variable "do_datacenter" {
  type    = string
  default = "nyc3"
}
variable "stack_name" {
  type    = string
  default = "polyglotK8s"
}
variable "domain" {
  type    = string
  default = "polyglot.host"
}
variable "k8s_master_node_count" {
  type    = string
  default = "3"
}
variable "k8s_master_node_size" {
  type    = string
  default = "s-2vcpu-4gb"
}
variable "k8s_master_node_image" {
  type    = string
  default = "centos-7-x64"
}
variable "k8s_worker_node_count" {
  type    = string
  default = "2"
}
variable "k8s_worker_node_size" {
  type    = string
  default = "s-4vcpu-8gb"
}
variable "k8s_worker_node_image" {
  type    = string
  default = "centos-7-x64"
}
variable "k8s_lb_node_size" {
  type    = string
  default = "s-1vcpu-1gb"
}
variable "k8s_lb_node_image" {
  type    = string
  default = "centos-7-x64"
}
variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "tls_private_key" "cluster_new_key" {
  algorithm = "RSA"
}

resource "local_file" "cluster_new_priv_file" {
  content         = tls_private_key.cluster_new_key.private_key_pem
  filename        = "../.generated/.${var.stack_name}.${var.domain}/priv.pem"
  file_permission = "0600"
}
resource "local_file" "cluster_new_pub_file" {
  content  = tls_private_key.cluster_new_key.public_key_openssh
  filename = "../.generated/.${var.stack_name}.${var.domain}/pub.key"
}

resource "digitalocean_ssh_key" "cluster_ssh_key" {
  name       = "${var.stack_name}SSHKey"
  public_key = tls_private_key.cluster_new_key.public_key_openssh
}

locals {
  ssh_fingerprint = digitalocean_ssh_key.cluster_ssh_key.fingerprint
}

data "template_file" "ansible_inventory" {
  template = "${file("./inventory.tpl")}"
  vars = {
    k8s_master_nodes = "${join("\n", formatlist("%s ansible_do_host=%s ansible_internal_private_ip=%s", digitalocean_droplet.k8sMaster_droplets.*.ipv4_address, digitalocean_droplet.k8sMaster_droplets.*.name, digitalocean_droplet.k8sMaster_droplets.*.ipv4_address_private))}"
    k8s_worker_nodes = "${join("\n", formatlist("%s ansible_do_host=%s ansible_internal_private_ip=%s", digitalocean_droplet.k8sWorker_droplets.*.ipv4_address, digitalocean_droplet.k8sWorker_droplets.*.name, digitalocean_droplet.k8sWorker_droplets.*.ipv4_address_private))}"
    k8s_lb_nodes     = "${join("\n", formatlist("%s ansible_do_host=%s ansible_internal_private_ip=%s", digitalocean_droplet.k8sLoadBalancer_droplets.*.ipv4_address, digitalocean_droplet.k8sLoadBalancer_droplets.*.name, digitalocean_droplet.k8sLoadBalancer_droplets.*.ipv4_address_private))}"
    ssh_private_file = "../.generated/.${var.stack_name}.${var.domain}/priv.pem"
  }
  depends_on = [digitalocean_droplet.k8sMaster_droplets, digitalocean_droplet.k8sWorker_droplets, digitalocean_droplet.k8sLoadBalancer_droplets]
}

resource "local_file" "ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "../.generated/.${var.stack_name}.${var.domain}/inventory"
}

resource "digitalocean_vpc" "k8sVPC" {
  name   = "${var.stack_name}-k8s-network"
  region = var.do_datacenter
}

resource "digitalocean_droplet" "k8sMaster_droplets" {
  count              = var.k8s_master_node_count
  image              = var.k8s_master_node_image
  name               = "${var.stack_name}-k8sMasterNode-${count.index}"
  region             = var.do_datacenter
  size               = var.k8s_master_node_size
  private_networking = true
  vpc_uuid           = digitalocean_vpc.k8sVPC.id
  ssh_keys           = [local.ssh_fingerprint]
  depends_on         = [digitalocean_ssh_key.cluster_ssh_key]
  tags               = ["${var.stack_name}-k8sMasterNode-${count.index}", "${var.stack_name}", "k8sMasterNode", "k8sMasterNode-${count.index}", "k8s", "k8sMultiMaster"]
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"${var.stack_name}-k8sMasterNode-${count.index}\" -i \"${self.ipv4_address}\" -f"
  }
  /*
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"api.${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"*.${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
  */
}

resource "digitalocean_droplet" "k8sWorker_droplets" {
  count              = var.k8s_worker_node_count
  image              = var.k8s_worker_node_image
  name               = "${var.stack_name}-k8sWorkerNode-${count.index}"
  region             = var.do_datacenter
  size               = var.k8s_worker_node_size
  private_networking = true
  vpc_uuid           = digitalocean_vpc.k8sVPC.id
  ssh_keys           = [local.ssh_fingerprint]
  depends_on         = [digitalocean_ssh_key.cluster_ssh_key]
  tags               = ["${var.stack_name}-k8sWorkerNode-${count.index}", "${var.stack_name}", "k8sWorkerNode", "k8sWorkerNode-${count.index}", "k8s", "k8sMultiMaster"]
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"${var.stack_name}-k8sWorkerNode-${count.index}\" -i \"${self.ipv4_address}\" -f"
  }
  /*
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"api.${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"*.${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
  */
}

resource "digitalocean_droplet" "k8sLoadBalancer_droplets" {
  count              = 1
  image              = var.k8s_lb_node_image
  name               = "${var.stack_name}-k8sLoadBalancerNode-${count.index}"
  region             = var.do_datacenter
  size               = var.k8s_lb_node_size
  private_networking = true
  vpc_uuid           = digitalocean_vpc.k8sVPC.id
  ssh_keys           = [local.ssh_fingerprint]
  depends_on         = [digitalocean_ssh_key.cluster_ssh_key]
  tags               = ["${var.stack_name}-k8sLoadBalancerNode-${count.index}", "${var.stack_name}", "k8sLoadBalancerNode", "k8sLoadBalancerNode-${count.index}", "k8s", "k8sMultiMaster"]
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"${var.stack_name}-k8sLoadBalancerNode-${count.index}\" -i \"${self.ipv4_address}\" -f"
  }
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"api.${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"apps.${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"*.apps.${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
  provisioner "local-exec" {
    command = "DO_PAT=${var.do_token} ./do_dns_worker.sh -d \"${var.domain}\" -r \"*.${var.stack_name}\" -i \"${self.ipv4_address}\" -f"
  }
}
