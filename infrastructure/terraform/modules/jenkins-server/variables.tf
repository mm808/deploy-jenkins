variable "env" {
  type    = string
}

variable "app_name" {
  description = "app_name"
  type = string  
}

variable "app_region" {
  description = "app_region"
  type        = string
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "server_subnet" {
  description = "subnet for jenkins"
  type = string
}

variable "timestamp"{
  description = "use date tags"
  type = string
}

variable "app-lb-sg-id" {
  description = "sec grp id of load balancer from output"
  type = string
}

variable "lb_subnet_cidrs" {
  description = "load balancer cidr ranges"
  type = list(string)
}

variable "instance_type" {
  description = "server instance type"
  type        = string
}

variable "infra_alarm_sns_arn" {
  description = "sns topic to alert on alarm"
  type        = string
}

variable "disk_monitoring_device" {
  description = "disk device name"
  type        = string
}

variable "webserver-port" {
  type    = number
  default = 8080
}

variable "s3_bootstrap_bucket" {
  description = "where bootstrap items are"
  type = string
}

variable "dir_for_cwa_files" {
  description = "dir for cloudwatch config files"
  type        = string
  default     = "/opt/aws/amazon-cloudwatch-agent/bin"
}

variable "s3_bootstrap_folder" {
  description = "where bootstrap scripts are"
  type        = string
  default     = "bootstrap"
}

variable "backup_script_name" {
  type    = string
  default = "restore_backups.sh"
}

variable "dir_for_backup" {
  type    = string
  default = "/tmp/jenkins_s3_backup"
}

variable "create_backup_script" {
  description = "create_backup_script name"
  type        = string
  default     = "create_backup.sh"
}

variable "copy_backup_script" {
  description = "copy_backup_script name"
  type        = string
  default     = "copy_backups_tos3.sh"
}

variable "cross_accnt_codebuild_role" {
  description = "role to assume in dev accnt"
  type = string
}
