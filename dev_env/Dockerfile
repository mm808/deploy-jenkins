FROM ubuntu:latest

ENV DEBIAN_FRONTEND="noninteractive" TZ="America"

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    python-setuptools \
    python3-pip \
    zip \
    unzip \
    jq \
    git \
    zlib1g-dev \
    build-essential \
    sudo \
    passwd \
    nano \
    groff \
    less \
    ssh

RUN mkdir /root/.pip && \
    pip3 install --upgrade pip && \
    pip install --upgrade awscli boto3 aws-sam-cli && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install awscli --user

RUN pip3 install jinja2==3.0 --user

RUN add-apt-repository --yes --update ppa:ansible/ansible && \
    apt install -y ansible && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://releases.hashicorp.com/terraform/1.2.8/terraform_1.2.8_linux_amd64.zip && \
    unzip terraform_1.2.8_linux_amd64.zip && \
    mv terraform /usr/local/bin/

RUN mkdir -p \
    /infrastructure
