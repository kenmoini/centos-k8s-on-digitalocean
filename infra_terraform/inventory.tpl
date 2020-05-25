## Ansible Inventory template file used by Terraform to create an ./inventory file populated with the nodes it created

[kubernetesMasterNodes]
${k8s_master_nodes}

[kubernetesWorkerNodes]
${k8s_worker_nodes}

[kubernetesLoadBalancerNodes]
${k8s_lb_nodes}

[all:vars]
ansible_ssh_private_key_file=${ssh_private_file}
ansible_ssh_user=root
ansible_ssh_common_args='-o StrictHostKeyChecking=no'