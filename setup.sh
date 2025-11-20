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

# Set up SSH key if needed
if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ed25519 ]; then
    echo ""
    echo "========================================="
    echo "SSH key not found!"
    echo "========================================="
    echo "Please set up your SSH key manually:"
    echo "1. ssh-keygen -t ed25519 -C 'your_email@example.com'"
    echo "2. Add the public key to your GitHub account"
    echo "3. Re-run this script"
    echo ""
    exit 1
fi

# Clone the repository
if [ ! -d "ansible" ]; then
    echo ""
    echo "Cloning ansible repository..."
    git clone git@github.com:RobertVDLeeuw/ansible.git
else
    echo ""
    echo "Ansible repository already exists, pulling latest changes..."
    cd ansible && git pull && cd ..
fi

cd ansible

# Run foundation setup first
echo ""
echo "========================================="
echo "Running foundation setup..."
echo "========================================="
ansible-pull -U https://github.com/RobertVDLeeuw/ansible.git --tags foundation -K

# Set up SOPS and .env
echo ""
echo "========================================="
echo "Setting up SOPS encryption..."
echo "========================================="
./scripts/sops-setup.sh

echo ""
echo "========================================="
echo "Creating .env file..."
echo "========================================="
if [ ! -f .env ]; then
    echo "Creating .env from template..."
    ./scripts/env-helper.sh init
    echo ""
    echo "IMPORTANT: Edit your .env file with your secrets:"
    echo "  ./scripts/env-helper.sh edit"
    echo ""
    echo "The .env file will be automatically encrypted when you save."
    echo "Your age key is at: ~/.config/sops/age/keys.txt"
    echo "BACK UP THIS KEY SECURELY!"
else
    echo ".env already exists, skipping creation"
fi

echo ""
echo "========================================="
echo "Foundation setup complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Edit your .env file:"
echo "     ./scripts/env-helper.sh edit"
echo ""
echo "2. Run full installation:"
echo "     ansible-pull -U https://github.com/RobertVDLeeuw/ansible.git -K"
echo ""
echo "Or install specific categories:"
echo "     ansible-pull -U https://github.com/RobertVDLeeuw/ansible.git --tags terminal,development,desktop -K"
echo ""

