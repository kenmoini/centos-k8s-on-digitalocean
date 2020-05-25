#!/usr/bin/env bash

DO_PAT="someSecretLongThing"

TERRAFORM_INSTALL="true"
TERRAFORM_VERSION="0.12.25"

CREATE_CLUSTER="true"

DOMAIN="example.com"
STACK_NAME="kemo-k8s"

MASTER_NODE_COUNT="3"
MASTER_NODE_SIZE="s-2vcpu-4gb"
MASTER_NODE_IMAGE="centos-7-x64"

WORKER_NODE_COUNT="2"
WORKER_NODE_SIZE="s-4vcpu-8gb"
WORKER_NODE_IMAGE="centos-7-x64"

DO_DATA_CENTER="nyc1"

KUBERNETES_API_PORT="6443"

### DO NOT EDIT PAST THIS LINE

export CLUSTER_NAME="${STACK_NAME}.${DOMAIN}"
export LOADBALANCER_NODE_COUNT="1"
export LOADBALANCER_NODE_SIZE="s-1vcpu-1gb"
export LOADBALANCER_NODE_IMAGE="centos-7-x64"

export TF_VAR_do_datacenter=$DO_DATA_CENTER
export TF_VAR_do_token=$DO_PAT
export TF_VAR_stack_name=$STACK_NAME
export TF_VAR_domain=$DOMAIN

export TF_VAR_k8s_master_node_count=$MASTER_NODE_COUNT
export TF_VAR_k8s_master_node_size=$MASTER_NODE_SIZE
export TF_VAR_k8s_master_node_image=$MASTER_NODE_IMAGE
export TF_VAR_k8s_worker_node_count=$WORKER_NODE_COUNT
export TF_VAR_k8s_worker_node_size=$WORKER_NODE_SIZE
export TF_VAR_k8s_worker_node_image=$WORKER_NODE_IMAGE
export TF_VAR_k8s_lb_node_size=$LOADBALANCER_NODE_SIZE
export TF_VAR_k8s_lb_node_image=$LOADBALANCER_NODE_IMAGE