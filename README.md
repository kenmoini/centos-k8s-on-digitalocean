## Kubernetes on DigitalOcean, on CentOS

*Ideally this would be RHEL, but RHEL isn't supported on DigitalOcean so no real point to that, but this should still work in a RHEL environment...*

Let's not kid ourselves: the hyperscalar cloud providers are expensive.

Would you like to quickly deploy a highly available, multi-master, multi-worker Kubernetes cluster on the more affordable [DigitalOcean cloud](https://m.do.co/c/9058ed8261ee)? *(Use that link for $100 in credits on DigitalOcean!)*

## What this will do

If you use the whole provisioner as intended, as long as you bring along a DigitalOcean Personal Access Token this code base will:

1. Create the needed infrastructure in DigitalOcean with Terraform
2. Set the DNS records needed
3. Configure the HAProxy Load Balancer for the cluster
4. Deploy a fully HA Kubernetes cluster
5. Optionally deploy extras such as the Kubernetes Dashboard, Metrics Server, Operator Framework, a test application, and more.

## How to Use

1. Copy the `example.vars.sh` file to `vars.sh` - modify as desired
2. Enter the `infra_terraform` directory and run `./create.sh`
3. Enter the `config_ansible` directory and run:

```bash
./configure.sh
./deploy.sh
./add-ons.sh
./print-out.sh
```
