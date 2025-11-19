# eval "$(zoxide init --cmd cd zsh)"
# eval "$(fzf --zsh)"

  # Autocomplete
autoload -U compinit
zmodload zsh/complist
compinit
_comp_options+=(globdots)             # Include hidden files.

zstyle ':completion:*' matcher-list 'm:{a-z}={a-zA-Z}'
zstyle ':completion:*' list-colors '{(s.:.)LS_COLORS}'
zstyle ':completion:*' menu no

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

bindkey '^I'   complete-word       # tab
bindkey '^[[Z' autosuggest-accept  # shift + tab

clear-terminal() { tput reset; zle redisplay; }
zle -N clear-terminal
bindkey '^[l' clear-terminal
bindkey -M viins '^[l' clear-terminal


# bindkey '^[[1;5A' history-search-backward
# bindkey '^[[1;5B' history-search-forward

bindkey '^[k' history-search-backward
bindkey '^[j' history-search-forward
bindkey -M viins '^[k' history-search-backward
bindkey -M viins '^[j' history-search-forward

