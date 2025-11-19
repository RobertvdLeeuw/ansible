{ config, pkgs, ... }:
{
  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        # rebuild = "sudo nixos-rebuild build --use-remote-sudo --impure && clear";
        update = "sudo nixos-rebuild switch --use-remote-sudo --impure && clear";
        cnfnix = "cd /etc/nixos && nvim configuration.nix && cd -";
        cnfnixr = "cd /etc/nixos && nvim README.md && cd -";
        try = "nix-shell -p";

        todo = "nvim ~/Documents/todo.md";
        books = "nvim ~/Documents/books.txt";

        tr = "tree --gitignore -L 3";

        ga = "git add . && clear";
        gs = "git status";
        gc = "git commit -m ";
        gp = "git push && clear";
      };
      shellGlobalAliases = {
        # man = "wikiman";
        cat = "bat";
        nano = "nvim";
        surf = "GDK_BACKEND=x11 surf";  # TODO: Better fix for this, surf + xwayland = :()
      };
      
      initContent = ''
        eval "$(zoxide init --cmd cd zsh)"
        eval "$(fzf --zsh)"
        
        autoload -U compinit
        zmodload zsh/complist
        compinit
        _comp_options+=(globdots)             # Include hidden files.

        zstyle ':completion:*' matcher-list 'm:{a-z}={a-zA-Z}'
        zstyle ':completion:*' list-colors '{(s.:.)LS_COLORS}'
        zstyle ':completion:*' menu no

        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

        bindkey '^I'   complete-word       # tab
        bindkey '^[[Z' forward-word  # shift + tab
        bindkey '^[^I' autosuggest-accept  # shift + tab

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

        eval "$(direnv hook zsh)"

        export NIXPKGS_ALLOW_UNFREE=1
      '';

      
      defaultKeymap = "viins";
      
      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        extended = true;
        share = true;
      };
    
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
          "regexp"
        ];
      };
      
      autosuggestion = {
        enable = true;
        # highlight = "fg=8"; 
      };
    };
    
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      config = {};
      silent = true;

      nix-direnv.enable = true;
    };
  };
}
