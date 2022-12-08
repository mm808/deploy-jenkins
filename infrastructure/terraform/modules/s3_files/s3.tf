resource "aws_s3_object" "cloudwatch_agent_config" {
    bucket  = "${var.s3_bootstrap_bucket}"
    key     =  "${var.s3_bootstrap_folder}/config.json"
    source = "server_config_files/config.json"
    etag = filemd5("server_config_files/config.json")
}

resource "aws_s3_object" "copy_backup_script" {
    bucket  = "${var.s3_bootstrap_bucket}"
    key     =  "${var.s3_bootstrap_folder}/${var.copy_backup_script}"
    source = "server_config_files/${var.copy_backup_script}"
    etag = filemd5("server_config_files/${var.copy_backup_script}")
}

resource "aws_s3_object" "create_backup_script" {
    bucket  = "${var.s3_bootstrap_bucket}"
    key     =  "${var.s3_bootstrap_folder}/${var.create_backup_script}"
    source = "server_config_files/${var.create_backup_script}"
    etag = filemd5("server_config_files/${var.create_backup_script}")
}

resource "aws_s3_object" "restore_backups_script" {
    bucket  = "${var.s3_bootstrap_bucket}"
    key     =  "${var.s3_bootstrap_folder}/${var.backup_script_name}"
    source = "server_config_files/${var.backup_script_name}"
    etag = filemd5("server_config_files/${var.backup_script_name}")
}
