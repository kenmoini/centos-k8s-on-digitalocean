#!/bin/bash

## set -x	## Uncomment for debugging

sudo pwd

## Include vars if the file exists
FILE=./vars.sh
if [ -f "$FILE" ]; then
    source ./vars.sh
fi

export CREATE_CLUSTER=${CREATE_CLUSTER:="true"}

export TERRAFORM_INSTALL=${TERRAFORM_INSTALL:="false"}
export TERRAFORM_VERSION=${TERRAFORM_VERSION:="0.12.25"}

export DO_PAT=${DO_PAT:="safasdfhjasjkdfhasjfhasfkh"}


## Functions
function checkForProgram() {
    command -v $1
    if [[ $? -eq 0 ]]; then
        printf '%-72s %-7s\n' $1 "PASSED!";
    else
        printf '%-72s %-7s\n' $1 "FAILED!";
        exit 1
    fi
}

checkForProgram wget
checkForProgram jq
checkForProgram ansible-playbook

if [ $TERRAFORM_INSTALL = "true" ]; then
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    chmod +x terraform
    sudo mv terraform /usr/local/bin/
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi

checkForProgram terraform

if [ $CREATE_CLUSTER = "true" ]; then
    terraform init
    terraform plan -var "do_token=${DO_PAT}"
    terraform apply -var "do_token=${DO_PAT}"
fi

