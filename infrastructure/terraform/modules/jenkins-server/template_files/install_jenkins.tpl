#!/bin/bash

touch /tmp/jenkins_install_log.txt
echo "Starting jenkins install steps... "  >> /tmp/jenkins_install_log.txt
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum upgrade
echo "  - installed updates and gpg keys. "  >> /tmp/jenkins_install_log.txt
amazon-linux-extras install java-openjdk11 -y
echo "  - installed java. "  >> /tmp/jenkins_install_log.txt
yum install git -y
echo "  - installed git. "  >> /tmp/jenkins_install_log.txt
yum install jenkins -y
systemctl enable jenkins
systemctl start jenkins
echo "  - installed and started jenkins. "  >> /tmp/jenkins_install_log.txt
