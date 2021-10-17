# General

environment   = "dev"
workers_count = 2

# Network

vnet_address_spaces   = "10.10.0.0/16"
subnet_address_spaces = "10.10.2.0/24"
server_ipconf_name    = "ansible-server-ipconfig"
worker_ipconf_name    = "ansible-worker-ipconfig"

# VM details

publisher = "Canonical"
offer     = "UbuntuServer"
sku       = "19.04"
range     = "latest"
os_type   = "Standard_ds1_v2"
username  = "ansible"