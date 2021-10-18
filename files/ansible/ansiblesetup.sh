#!/bin/sh

### Adding ansible user as sudoers
#echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sysops

### Package Update
sudo yum update
sudo yum upgrade -y

### Install dependencies
#sudo yum install epel-release

### Uninstall Python older version
sudo dnf remove python3 -y

### Python - pip install
sudo yum install python3.8 -y
sudo yum install python38-pip -y
pip3 install pip
pip3 install ansible

### Check the ansible version
ansible --version