# NixOS to Debian Ansible Migration TODO

This document provides step-by-step instructions for an AI agent to automate the migration from NixOS to Debian using Ansible. The goal is to create a complete Ansible setup (not apply it to the machine).

## Input Sources
- `to_sort/` folder containing old NixOS configurations
- `migration_doc.md` containing migration requirements and software lists
- Existing `setup.sh` script (needs to be enhanced)

## Target Structure

Create the following directory structure:
```
ansible/
├── playbook.yml              # Main playbook
├── setup.sh                  # Enhanced setup script
├── group_vars/
│   └── all.yml               # Software categories and dotfile mappings
├── tasks/
│   ├── foundation.yml
│   ├── terminal.yml
│   ├── development.yml
│   ├── desktop.yml
│   ├── gaming.yml
│   ├── uncategorized.yml
│   └── dotfiles.yml
└── dotfiles/
    ├── .bashrc               # Root-level dotfiles (symlink to ~/)
    ├── .gitconfig
    └── config/               # Config directory files (symlink to ~/.config/)
        ├── sway/
        ├── alacritty/
        └── nvim/
```

## Step 1: Analyze NixOS Configurations

Parse the NixOS configs in `to_sort/` to extract:

1. **Installed packages**: Look for:
   - `environment.systemPackages = with pkgs; [...]`
   - `home.packages = with pkgs; [...]` 
   - Any other package declarations

2. **Services enabled**: Look for:
   - `services.* = { enable = true; ... }`
   - These may need manual handling in Debian

3. **Configuration files**: Look for:
   - `home.file.*` declarations
   - `xdg.configFile.*` declarations
   - Any file management

4. **Custom configurations**: Look for:
   - Window manager configs (sway, etc.)
   - Shell configurations
   - Development tool configs

## Step 2: Categorize Software

Using the extracted package list and the migration document, categorize software into:

### foundation
- Package managers: flatpak, snapd
- Core system utilities needed for other package managers
- Repository management tools
- DO NOT include things that go in setup.sh (git, ansible, basic apt tools)

### terminal
- Terminal emulators
- Shell utilities (zoxide, bat, fd-find, dust, etc.)
- Command-line productivity tools
- Text editors (vim, nano)

### development  
- Programming languages and runtimes
- Development tools (docker, git tools beyond basic git)
- IDEs and editors
- Package managers for languages (pip, npm, cargo)
- Development utilities

### desktop
- GUI applications
- Desktop environment components
- Media players
- Communication apps (non-gaming)
- Productivity applications

### gaming
- Games and game platforms (Steam, etc.)
- Gaming utilities
- Game development tools

### uncategorized
- Software that doesn't fit clearly in other categories
- Things to be sorted later

## Step 3: Determine Package Sources

For each piece of software, determine the best installation method:

### Priority Order:
1. **apt**: Official Debian packages (preferred for system tools)
2. **flatpak**: Cross-distro packages (good for desktop apps)
3. **snap**: Canonical packages (use sparingly)
4. **pip**: Python packages
5. **cargo**: Rust packages  
6. **npm**: Node packages
7. **manual**: Custom installation required

### Package Source Research:
- Check `apt search <package>` equivalents
- Verify flatpak availability on flathub
- Note any packages that need manual installation
- Document any packages that don't have Debian equivalents

## Step 4: Create group_vars/all.yml

Use this exact format (Approach 2 from discussion):

```yaml
software_categories:
  foundation:
    packages:
      apt:
        - flatpak
        - snapd
        # Add other foundation packages here
    dotfiles: []
    
  terminal:
    packages:
      apt:
        - alacritty  # example
        - zoxide
      cargo:
        - du-dust
    dotfiles:
      - { src: "config/alacritty", dest: ".config/alacritty" }
      - { src: ".bashrc", dest: ".bashrc" }
      
  development:
    packages:
      apt:
        - docker.io
        - python3-pip
      pip:
        - uv
    dotfiles:
      - { src: "config/nvim", dest: ".config/nvim" }
      - { src: ".gitconfig", dest: ".gitconfig" }
      
  desktop:
    packages:
      flatpak:
        - com.spotify.Client
      apt:
        - dolphin
    dotfiles:
      - { src: "config/sway", dest: ".config/sway" }
      
  gaming:
    packages:
      apt:
        - steam
      flatpak:
        - org.prismlauncher.PrismLauncher
    dotfiles: []
    
  uncategorized:
    packages:
      apt: []
      flatpak: []
      snap: []
    dotfiles: []
```

## Step 5: Create Task Files

### Template for each task file (foundation.yml, terminal.yml, etc.):

```yaml
---
- name: "Install {{ category }} packages via apt"
  apt:
    name: "{{ software_categories[category].packages.apt | default([]) }}"
    state: present
    update_cache: yes
  when: software_categories[category].packages.apt is defined and (software_categories[category].packages.apt | length > 0)
  become: yes

- name: "Install {{ category }} packages via flatpak"
  flatpak:
    name: "{{ item }}"
    state: present
  loop: "{{ software_categories[category].packages.flatpak | default([]) }}"
  when: software_categories[category].packages.flatpak is defined

- name: "Install {{ category }} packages via snap"
  snap:
    name: "{{ item }}"
    state: present
  loop: "{{ software_categories[category].packages.snap | default([]) }}"
  when: software_categories[category].packages.snap is defined

- name: "Install {{ category }} packages via pip"
  pip:
    name: "{{ item }}"
    state: present
  loop: "{{ software_categories[category].packages.pip | default([]) }}"
  when: software_categories[category].packages.pip is defined
  become: yes

- name: "Install {{ category }} packages via cargo"
  shell: cargo install {{ item }}
  loop: "{{ software_categories[category].packages.cargo | default([]) }}"
  when: software_categories[category].packages.cargo is defined
  become: no

- name: "Install {{ category }} packages via npm"
  npm:
    name: "{{ item }}"
    global: yes
  loop: "{{ software_categories[category].packages.npm | default([]) }}"
  when: software_categories[category].packages.npm is defined
  become: yes
```

### Special handling needed:
- **foundation.yml**: Add flatpak repository setup
- **development.yml**: May need additional setup for docker, etc.
- **desktop.yml**: May need theme/icon installations

## Step 6: Create dotfiles.yml

```yaml
---
- name: "Create config directories"
  file:
    path: "{{ ansible_env.HOME }}/{{ item.dest | dirname }}"
    state: directory
  loop: "{{ all_dotfiles }}"
  when: (item.dest | dirname) != ""
  become: no
  vars:
    all_dotfiles: "{{ software_categories.values() | map(attribute='dotfiles') | flatten }}"

- name: "Symlink dotfiles"
  file:
    src: "{{ ansible_env.PWD }}/dotfiles/{{ item.src }}"
    dest: "{{ ansible_env.HOME }}/{{ item.dest }}"
    state: link
    force: yes
  loop: "{{ all_dotfiles }}"
  become: no
  vars:
    all_dotfiles: "{{ software_categories.values() | map(attribute='dotfiles') | flatten }}"
```

## Step 7: Create Main playbook.yml

```yaml
---
- name: "Configure Debian Workstation"
  hosts: localhost
  connection: local
  
  vars:
    username: "{{ ansible_env.USER }}"
    home_dir: "{{ ansible_env.HOME }}"
    
  tasks:
    - name: "Load software categories"
      include_vars: group_vars/all.yml
      
    - name: "Foundation setup"
      include_tasks: tasks/foundation.yml
      vars:
        category: foundation
      tags: [foundation]
      
    - name: "Terminal tools"
      include_tasks: tasks/terminal.yml
      vars:
        category: terminal
      tags: [terminal]
      
    - name: "Development environment"
      include_tasks: tasks/development.yml
      vars:
        category: development
      tags: [development]
      
    - name: "Desktop applications"
      include_tasks: tasks/desktop.yml
      vars:
        category: desktop
      tags: [desktop]
      
    - name: "Gaming software"
      include_tasks: tasks/gaming.yml
      vars:
        category: gaming
      tags: [gaming]
      
    - name: "Uncategorized software"
      include_tasks: tasks/uncategorized.yml
      vars:
        category: uncategorized
      tags: [uncategorized]
      
    - name: "Configure dotfiles"
      include_tasks: tasks/dotfiles.yml
      tags: [dotfiles]
```

## Step 8: Enhance setup.sh

Expand the existing setup.sh script to include:

```bash
#!/bin/bash
set -e

echo "Setting up Debian workstation with Ansible..."

# Install Ansible
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible git

# Set up SSH key if needed
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "SSH key not found. Please set up your SSH key manually:"
    echo "1. ssh-keygen -t rsa -b 4096 -C 'your_email@example.com'"
    echo "2. Add the public key to your GitHub account"
    echo "3. Re-run this script"
    exit 1
fi

# Clone the repository
if [ ! -d "ansible" ]; then
    echo "Cloning ansible repository..."
    git clone git@github.com:RobertVDLeeuw/ansible.git
else
    echo "Ansible repository already exists, pulling latest changes..."
    cd ansible && git pull && cd ..
fi

cd ansible

# Run foundation setup first
echo "Running foundation setup..."
ansible-playbook playbook.yml --tags foundation -K

echo "Setup complete! You can now run:"
echo "  ansible-playbook playbook.yml --tags terminal,development,desktop,gaming"
echo "  ansible-playbook playbook.yml  # For everything"
```

## Step 9: Migrate Configuration Files

For each configuration file found in the NixOS configs:

1. **Extract the content**: Get the actual config file content
2. **Determine destination**: Map NixOS paths to standard Linux paths
3. **Place in dotfiles/**: Put in appropriate location in dotfiles/ directory
4. **Add to dotfiles mapping**: Add entry in the appropriate category in group_vars/all.yml

Common mappings:
- NixOS `home.file.".bashrc"` → `dotfiles/.bashrc` → `~/.bashrc`  
- NixOS `xdg.configFile."sway/config"` → `dotfiles/config/sway/config` → `~/.config/sway/config`

## Step 10: Validation and Documentation

Create documentation for:

1. **Package mappings**: Document any NixOS → Debian package name changes
2. **Missing software**: Note any software without Debian equivalents
3. **Manual steps**: Document anything that can't be automated
4. **Usage instructions**: How to run the playbook selectively

## Expected Output

When complete, the repository should allow:

```bash
# Initial setup
curl -sSL https://raw.githubusercontent.com/RobertVDLeeuw/ansible/main/setup.sh | bash

# Selective installation
cd ansible
ansible-playbook playbook.yml --tags terminal,development  # Just specific categories
ansible-playbook playbook.yml --tags desktop              # Just desktop apps  
ansible-playbook playbook.yml                             # Everything

# Dotfiles only
ansible-playbook playbook.yml --tags dotfiles
```

## Notes for AI Agent

- Prioritize commonly available packages in apt over exotic package managers
- When in doubt about categorization, put items in 'uncategorized' for manual sorting
- Pay attention to dependencies between packages (e.g., some development tools need foundation packages)
- Some NixOS packages may be named differently in Debian - research equivalents
- Configuration files may need slight modifications for different software versions
- Test the generated YAML syntax before finalizing

## Success Criteria

The migration is complete when:
- [ ] All software from NixOS configs is categorized and mapped to Debian equivalents
- [ ] All configuration files are extracted and placed in dotfiles/
- [ ] The Ansible playbook runs without syntax errors  
- [ ] setup.sh successfully installs Ansible and clones the repo
- [ ] Each software category can be installed independently via tags
- [ ] Dotfiles are properly symlinked to their target locations
