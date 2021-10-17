#!/bin/sh

### Adding ansible user as sudoers
#echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sysops

### Package Update
sudo apt-get update
sudo apt-get upgrade -y

### Install dependencies
sudo apt install -y software-properties-common

### Update repository
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get update -y

### Python - pip install
sudo apt-get install python3-pip -y
sudo apt-get install ansible -y

### Check the ansible version
ansible --version