## Kubernetes Terraform Deployer on DigitalOcean

This set of assets will deploy the infrastructure needed for a multi-master, multi-worker, fully HA Kubernetes cluster running on DigitalOcean.

## To Use

1. Copy the `../example.vars.sh` file to `../vars.sh`
2. Modify as needed
3. `./create.sh`
4. And alternatively when you're done: `./destroy.sh`

## Droplet Sizes
A map of Droplet sizes (in NYC3) to make specifying Droplet sizes simpler:

| Droplet Size   |
| -------------- |
| s-1vcpu-1gb    |
| s-1vcpu-2gb    |
| s-1vcpu-3gb    |
| s-2vcpu-2gb    |
| s-2vcpu-4gb    |
| s-3vcpu-1gb    |
| s-4vcpu-8gb    |
| s-6vcpu-16gb   |
| s-8vcpu-32gb   |
| s-16vcpu-64gb  |
| s-20vcpu-96gb  |
| s-24vcpu-128gb |
| s-32vcpu-192gb |

See [DigitalOcean Pricing](https://www.digitalocean.com/pricing/) for costs.