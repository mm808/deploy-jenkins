#!/bin/sh

# this script uploads the latest jenkins_home backup and /etc/sudoers to s3
# script must get a bucket name as first argument and environment name as second argument

LOGFILE=/tmp/jenkins_backup_scripts/copy_backup_log.txt
## delete the existing log to keep things tidy
if ls $LOGFILE 1> /dev/null 2>&1; then
  echo "Found existing log, removing now" >> $LOGFILE
  rm -f $LOGFILE
fi

jenkins_backups_dir=/tmp/jenkins_backups
sudoers_path=/etc/sudoers
current_date=$(date "+%Y.%m.%d")

# find what file is in backups directory, get only the newest
target_file=$(ls -t "${jenkins_backups_dir}" | head -n1)
echo "Newest file in ${jenkins_backups_dir}: ${target_file}" >> $LOGFILE

# copy backup to s3
echo "Copying ${target_file} to ${1}/${2}/backups ..." >> $LOGFILE
aws s3 cp $jenkins_backups_dir/$target_file s3://$1/$2/backups/$target_file
echo "Jenkins backup file upload complete: $(date)" >> $LOGFILE

echo "Copying sudoers to ${1}/${2}/backups ..." >> $LOGFILE
aws s3 cp $sudoers_path s3://$1/$2/backups/sudoers.$current_date
echo "sudoers backup file upload complete: $(date)" >> $LOGFILE