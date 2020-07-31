#!/bin/bash

## set -x	## Uncomment for debugging

sudo pwd

## Include vars if the file exists
FILE=../vars.sh
if [ -f "$FILE" ]; then
    source ../vars.sh
fi

bold=$(tput bold)
normal=$(tput sgr0)

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

echo -e "\n==============================================================="
echo -e " Your new Kubernetes cluster awaits!"
echo -e "===============================================================\n"

echo -e "${bold}Cluster API Endpoint:${normal} api.${STACK_NAME}.${DOMAIN}:${KUBERNETES_API_PORT}\n"
echo -e "${bold}Kube Config File:${normal} ${DIRNAME}/.generated/.${STACK_NAME}.${DOMAIN}/pulled-kube.conf\n"
echo -e "${bold}Set the context with:${normal} export KUBECONFIG=${DIRNAME}/.generated/.${STACK_NAME}.${DOMAIN}/pulled-kube.conf\n"

echo -e "${bold}Open a Dashboard Proxy:${normal} kubectl proxy\n"
echo -e "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/\n"

echo -e "${bold}Cluster-admin SA Token:${normal} ${KUBERNETES_GLOBAL_CLUSTER_ADMIN_SERVICE_ACCOUNT_NAME}"
export KUBECONFIG=${DIRNAME}/.generated/.${STACK_NAME}.${DOMAIN}/pulled-kube.conf
echo $(kubectl get secret -n kube-system $(kubectl get serviceaccount/prod-nyc1-pv-k8s-admin -n kube-system -o jsonpath='{.secrets..name}') -o jsonpath='{.data.token}' | base64 --decode)