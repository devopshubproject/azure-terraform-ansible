# azure-terraform-ansible
This repo contains script which will help you to provision full functioning ansible lab environment on azure using terraform


# Objectives

This repo contains a set of _Terraform_ scripts that helps to deploy a basic _Ansible_ environment (Controller and server) in _Azure_. Which can be effectively used to perform testing of the ansible functionality.

<img src ="https://blog.wescale.fr/content/images/2018/10/Logo-article_Plan-de-travail-1.png" align="center" width=2500 height=1000>

# Prerequisite

-  Azure Subscription
-  Terraform
-  Storage account in Azure to store the state of Azure
-  Azure CLI

# Initial Setup

This script comes with full packed script which will provision one ansible __control server__ and two ansible __worker ndoes__. In case if you want to increase the number of __worker nodes__ just update the count in __tfvars file accordingly.

```
Path to the file: ./tfvars/dev.tfvars

$ cat tfvars/dev.tfvars

# General

workers_count = 2   <== The value can be changed
```

This script will install and configure __Ansible__ during provisioning automatically and will also ensure the secure connectivity between the control nodes and worker nodes via __SSH mode__ (password less authentication) and will the entries across the know-host.

For Reference:

```
###################################################
# Azure local file - ansible ssh add
###################################################

resource "local_file" "host_script" {
    filename = "./add_host.sh"

    content = <<-EOF
    echo "Setting SSH Key"
    echo "${tls_private_key.sshkey.private_key_pem}"
    .
    .
    .
}
```


> This script will also comes in hand where it will facilitate one by creating the host file/inventory file automatically for __Ansible__ to refer later.


For Reference:

```
resource "local_file" "inventory" {
    filename = "./host.ini"

    content = <<-EOF
    [Webserver]
    .
    .
    .
}
```

## Create Ansible Lab

1) Login into your system, clone the github repo into your local.

`
git clone https://github.com/devopshubproject/azure-terraform-ansible.git
`

2) Goto into the cloned folder, 

`
cd ./azure-terraform-ansible
`

3) Open a terminal, try to connect to Azure before running the script.

`
az login
`

A login windown will open on the browser, pass on your crendentials and close the windows. This will create a trust token.

Note: Before doing this you need to have AZ cli installed on the machine and also TF.

To install and configure Az cli and terraform refer the below link
* [Azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Terraform](https://www.terraform.io/downloads.html)

4) Before running the script, one must create __Azure storage account__ as a backend, if not you can connect the backend file which will create state files local.

To create and configure remote state storage account:

```
#!/bin/bash

RESOURCE_GROUP_NAME=dev-tf-rg
STORAGE_ACCOUNT_NAME=ansibletfstate
CONTAINER_NAME=devansiblestate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
```


To create local state file store, comment the below file

```
Path to the file: ./backend.tf

$ cat backend.tf

terraform {
  backend "azurerm" {}
}

```

## Final execution step

- Run the terraform init command to initialize Terraform:

```
Prems-MacBook-Pro-2:azure-terraform-ansible premkumarpalanichamy$ terraform init -backend-config=./backend/backend-dev.tfvars 

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/local from the dependency lock file
- Reusing previous version of hashicorp/tls from the dependency lock file
- Using previously-installed hashicorp/local v2.1.0
- Using previously-installed hashicorp/tls v3.1.0
- Using previously-installed hashicorp/azurerm v2.81.0
- Using previously-installed hashicorp/random v3.1.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Prems-MacBook-Pro-2:azure-terraform-ansible premkumarpalanichamy$ 
```

- Run terraform plan and create a plan. Create the Terraform plan by executing terraform plan (-out out.plan):

```
Prems-MacBook-Pro-2:azure-terraform-ansible premkumarpalanichamy$ terraform plan -input=false -var-file=./tfvars/dev.tfvars
random_password.password: Refreshing state... [id=none]
tls_private_key.sshkey: Refreshing state... [id=76c3575ace129602aeec54fb2ea4b8e29252280e]
local_file.private_key: Refreshing state... [id=e2f1709dd086f6124754b7d33042640a6c2633b9]
azurerm_resource_group.rg: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg]
azurerm_public_ip.server_pip: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/publicIPAddresses/dev-ansible-server-pip]
azurerm_network_security_group.nsg: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/networkSecurityGroups/dev-ansible-nsg]
azurerm_public_ip.worker_pip[0]: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/publicIPAddresses/dev-ansible-workers-pip-0]
azurerm_virtual_network.vnet: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/virtualNetworks/dev-ansible-vnet]
azurerm_key_vault.kv: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.KeyVault/vaults/devansibledevopscafekv]
azurerm_public_ip.worker_pip[1]: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/publicIPAddresses/dev-ansible-workers-pip-1]
local_file.inventory: Refreshing state... [id=c157788bfa40152843798cc828a812219cf8c396]
local_file.host_script: Refreshing state... [id=05b0ce0fc758e46946833e3ec629e958d3d3a99c]
azurerm_subnet.subnet: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/virtualNetworks/dev-ansible-vnet/subnets/dev-ansible-subnet]
azurerm_network_security_rule.rules_inbound: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/networkSecurityGroups/dev-ansible-nsg/securityRules/dev-ansible-nsg-rule]
azurerm_subnet_network_security_group_association.nsg_subnet: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/virtualNetworks/dev-ansible-vnet/subnets/dev-ansible-subnet]
azurerm_network_interface.server_nic: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/networkInterfaces/dev-ansible-server-nic]
azurerm_network_interface.worker_nic[0]: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/networkInterfaces/dev-ansible-worker-nic-0]
azurerm_network_interface.worker_nic[1]: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Network/networkInterfaces/dev-ansible-worker-nic-1]
azurerm_linux_virtual_machine.ansible_workers[1]: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Compute/virtualMachines/dev-ansible-workers-1]
azurerm_linux_virtual_machine.ansible_workers[0]: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Compute/virtualMachines/dev-ansible-workers-0]
azurerm_key_vault_secret.secret: Refreshing state... [id=https://devansibledevopscafekv.vault.azure.net/secrets/dev-ansible-secret/2fc01c12d1db48bfb69d893554aa3267]
azurerm_linux_virtual_machine.ansible_server: Refreshing state... [id=/subscriptions/470b3d0c-da4e-486b-8c01-fc547833eb79/resourceGroups/dev-ansible-rg/providers/Microsoft.Compute/virtualMachines/dev-ansible-server]
```

- To create use terraform apply based on the plan:

```
terraform apply out.plan
azurerm_resource_group.ansible: Creating...
azurerm_resource_group.ansible: Creation complete after 1s [id=/subscriptions/********-****-****-****-************/resourceGroups/ansible-rg]
azurerm_virtual_network.ansible: Creating...
azurerm_virtual_network.ansible: Still creating... [10s elapsed]
azurerm_virtual_network.ansible: Creation complete after 15s [id=/subscriptions/********-****-****-****-************/resourceGroups/ansible-rg/providers/Microsoft.Network/virtualNetworks/ansible-network]
azurerm_subnet.ansible: Creating...
```

- Login into the console to cross verify the provisioned resources.

#### Clean up ####

Once the lab is done and to avoid extra cost, try to clean up the env.

- Run terraform destroy to clean the environment.

```
Prems-MacBook-Pro-2:azure-terraform-ansible premkumarpalanichamy$ terraform destroy -var-file=./tfvars/dev.tfvars --auto-approve

tls_private_key.sshkey: Refreshing state... [id=76c3575ace129602aeec54fb2ea4b8e29252280e]
random_password.password: Refreshing state... [id=none]
local_file.private_key: Refreshing state... [id=e2f1709dd086f6124754b7d33042640a6c2633b9]
```


## <font color = "red"> Follow-Me </font>

[![Portfolio](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/premkumar-palanichamy)

<p align="left">
<a href="https://linkedin.com/in/premkumarpalanichamy" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="premkumarpalanichamy" height="25" width="25" /></a>
</p>

[![youtube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCJKEn6HeAxRNirDMBwFfi3w)

