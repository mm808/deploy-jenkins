#!/bin/bash

touch /tmp/restore_jenkins_log.txt
echo "Starting jenkins restore steps... "  >> /tmp/restore_jenkins_log.txt
mkdir ${dir_for_backup}

### download the script that will download the latest backup - I know, I know, seems obfuscated
aws s3 cp s3://${bootstrap_bucket}/${bootstrap_folder}/${backup_script_name} ${dir_for_backup}/${backup_script_name}
if [ -f "${dir_for_backup}/${backup_script_name}" ]; then
    printf " - successfully downloaded %s\n " ${backup_script_name} >> /tmp/restore_jenkins_log.txt
else
    printf " - failed to download backup script\n" >> /tmp/restore_jenkins_log.txt
    exit 1
fi

## run the script
chmod +x ${dir_for_backup}/${backup_script_name}
.${dir_for_backup}/${backup_script_name} "${bootstrap_bucket}"
