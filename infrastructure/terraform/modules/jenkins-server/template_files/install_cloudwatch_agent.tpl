#!/bin/bash

touch /tmp/cloudwatch_install_log.txt
echo " - starting cloudwatch agent setup steps"  >> /tmp/cloudwatch_install_log.txt

## install cloudwatch agent package
yum install amazon-cloudwatch-agent -y

## download the cloudwatch agent config file from s3
aws s3 cp s3://${s3_bootstrap_bucket}/${s3_bootstrap_folder} ${dir_for_cwa_files} --recursive --exclude "*" --include "*.json"
if [ -f /opt/aws/amazon-cloudwatch-agent/bin/config.json ]; then
    echo " - successfully downloaded cloudwatch agent config file" >> /tmp/cloudwatch_install_log.txt
else
    echo " - failed to download cloudwatch agent config file, configuration failed!" >> /tmp/cloudwatch_install_log.txt
    exit 1
fi

## restart the service with the config file 
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
echo " - successfully restarted cloudwatch agent service with new config file " >> /tmp/cloudwatch_install_log.txt