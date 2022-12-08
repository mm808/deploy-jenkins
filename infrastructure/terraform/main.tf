# config terraform
terraform {
  required_version = "=1.2.8"
  backend "s3" {}
  required_providers {
    aws = "~> 4.0"
  }
}


# config provider
provider "aws" {
  region = var.app_region
  default_tags {
    tags = {
      env              = var.env
      owner            = var.owner
      managed-by       = "Terraform"
      create-date      = var.timestamp
      source-repo      = "https://bitbucket.org/astechdevelopment/deploy_new_jenkins/"
    }
  }
}

module "s3_files" {
  source = "./modules/s3_files"

  s3_bootstrap_bucket  = var.s3_bootstrap_bucket
  s3_bootstrap_folder  = var.s3_bootstrap_folder
  copy_backup_script   = var.copy_backup_script
  create_backup_script = var.create_backup_script
  backup_script_name   = var.backup_script_name
}

module "load-balancer" {
  source = "./modules/load-balancer"

  app_name        = var.app_name
  env             = var.env
  vpc_id          = var.vpc_id
  lb_subnet_ids   = var.lb_subnet_ids
  lb_subnet_cidrs = var.lb_subnet_cidrs
  webserver-port  = var.webserver-port
  jenkins-ec2-id  = module.jenkins-server.jenkins-ec2-id
}

module "jenkins-server" {
  source = "./modules/jenkins-server"

  app_name                   = var.app_name
  app_region                 = var.app_region
  env                        = var.env
  vpc_id                     = var.vpc_id
  instance_type              = var.instance_type
  infra_alarm_sns_arn        = var.infra_alarm_sns_arn
  server_subnet              = var.server_subnet
  app-lb-sg-id               = module.load-balancer.app-lb-sg-id
  lb_subnet_cidrs            = var.lb_subnet_cidrs
  timestamp                  = var.timestamp
  webserver-port             = var.webserver-port
  s3_bootstrap_bucket        = var.s3_bootstrap_bucket
  backup_script_name         = var.backup_script_name
  dir_for_backup             = var.dir_for_backup
  dir_for_cwa_files          = var.dir_for_cwa_files
  cross_accnt_codebuild_role = var.cross_accnt_codebuild_role
  disk_monitoring_device     = var.disk_monitoring_device
}
