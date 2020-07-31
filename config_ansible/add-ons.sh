#!/bin/bash

## set -x	## Uncomment for debugging

## Include vars if the file exists
FILE=../vars.sh
if [ -f "$FILE" ]; then
    source ../vars.sh
fi

## Functions
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
  --extra-vars "kubernetes_api_port=${KUBERNETES_API_PORT}" \
  --extra-vars "kubernetes_cni=${KUBERNETES_CNI}" \
  --extra-vars "kubernetes_create_global_cluster_admin_service_account=${KUBERNETES_CREATE_GLOBAL_CLUSTER_ADMIN_SERVICE_ACCOUNT}" \
  --extra-vars "kubernetes_global_cluster_admin_service_account_name=${KUBERNETES_GLOBAL_CLUSTER_ADMIN_SERVICE_ACCOUNT_NAME}" \
  --extra-vars "kubernetes_remove_taint_from_masters=${KUBERNETES_REMOVE_TAINT_FROM_MASTERS}" \
  --extra-vars "kubernetes_deploy_dashboard=${KUBERNETES_DEPLOY_DASHBOARD}" \
  --extra-vars "kubernetes_deploy_metrics_server=${KUBERNETES_DEPLOY_METRICS_SERVER}" \
  --extra-vars "kubernetes_deploy_logviewer=${KUBERNETES_DEPLOY_LOGVIEWER}" \
  --extra-vars "kubernetes_deploy_helm=${KUBERNETES_DEPLOY_HELM}" \
  --extra-vars "kubernetes_deploy_nginx_ingress=${KUBERNETES_DEPLOY_NGINX_INGRESS}" \
  tasks/postconfig.yaml