# Terraform Remote Lab

This Terraform configuration provisions a single Ubuntu 22.04 VM in AWS that mirrors the Docker and Vagrant lab environments. It creates the surrounding AWS networking (VPC, subnet, route table, security group) and uploads your SSH public key so you can connect immediately after `terraform apply`.

## Prerequisites

- Terraform >= 1.5.0
- AWS account with credentials exported via `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
- An existing SSH public key (for example `~/.ssh/id_ed25519.pub`)

## Quick start

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your details (owner tag, SSH key path, CIDR restrictions)
terraform init
terraform plan
terraform apply
```

After apply completes, Terraform prints the public IP, DNS name, and a ready-to-use SSH command:

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
```

## Customisation

- **Restrict SSH access** — Override `allowed_ssh_cidrs` in `terraform.tfvars` with your office or VPN CIDR blocks.
- **Use a specific AMI** — Set `ami_id` if your organisation maintains hardened images.
- **Change instance size** — Update `instance_type` (for example `t3.small`) to align with workload needs.
- **Tagging** — Edit the `tags` map to match your asset tracking scheme.

## Clean up

Destroy the lab to avoid unintentional costs:

```bash
terraform destroy
```
