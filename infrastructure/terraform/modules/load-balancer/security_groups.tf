resource "aws_security_group" "app-lb-sg" {
  name        = "${var.app_name}-lb-sg"
  description = "${var.app_name} lb security group"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

#Create SG for allowing TCP/8080 from * 
resource "aws_security_group" "jenkins-sg" {
  name        = "${var.app_name}-server-sg"
  description = "Allow TCP/8080"
  vpc_id      = var.vpc_id
  ingress {
    description     = "allow lb sg"
    from_port       = var.webserver-port
    to_port         = var.webserver-port
    protocol        = "tcp"
    security_groups = [aws_security_group.app-lb-sg.id]
  }
  ingress {
    description     = "allow public on 8080" 
    from_port   = "8080" 
    to_port     = "8080" 
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

# SG to allow ssh on port 22
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


