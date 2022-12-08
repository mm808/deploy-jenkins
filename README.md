# deploy-jenkins

## What's this project for?
This project provides IAC to deploy a new ec2 server in a private subnet behind a load balancer and install jenkins. It will deploy the latest backup into jenkins_home so we have the existing users and projects.   

## Guidelines 
- The backend state includes the use of a dynamodb table to lock the state file while updates occur. The table was created manually before using this project. For each version of this project you should create a new environment or version specific table for use and include it in the *-backend,tfvars file.   
- The backend uses an s3 bucket for the state file. The bucket was manually created before use of this project. For each version of this project you should create a new environment specific s3 bucket or bucket prefix.   
- The bootstrap process uses an s3 bucket for some config files. The bucket was manually created before use of this project. You should create a new environment specific s3 bucket or bucket prefix for the items in infrastructure/terraform/server_config_files. If you need to do something else during bootstrap then modify or add to these files and create a step to get the new file to the server. Once the machine is bootstrapped these files will not get used again.   
- The set up process creates log files in /tmp that indicate some basic steps along the way. View these if the server isn't correct after deploy.   
- You must set up cron jobs to trigger the create_backup and copy_tos3 once you are using the new server in production.  
- The cron for copy_tos3 must be set with an argument for the bucket and environment the backup gets copied to  

## Use
To spin up a new server this process must have access to the bootstrap bucket in s3. Currently this is configured in infrastructure/terraform/modules/ec2.tf with the profile and policy given the new server. Additionally permission needs to be granted to this server into the Dev account to trigger CodeBuild and access to the CodeBuild source S3 bucket. That role must be manually put in place in the 'spoke' accounts ahead of time and then referenced in the policy created in infrastructure/terraform/modules/ec2.tf as the variable 'cross_accnt_codebuild_role'.   
*ToDo:* make the permission and role creation part of this project   
We will need one of these per 'spoke' account.
