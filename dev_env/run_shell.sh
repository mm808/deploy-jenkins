#!/bin/bash

if [ -z "$1" ]
then
  echo "you must provide VERSION variable"
  exit 1
fi

docker run -it --rm --name tf-ans-aws-container \
<<<<<<< HEAD
    --volume /Users/matt/SourceCode/GitLab_Projs/deploy-jenkins/infrastructure:/infrastructure \
=======
    --volume ~/SourceCode/asTech_Projs/DevOps/deploy_new_jenkins/infrastructure:/infrastructure \
>>>>>>> add-monitoring
    mattman70/tf1-2-8-ansible-shell:$1