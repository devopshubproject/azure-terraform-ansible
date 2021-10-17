##### Global Variable #####

#### Tags ####
variable "owner" {
  type        = string
  description = "The name of the infra provisioner or owner"
  default     = "Prem"
}
variable "environment" {
  type        = string
  description = "The environment name"
}
variable "cost_center" {
  type        = string
  description = "The cost_center name for this project"
  default     = "personal budget"
}
variable "app_name" {
  type        = string
  description = "Application name of project"
  default     = "ansible"
}
variable "location" {
  type        = string
  description = "The Location for Infra centre"
  default     = "West Europe"
}

variable "workers_count" {
  type        = number
  description = "The value for number of workers to get provisioned"
}

### Network ###

### Vnet
variable "vnet_address_spaces" {
  description = "The environment address space CIDR range"
}

## Subnet
variable "subnet_address_spaces" {
  description = "The sbx environment subnet address spaces CIDR range"
}

variable "server_ipconf_name" {
  type        = string
  description = "The nic name for the ansible server resource"
}

variable "worker_ipconf_name" {
  type        = string
  description = "The nic name for the ansible worker resource"
}

### Virtual Machine ###
variable "os_type" {
  type        = string
  description = "Type of OS"
}

variable "publisher" {
  type        = string
  description = "Name of the OS publisher"
}

variable "offer" {
  type        = string
  description = "The Offer Name for the Image"
}

variable "sku" {
  type        = string
  description = "The Name of the SKU for the Image."
}
variable "range" {
  type        = string
  description = "The version for the Image."
}
### VM Details ###
variable "username" {
  type        = string
  description = "The root user name for the compute resource"
}

/* variable "password" {
  type = string
  description = "The root password for the compute resource"
} */