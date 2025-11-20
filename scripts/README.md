# Scripts

Helper scripts for managing your Debian workstation configuration.

## SOPS and Secrets Management

### sops-setup.sh

Sets up SOPS (Secrets OPerationS) and age encryption for managing secrets.

**Usage:**
```bash
./scripts/sops-setup.sh
```

**What it does:**
1. Checks if age and sops are installed
2. Generates an age encryption key (if not exists)
3. Updates `.sops.yaml` with your public key
4. Provides instructions for encrypting `.env`

**First-time setup:**
```bash
# 1. Run foundation playbook (installs age and sops)
ansible-playbook playbook.yml --tags foundation -K

# 2. Run SOPS setup
./scripts/sops-setup.sh

# 3. Create and encrypt your .env
./scripts/env-helper.sh init
./scripts/env-helper.sh edit
```

### env-helper.sh

Manages your encrypted `.env` file with convenient commands.

**Usage:**
```bash
./scripts/env-helper.sh {init|edit|view|encrypt|decrypt|export|reload}
```

**Commands:**

| Command | Description |
|---------|-------------|
| `init` | Create `.env` from `.env.example` template |
| `edit` | Edit `.env` with SOPS (auto-encrypts on save) |
| `view` | View decrypted `.env` content |
| `encrypt` | Encrypt `.env` file in place |
| `decrypt` | Decrypt `.env` file in place (⚠️ leaves unencrypted) |
| `export` | Export `.env` variables to current shell |
| `reload` | Reload shell configuration (applies .env changes) |

**Shell Aliases:**

When using zsh or bash, these convenient aliases are available:
- `env-edit` → `~/ansible/scripts/env-helper.sh edit`
- `env-view` → `~/ansible/scripts/env-helper.sh view`
- `env-reload` → `source ~/.zshrc` (or `~/.bashrc`)

**Examples:**

```bash
# Create new .env from template
./scripts/env-helper.sh init

# Edit encrypted .env (opens in $EDITOR)
./scripts/env-helper.sh edit
# Or use alias: env-edit

# Reload shell to apply changes
./scripts/env-helper.sh reload
# Or use alias: env-reload

# View secrets without editing
./scripts/env-helper.sh view
# Or use alias: env-view

# Load secrets into current shell (alternative)
eval $(./scripts/env-helper.sh export)

# Verify a variable is loaded
echo $OPENAI_API_KEY
```

## Workflow

### Initial Setup

```bash
# 1. Install foundation packages (includes age and sops)
ansible-playbook playbook.yml --tags foundation -K

# 2. Set up SOPS encryption
./scripts/sops-setup.sh

# 3. Create .env file
./scripts/env-helper.sh init

# 4. Edit and add your secrets
./scripts/env-helper.sh edit
# Fill in your API keys, homelab IPs, etc.
# Save and close - file is automatically encrypted

# 5. Commit encrypted .env
git add .env .sops.yaml
git commit -m "Add encrypted environment variables"
git push
```

### Daily Usage

**Environment variables are automatically loaded when you start a new shell!**

Your `.zshrc` and `.bashrc` automatically decrypt and load `.env` on shell startup.

```bash
# Edit secrets
env-edit  # or: ./scripts/env-helper.sh edit

# Reload shell to apply changes
env-reload  # or: ./scripts/env-helper.sh reload

# View secrets
env-view  # or: ./scripts/env-helper.sh view

# Verify variables are loaded
echo $OPENAI_API_KEY
echo $HOMELAB_IP

# Load into a specific project (if needed)
cd ~/projects/my-app
eval $(~/ansible/scripts/env-helper.sh export)
```

### On a New Machine

```bash
# 1. Clone your ansible repo
git clone git@github.com:YourUsername/ansible.git
cd ansible

# 2. Run setup script
./setup.sh

# 3. Run SOPS setup (generates new age key)
./scripts/sops-setup.sh

# 4. Copy your age key from backup
# Option A: Copy from secure backup
cp /path/to/backup/keys.txt ~/.config/sops/age/keys.txt

# Option B: Or update .sops.yaml with new public key and re-encrypt
# (requires access to decrypted .env from another machine)

# 5. Verify you can decrypt
./scripts/env-helper.sh view
```

## Security Notes

### Age Key Backup

Your age private key is stored at: `~/.config/sops/age/keys.txt`

**⚠️ IMPORTANT:**
- Back up this file securely (password manager, encrypted USB, etc.)
- Without this key, you cannot decrypt your secrets
- Do NOT commit this file to git (it's in `.gitignore`)

**Backup methods:**
```bash
# Copy to encrypted USB
cp ~/.config/sops/age/keys.txt /media/usb/backups/

# Store in password manager as secure note
cat ~/.config/sops/age/keys.txt

# Encrypt with GPG and store
gpg -c ~/.config/sops/age/keys.txt
# Store keys.txt.gpg in cloud storage
```

### .env File

- The `.env` file is encrypted with SOPS before committing
- Only you (with the age key) can decrypt it
- Safe to commit to public or private repos
- Each machine needs the age key to decrypt

### Best Practices

1. **Never commit unencrypted secrets**
   ```bash
   # Always verify .env is encrypted before committing
   head .env
   # Should show SOPS metadata, not plain text
   ```

2. **Use different keys for different contexts**
   - Personal projects: One age key
   - Work projects: Different age key
   - Team projects: Shared age key (distributed securely)

3. **Rotate secrets regularly**
   ```bash
   ./scripts/env-helper.sh edit
   # Update API keys, passwords, etc.
   ```

4. **Keep age key secure**
   - Don't share via email/chat
   - Use secure transfer methods (encrypted USB, password manager)
   - Keep backups in multiple secure locations

## Troubleshooting

### "sops: command not found"

```bash
# Run foundation playbook
ansible-playbook playbook.yml --tags foundation -K
```

### "age: command not found"

```bash
# Install age
sudo apt install age
```

### "Failed to get the data key"

Your age key is missing or incorrect:
```bash
# Check if key exists
ls -la ~/.config/sops/age/keys.txt

# Restore from backup
cp /path/to/backup/keys.txt ~/.config/sops/age/keys.txt
```

### "File appears to already be encrypted"

The file is already encrypted. Use `edit` or `view` instead:
```bash
./scripts/env-helper.sh edit
```

