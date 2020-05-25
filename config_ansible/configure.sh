#!/bin/bash

## set -x	## Uncomment for debugging

sudo pwd

## Include vars if the file exists
FILE=../vars.sh
if [ -f "$FILE" ]; then
    source ../vars.sh
fi

## Functions
function checkForProgram() {
    command -v $1
    if [[ $? -eq 0 ]]; then
        printf '%-72s %-7s\n' $1 "PASSED!";
    else
        printf '%-72s %-7s\n' $1 "FAILED!";
    fi
}
function checkForProgramAndExit() {
    command -v $1
    if [[ $? -eq 0 ]]; then
        printf '%-72s %-7s\n' $1 "PASSED!";
    else
        printf '%-72s %-7s\n' $1 "FAILED!";
        exit 1
    fi
}

checkForProgramAndExit ansible-playbook

ansible-playbook -i ../.generated/.${STACK_NAME}.${DOMAIN}/inventory \
  --extra-vars "stack_name=${STACK_NAME}" \
  --extra-vars "domain=${DOMAIN}" \
  tasks/preconfig.yaml

ansible-playbook -i ../.generated/.${STACK_NAME}.${DOMAIN}/inventory \
  --extra-vars "stack_name=${STACK_NAME}" \
  --extra-vars "domain=${DOMAIN}" \
  --extra-vars "kubernetes_api_port=${KUBERNETES_API_PORT}" \
  tasks/configure_load_balancers.yaml

ansible-playbook -i ../.generated/.${STACK_NAME}.${DOMAIN}/inventory \
  --extra-vars "stack_name=${STACK_NAME}" \
  --extra-vars "domain=${DOMAIN}" \
  --extra-vars "kubernetes_api_port=${KUBERNETES_API_PORT}" \
  tasks/configure_masters.yaml

ansible-playbook -i ../.generated/.${STACK_NAME}.${DOMAIN}/inventory \
  --extra-vars "stack_name=${STACK_NAME}" \
  --extra-vars "domain=${DOMAIN}" \
  --extra-vars "kubernetes_api_port=${KUBERNETES_API_PORT}" \
  tasks/configure_workers.yaml