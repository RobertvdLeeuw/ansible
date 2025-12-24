#!/bin/bash
set -e

echo "========================================="
echo "Debian Workstation Setup with Ansible"
echo "========================================="
echo ""

# Install Ansible and Git
echo "Installing Ansible and Git..."
sudo apt-get update
sudo apt-get install -y ansible git

sudo ansible-pull -U https://github.com/RobertVDLeeuw/ansible.git | tee ~/ansible-pull.log
# TODO: ansible-pull -d {opt arg where to clone repo to}
