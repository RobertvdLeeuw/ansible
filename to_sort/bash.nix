{ config, pkgs, ... }:
{
  programs = {
    bash = {
      shellAliases = {
        rebuild = "nixos-rebuild build --use-remote-sudo && clear";
        update = "nixos-rebuild switch --use-remote-sudo && clear";
        cnfnix = "cd /etc/nixos && nvim configuration.nix && cd -";
        todo = "nvim ~/Documents/todo.md";
        books = "nvim ~/Documents/books.txt";
      };
      
      shellInit = ''
        bindkey '^I'   complete-word       # tab

        clear-terminal() { tput reset; zle redisplay; }
        zle -N clear-terminal
        bindkey '^[l' clear-terminal

        bindkey '^[k' history-search-backward
        bindkey '^[j' history-search-forward
      '';
    };
  };
}
