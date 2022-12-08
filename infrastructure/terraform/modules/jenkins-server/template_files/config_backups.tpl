#!/bin/bash

touch /tmp/config_backups_log.txt
echo "Starting steps to configure backups... "  >> /tmp/config_backups_log.txt

mkdir -p /tmp/jenkins_backups
mkdir -p /tmp/jenkins_backup_scripts
if [ -d "/tmp/jenkins_backup_scripts" ] && [ -d "/tmp/jenkins_backups" ]; then
    " - created backup script and backup zip folder locations\n " >> /tmp/config_backups_log.txt
fi

# get create_backup_script
aws s3 cp s3://${bootstrap_bucket}/${bootstrap_folder}/${create_backup_script} /tmp/jenkins_backup_scripts &>> /tmp/config_backups_log.txt

if [ -f "/tmp/jenkins_backup_scripts/${create_backup_script}" ]; then
    printf " - successfully downloaded create backup script\n " >> /tmp/config_backups_log.txt
else
  printf " - didn't downloaded create backup script!\n "  >> /tmp/config_backups_log.txt
  exit 1
fi

# get copy_backup_script
aws s3 cp s3://${bootstrap_bucket}/${bootstrap_folder}/${copy_backup_script} /tmp/jenkins_backup_scripts &>> /tmp/config_backups_log.txt

if [ -f "/tmp/jenkins_backup_scripts/${copy_backup_script}" ]; then
    printf " - successfully downloaded copy backup script \n " >> /tmp/config_backups_log.txt
else
  printf " - didn't downloaded copy backup script!\n "  >> /tmp/config_backups_log.txt
  exit 1
fi

chmod +x /tmp/jenkins_backup_scripts/${create_backup_script}
chmod +x /tmp/jenkins_backup_scripts/${copy_backup_script}
printf " - set execution mode on backup scripts\n" >> /tmp/config_backups_log.txt
