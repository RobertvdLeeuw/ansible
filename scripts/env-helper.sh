#!/bin/bash
# Environment File Helper
# Manages encrypted .env file with SOPS

set -e

ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 {init|edit|view|encrypt|decrypt|export|reload}"
    echo
    echo "Commands:"
    echo "  init     - Create .env from .env.example"
    echo "  edit     - Edit .env with SOPS (auto-encrypts on save)"
    echo "  view     - View decrypted .env content"
    echo "  encrypt  - Encrypt .env file in place"
    echo "  decrypt  - Decrypt .env file in place (WARNING: leaves unencrypted)"
    echo "  export   - Export .env variables to current shell (eval required)"
    echo "  reload   - Reload shell configuration (sources .zshrc or .bashrc)"
    echo
    echo "Examples:"
    echo "  $0 init              # Create new .env from template"
    echo "  $0 edit              # Edit encrypted .env"
    echo "  $0 view              # View secrets"
    echo "  $0 reload            # Reload shell after editing .env"
    echo "  eval \$($0 export)   # Load secrets into shell"
    exit 1
}

check_sops() {
    # Check for sops in common locations
    if command -v sops &> /dev/null; then
        SOPS_CMD="sops"
    elif [ -f /usr/local/bin/sops ]; then
        SOPS_CMD="/usr/local/bin/sops"
    elif [ -f /usr/bin/sops ]; then
        SOPS_CMD="/usr/bin/sops"
    else
        echo -e "${RED}Error: sops is not installed${NC}"
        echo "Run: ansible-pull -U https://github.com/RobertVDLeeuw/ansible.git --tags foundation -K"
        exit 1
    fi
}

check_age_key() {
    if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
        echo -e "${RED}Error: Age key not found${NC}"
        echo "Run: ./scripts/sops-setup.sh"
        exit 1
    fi
}

cmd_init() {
    if [ -f "$ENV_FILE" ]; then
        echo -e "${YELLOW}Warning: $ENV_FILE already exists${NC}"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted"
            exit 0
        fi
    fi
    
    if [ ! -f "$ENV_EXAMPLE" ]; then
        echo -e "${RED}Error: $ENV_EXAMPLE not found${NC}"
        exit 1
    fi
    
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    echo -e "${GREEN}✓ Created $ENV_FILE from $ENV_EXAMPLE${NC}"
    echo
    echo "Next steps:"
    echo "1. Edit the file: $0 edit"
    echo "2. Fill in your secrets"
    echo "3. Save and close (file will be auto-encrypted)"
}

cmd_edit() {
    check_sops
    check_age_key

    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${YELLOW}$ENV_FILE not found. Creating from template...${NC}"
        cmd_init
    fi

    $SOPS_CMD "$ENV_FILE"
    echo -e "${GREEN}✓ File saved and encrypted${NC}"
    echo -e "${YELLOW}To load changes in current shell, run:${NC}"
    echo -e "  ${CYAN}env-reload${NC}  (or: source ~/.zshrc / source ~/.bashrc)"
}

cmd_view() {
    check_sops
    check_age_key

    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}Error: $ENV_FILE not found${NC}"
        echo "Run: $0 init"
        exit 1
    fi

    $SOPS_CMD -d "$ENV_FILE"
}

cmd_encrypt() {
    check_sops
    check_age_key

    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}Error: $ENV_FILE not found${NC}"
        exit 1
    fi

    # Check if already encrypted
    if grep -q "sops:" "$ENV_FILE" 2>/dev/null; then
        echo -e "${YELLOW}File appears to already be encrypted${NC}"
        exit 0
    fi

    $SOPS_CMD -e -i "$ENV_FILE"
    echo -e "${GREEN}✓ $ENV_FILE encrypted${NC}"
}

cmd_decrypt() {
    check_sops
    check_age_key

    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}Error: $ENV_FILE not found${NC}"
        exit 1
    fi

    echo -e "${YELLOW}WARNING: This will leave $ENV_FILE unencrypted!${NC}"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 0
    fi

    $SOPS_CMD -d -i "$ENV_FILE"
    echo -e "${GREEN}✓ $ENV_FILE decrypted${NC}"
    echo -e "${RED}Remember to re-encrypt before committing!${NC}"
}

cmd_export() {
    check_sops
    check_age_key

    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}Error: $ENV_FILE not found${NC}" >&2
        exit 1
    fi

    # Decrypt and export
    $SOPS_CMD -d "$ENV_FILE" | grep -v '^#' | grep -v '^$' | while IFS= read -r line; do
        echo "export $line"
    done
}

cmd_reload() {
    # Detect current shell
    CURRENT_SHELL=$(basename "$SHELL")

    case "$CURRENT_SHELL" in
        zsh)
            echo -e "${GREEN}Reloading zsh configuration...${NC}"
            exec zsh
            ;;
        bash)
            echo -e "${GREEN}Reloading bash configuration...${NC}"
            exec bash
            ;;
        *)
            echo -e "${YELLOW}Unknown shell: $CURRENT_SHELL${NC}"
            echo "Please manually reload your shell configuration:"
            echo "  source ~/.zshrc   # for zsh"
            echo "  source ~/.bashrc  # for bash"
            ;;
    esac
}

# Main
case "${1:-}" in
    init)
        cmd_init
        ;;
    edit)
        cmd_edit
        ;;
    view)
        cmd_view
        ;;
    encrypt)
        cmd_encrypt
        ;;
    decrypt)
        cmd_decrypt
        ;;
    export)
        cmd_export
        ;;
    reload)
        cmd_reload
        ;;
    *)
        usage
        ;;
esac

