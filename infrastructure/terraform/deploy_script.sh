#!/bin/bash

if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]
then
  echo "Script requires values for ENV, COMMIT and TF_ACTION"
  exit 1
fi

timestamp=`date +%m-%d-%Y`
s3_bucket=terraformstatebucket-$1/deploy_new_jenkins/$1
tfplan_file="tfplan_$1_$2"

INIT_COMMAND=""
TF_COMMAND=""

INIT_COMMAND=${INIT_COMMAND:="terraform init -backend-config=$1-backend.tfvars"}
echo "Running: $INIT_COMMAND..."
${INIT_COMMAND}

if [[ "$3" = "PLAN" ]];
then  
  TF_COMMAND=${TF_COMMAND:="terraform plan -var-file=$1.tfvars -var timestamp=$timestamp -out=$tfplan_file"}
  echo "Running terraform plan. Out file is $tfplan_file"
  ${TF_COMMAND}
  echo "Copying tfplan_file to S3..."
  aws s3 cp $tfplan_file s3://$s3_bucket/tfplan_files/$tfplan_file
elif [[ "$3" = "APPLY" ]];
then
  TF_COMMAND=""
  echo "Downloading tfplan_file from S3..."
  aws s3 cp s3://$s3_bucket/tfplan_files/$tfplan_file .
  TF_COMMAND=${TF_COMMAND:="terraform apply $tfplan_file"}
  echo "Running terraform apply..."
  ${TF_COMMAND}
else
  echo "No TF_ACTION found, build failed"
  exit 1
fi
