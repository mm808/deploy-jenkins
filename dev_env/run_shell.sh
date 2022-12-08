#!/bin/bash

if [ -z "$1" ]
then
  echo "you must provide VERSION variable"
  exit 1
fi

docker run -it --rm --name tf-ans-aws-container \
    --volume ~/SourceCode/DevOps/deploy-jenkins/infrastructure:/infrastructure \
    mattman70/tf1-2-8-ansible-shell:$1