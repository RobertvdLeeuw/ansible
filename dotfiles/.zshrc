# ZSH configuration migrated from NixOS

# Load encrypted environment variables
if [ -f ~/ansible/.env ]; then
    # Check if sops is available
    if command -v sops &> /dev/null; then
        # Decrypt and source .env
        eval "$(sops -d ~/ansible/.env 2>/dev/null | grep -v '^#' | grep -v '^$' | sed 's/^/export /')"
    fi
fi

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Vi mode
bindkey -v

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

# Initialize zoxide
eval "$(zoxide init --cmd cd zsh)"

# Initialize fzf
eval "$(fzf --zsh)"

# Completion system
autoload -U compinit
zmodload zsh/complist
compinit
_comp_options+=(globdots)  # Include hidden files

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={a-zA-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Key bindings
bindkey '^I'   complete-word       # tab
bindkey '^[[Z' forward-word        # shift + tab
bindkey '^[^I' autosuggest-accept  # alt + tab

# Clear terminal function
clear-terminal() { tput reset; zle redisplay; }
zle -N clear-terminal
bindkey '^[l' clear-terminal
bindkey -M viins '^[l' clear-terminal

# History search
bindkey '^[k' history-search-backward
bindkey '^[j' history-search-forward
bindkey -M viins '^[k' history-search-backward
bindkey -M viins '^[j' history-search-forward

# Initialize direnv
eval "$(direnv hook zsh)"

# Load zsh plugins
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

# Initialize starship prompt
eval "$(starship init zsh)"

