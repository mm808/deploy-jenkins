#Create SG for allowing TCP/8080 to jenkins server
resource "aws_security_group" "jenkins-sg" {
  name        = "${var.app_name}-server-sg"
  description = "Allow TCP/8080"
  vpc_id      = var.vpc_id
  
  ingress {
    description     = "allow lb sg"
    from_port       = var.webserver-port
    to_port         = var.webserver-port
    protocol        = "tcp"
    security_groups = [var.app-lb-sg-id]
  }

  ingress {
    description     = "allow lb subnets"
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    cidr_blocks = var.lb_subnet_cidrs
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG to allow ssh on port 22 to jenkins server
resource "aws_security_group" "ssh" {
  name        = "allow-ssh-sg"
  description = "Allow TCP/22"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "Allow port 22 from public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi_east1" {
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for ssh into Jenkins master
resource "aws_key_pair" "jenkins-server-key" {
  key_name   = "jenkins-server-key"
  public_key = file("modules/jenkins-server/jenkins_server_key.pub")
}

# role jenkins server can assume to do stuff
resource "aws_iam_role" "jenkins_server_role" {
  name               = "${var.env}_jenkins_server_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

# policy allowing Jenkins server access to its s3 scripts
resource "aws_iam_role_policy" "jenkins_server_policy" {
  name     = "jenkins_server_policy"
  role     = aws_iam_role.jenkins_server_role.id
  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.s3_bootstrap_bucket}",
        "arn:aws:s3:::${var.s3_bootstrap_bucket}/*"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutRetentionPolicy"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

#instance profile for jenkins server ec2
resource "aws_iam_instance_profile" "jenkins_server_profile" {
  name     = "jenkins_server_profile-${var.env}"
  role     = aws_iam_role.jenkins_server_role.name
}

# master template for user_data/cloud_init
data "cloudinit_config" "server" {
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/template_files/install_jenkins.tpl", {}) 
  }
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/template_files/config_backups.tpl", {bootstrap_bucket = var.s3_bootstrap_bucket 
    bootstrap_folder = var.s3_bootstrap_folder
    create_backup_script = var.create_backup_script
    copy_backup_script = var.copy_backup_script
    })
  }
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/template_files/install_cloudwatch_agent.tpl", {s3_bootstrap_bucket = var.s3_bootstrap_bucket 
    s3_bootstrap_folder = var.s3_bootstrap_folder
    dir_for_cwa_files = var.dir_for_cwa_files
    app_region = var.app_region})
  }
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/template_files/restore_jenkins.tpl", {bootstrap_bucket = var.s3_bootstrap_bucket
    env = var.env
    bootstrap_folder = var.s3_bootstrap_folder
    backup_script_name = var.backup_script_name
    dir_for_backup = var.dir_for_backup})
  }
}

resource "aws_instance" "jenkins-master" {
  ami                         = data.aws_ssm_parameter.linuxAmi_east1.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.jenkins-server-key.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id, aws_security_group.ssh.id]
  subnet_id                   = var.server_subnet
  root_block_device {
    tags        = {
      name = "jenkins-server-disk"
    }
    volume_size = 50
    volume_type           = "gp3"
    delete_on_termination = true
  }
  iam_instance_profile = aws_iam_instance_profile.jenkins_server_profile.name
  
  tags = {
    Name = "jenkins_master_${var.env}"
  }
  
  user_data = data.cloudinit_config.server.rendered
}
