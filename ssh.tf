###################################################
# Azure local file - ansible ssh add
###################################################

resource "local_file" "host_script" {
    filename = "./add_host.sh"

    content = <<-EOF
    echo "Setting SSH Key"
    echo "${tls_private_key.sshkey.private_key_pem}"
    ssh-add ${tls_private_key.sshkey.public_key_pem}
    echo "Adding IPs"

    ssh-keyscan -H ${azurerm_public_ip.worker_pip[0].ip_address} >> ~/.ssh/known_hosts
    ssh-keyscan -H ${azurerm_public_ip.worker_pip[1].ip_address} >> ~/.ssh/known_hosts

    EOF

}