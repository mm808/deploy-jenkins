variable "s3_bootstrap_bucket" {
  description = "where bootstrap items are"
  type        = string
}

variable "s3_bootstrap_folder" {
  description = "where bootstrap scripts are"
  type        = string
  default     = "bootstrap"
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

variable "backup_script_name" {
  type    = string
  default = "restore_backups.sh"
}
