# Bash configuration

# Load encrypted environment variables
if [ -f ~/ansible/.env ]; then
    # Check if sops is available
    if command -v sops &> /dev/null; then
        # Decrypt and source .env
        eval "$(sops -d ~/ansible/.env 2>/dev/null | grep -v '^#' | grep -v '^$' | sed 's/^/export /')"
    fi
fi

# History configuration
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Aliases
alias update="sudo apt update && sudo apt upgrade -y && flatpak update -y"
alias todo="nvim ~/Documents/todo.md"
alias books="nvim ~/Documents/books.txt"
alias tr="tree --gitignore -L 3"
alias ga="git add . && clear"
alias gs="git status"
alias gc="git commit -m"
alias gp="git push && clear"

# Global aliases
alias cat="bat"
alias nano="nvim"

# Environment management
alias env-edit="~/ansible/scripts/env-helper.sh edit"
alias env-view="~/ansible/scripts/env-helper.sh view"
alias env-reload="source ~/.bashrc"

# Initialize zoxide if available
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init --cmd cd bash)"
fi

# Initialize fzf if available
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
fi

# Initialize direnv if available
if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

# Initialize starship prompt if available
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

