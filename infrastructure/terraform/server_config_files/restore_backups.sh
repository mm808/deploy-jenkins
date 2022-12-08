#!/bin/bash

# this script will download the latest jenkins_home backup and put it into place so jenkins runs with all the latest config from the existing server
# it also downloads the latest backup of /etc/sudoers as part of making the server run with all the latest config from the existing server
# the script must get a bucket name arguement

echo "Starting jenkins restore script steps... "  >> /tmp/restore_jenkins_log.txt
JENKINS_DIR=/var/lib/jenkins
TARGET_DIR=/tmp/jenkins_s3_backup

LATEST_J_BACKUP=$(aws s3api list-objects-v2 --bucket $1 --query '(sort_by(Contents[?contains(Key, `'jenkins_backup'`)], &LastModified))[-1].Key')
# this removes "" from around file name
TEMPJ=`echo $LATEST_J_BACKUP | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`

printf " - latest Jenkins backup in s3 is %s\n" $TEMPJ >> /tmp/restore_jenkins_log.txt 
aws s3 cp s3://$1/$TEMPJ $TARGET_DIR/$TEMPJ

DOWNLOADED_FILE=$TARGET_DIR/$TEMPJ
if [ -f "${DOWNLOADED_FILE}" ]; then
    printf " - successfully downloaded backup to %s\n" $DOWNLOADED_FILE >> /tmp/restore_jenkins_log.txt
else
    printf " - failed to find the correct backup to extract!\n" >> /tmp/restore_jenkins_log.txt
    exit 1
fi

# keep a backup of the original jenkins_home
mv /var/lib/jenkins /var/lib/jenkins_orig

mkdir $JENKINS_DIR
tar -xf $DOWNLOADED_FILE -C $JENKINS_DIR
if [ -d "${JENKINS_DIR}/jobs" ]; then
    printf " - successfully extracted backup to %s\n" $JENKINS_DIR >> /tmp/restore_jenkins_log.txt
else
    printf " - failed to extract the backup to expected location!\n" >> /tmp/restore_jenkins_log.txt
    exit 1
fi

mv $JENKINS_DIR/config.xml /var/lib/jenkins_orig
systemctl restart jenkins
printf " - restarted service without config.xml to create default config\n" >> /tmp/restore_jenkins_log.txt

cp /var/lib/jenkins_orig/config.xml $JENKINS_DIR
chown jenkins:root $JENKINS_DIR/config.xml
systemctl restart jenkins
printf " - restarted service with astech config.xml to pick up desired configuration\n" >> /tmp/restore_jenkins_log.txt

LATEST_S_BACKUP=$(aws s3api list-objects-v2 --bucket $1 --query '(sort_by(Contents[?contains(Key, `'sudoers'`)], &LastModified))[-1].Key')
TEMPS=`echo $LATEST_S_BACKUP | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
printf " - latest sudoers backup in s3 is %s\n" $TEMPS >> /tmp/restore_jenkins_log.txt 

mv /etc/sudoers /etc/sudoers.bak
aws s3 cp s3://$1/$TEMPS $TARGET_DIR/$TEMPS
mv $TARGET_DIR/$TEMPS /etc/sudoers
if [ -f "/etc/sudoers" ]; then
    printf " - successfully extracted sudoers backup to /etc/\n" >> /tmp/restore_jenkins_log.txt
else
    printf " - failed to extract sudoers backup!\n" >> /tmp/restore_jenkins_log.txt
    exit 1
fi