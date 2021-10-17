###################################################
# Azure local file - ansible inventory
###################################################

resource "local_file" "inventory" {
    filename = "./host.ini"

    content = <<-EOF
    [Webserver]
    ${azurerm_public_ip.worker_pip[0].ip_address}
    ${azurerm_public_ip.worker_pip[1].ip_address}

    EOF

}