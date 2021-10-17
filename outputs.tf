### Output ###

output "pip" {
  description = "The public ip of the ansible server"
  value       = azurerm_public_ip.server_pip.ip_address
}

output "pub_key" {
  description = "The rsa pub key of the ansible server"
  value       = tls_private_key.sshkey.public_key_pem
}

output "pvt_key" {
  description = "The rsa pvt key of the ansible server"
  value       = tls_private_key.sshkey.private_key_pem
  sensitive = true
}

output "rg" {
  description = "The rg name of the setup"
  value       = azurerm_resource_group.rg.name
}