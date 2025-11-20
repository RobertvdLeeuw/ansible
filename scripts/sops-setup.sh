#!/bin/bash
# SOPS Setup Script
# Sets up age encryption and SOPS for managing secrets

set -e

SOPS_AGE_DIR="$HOME/.config/sops/age"
SOPS_AGE_KEY="$SOPS_AGE_DIR/keys.txt"
SOPS_CONFIG=".sops.yaml"

echo "=== SOPS Setup ==="
echo

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "Error: age is not installed"
    echo "Please run the foundation playbook first: ansible-playbook playbook.yml --tags foundation -K"
    exit 1
fi

# Check if sops is installed
if ! command -v sops &> /dev/null; then
    echo "Error: sops is not installed"
    echo "Please run the foundation playbook first: ansible-playbook playbook.yml --tags foundation -K"
    exit 1
fi

# Create age key directory
mkdir -p "$SOPS_AGE_DIR"

# Check if age key already exists
if [ -f "$SOPS_AGE_KEY" ]; then
    echo "Age key already exists at: $SOPS_AGE_KEY"
    echo
    PUBLIC_KEY=$(grep "# public key:" "$SOPS_AGE_KEY" | cut -d: -f2 | tr -d ' ')
else
    echo "Generating new age key..."
    age-keygen -o "$SOPS_AGE_KEY"
    echo
    echo "Age key generated at: $SOPS_AGE_KEY"
    echo
    PUBLIC_KEY=$(grep "# public key:" "$SOPS_AGE_KEY" | cut -d: -f2 | tr -d ' ')
fi

echo "Your age public key is:"
echo "$PUBLIC_KEY"
echo

# Update .sops.yaml with the public key
if [ -f "$SOPS_CONFIG" ]; then
    echo "Updating $SOPS_CONFIG with your public key..."
    sed -i "s/age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/$PUBLIC_KEY/g" "$SOPS_CONFIG"
    echo "✓ $SOPS_CONFIG updated"
else
    echo "Warning: $SOPS_CONFIG not found"
fi

echo
echo "=== Setup Complete ==="
echo
echo "Next steps:"
echo "1. Copy .env.example to .env and fill in your values:"
echo "   cp .env.example .env"
echo
echo "2. Edit .env with your secrets:"
echo "   nano .env"
echo
echo "3. Encrypt .env with SOPS:"
echo "   sops -e -i .env"
echo
echo "4. Commit the encrypted .env file:"
echo "   git add .env .sops.yaml"
echo "   git commit -m 'Add encrypted environment variables'"
echo
echo "5. To edit .env in the future:"
echo "   sops .env"
echo
echo "6. To decrypt .env (for reading):"
echo "   sops -d .env"
echo
echo "IMPORTANT: Keep your age key safe!"
echo "Location: $SOPS_AGE_KEY"
echo "Backup this file securely - you'll need it to decrypt your secrets!"
echo

