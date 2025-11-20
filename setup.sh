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

# Make scripts executable
chmod +x scripts/*.sh

# Run foundation setup (includes SOPS and age installation + setup)
echo ""
echo "========================================="
echo "Running foundation setup..."
echo "========================================="
echo "This will install:"
echo "  - Package managers (flatpak, snapd)"
echo "  - SOPS and age for secrets management"
echo "  - Generate encryption keys automatically"
echo ""
ansible-pull -U https://github.com/RobertVDLeeuw/ansible.git --tags foundation -K

echo ""
echo "========================================="
echo "Creating .env file..."
echo "========================================="
if [ ! -f .env ]; then
    if [ -f ~/.config/sops/age/keys.txt ]; then
        echo "Creating .env from template..."
        ./scripts/env-helper.sh init
        echo ""
        echo "✓ .env file created and encrypted"
        echo ""
        echo "IMPORTANT: Edit your .env file with your secrets:"
        echo "  ./scripts/env-helper.sh edit"
        echo "  (or use the 'env-edit' alias)"
        echo ""
        echo "Your age key is at: ~/.config/sops/age/keys.txt"
        echo "BACK UP THIS KEY SECURELY!"
    else
        echo "Warning: Age key not found at ~/.config/sops/age/keys.txt"
        echo "The foundation playbook should have created it."
        echo "You can create it manually by running: ./scripts/sops-setup.sh"
    fi
else
    echo ".env already exists, skipping creation"
fi

echo ""
echo "========================================="
echo "Foundation setup complete!"
echo "========================================="
echo ""
echo "✓ Package managers installed (flatpak, snapd)"
echo "✓ SOPS and age encryption configured"
echo "✓ Age key generated at: ~/.config/sops/age/keys.txt"
if [ -f .env ]; then
    echo "✓ .env file created and encrypted"
fi
echo ""
echo "Next steps:"
echo ""
echo "1. Edit your .env file with your secrets:"
echo "     ./scripts/env-helper.sh edit"
echo "     (or use the 'env-edit' alias after reloading shell)"
echo ""
echo "2. Run full installation:"
echo "     ansible-pull -U https://github.com/RobertVDLeeuw/ansible.git -K"
echo ""
echo "   Or install specific categories:"
echo "     ansible-pull -U https://github.com/RobertVDLeeuw/ansible.git --tags terminal,development,desktop -K"
echo ""
echo "Available tags: foundation, terminal, development, desktop, gaming, dotfiles"
echo ""

