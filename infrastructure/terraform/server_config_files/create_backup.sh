#!/bin/sh
# this script tars up the jenkins_home dir so it can be copied up to s3

LOGFILE=/tmp/jenkins_backup_scripts/create_backup_log.txt
## delete the existing log to keep things tidy
if ls $LOGFILE 1> /dev/null 2>&1; then
        echo "Found existing log, removing now" >> $LOGFILE
        rm -f $LOGFILE
fi

## delete the existing backup to keep things tidy
FILE=/tmp/jenkins_backups/*.tar.gz
if ls $FILE 1> /dev/null 2>&1; then
  echo "Found existing backup, removing now" >> $LOGFILE
  rm -f $FILE
fi

current_date=$(date "+%Y.%m.%d")
backup_filename=jenkins_backup.$current_date
backup_file_dir=/tmp/jenkins_backups
jenkins_home_path=/var/lib/jenkins

echo "Creating backup of ${jenkins_home_path} to ${backup_file_dir}/${j_backup_filename}.tar.gz ..." >> $LOGFILE
tar -czf $backup_file_dir/$backup_filename.tar.gz -C $jenkins_home_path .

echo "Backup creation complete: $(date)" >> $LOGFILE
