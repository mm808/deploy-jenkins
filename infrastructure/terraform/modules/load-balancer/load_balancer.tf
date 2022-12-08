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

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.lb_subnet_cidrs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.lb_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.lb_subnet_cidrs
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.lb_subnet_cidrs
  }
}

resource "aws_lb" "application-lb" {
  name               = "jenkins-lb-${var.env}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app-lb-sg.id]
  subnets            = var.lb_subnet_ids
  tags = {
    Name = "Jenkins-LB"
  }
}

resource "aws_lb_target_group" "app-lb-tg" {
  name        = "${var.app_name}-lb-tg"
  port        = var.webserver-port
  target_type = "instance"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 60
    timeout = 5
    path     = "/login"
    port     = var.webserver-port
    matcher  = "200-299"
  }
  tags = {
    Name = "jenkins-target-group"
  }

  depends_on = [aws_lb.application-lb]
}

resource "aws_lb_listener" "jenkins-listener-http" {
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "jenkins-listener-https" {
  load_balancer_arn = aws_lb.application-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate_validation.jenkins_cert.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkins-lb-attach" {
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = var.jenkins-ec2-id
  port             = var.webserver-port
}