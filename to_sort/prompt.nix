{ config, pkgs, inputs, ... }:

{
  programs.starship = {
    enable = true;

    settings = {
      format = "┌$username$directory$git_branch$nix_shell$shell\n$character";
      line_break = true;
      add_newline = false;

      character = {
        success_symbol = "└─";
        error_symbol = "└─";
      };

      username = {
        style_user = "bold green"; 
        style_root = "bold red";
        format = "──\\[[$user]($style)\\]";
        show_always = false;
        disabled = false;
      };

      directory = {
        format = "──\\[[$path](bold purple)\\]";
        truncation_length = 4;
        truncate_to_repo = false;
        truncation_symbol = "…/";
      };

      git_branch = {
        format = "──\\[[$branch](bold cyan)\\]";
      };

      nix_shell = {
        format = "──\\[[nix](bold green)\\]";
      };

      shell = {
        bash_indicator = "──\\[[bash](bold yellow)\\]";
        zsh_indicator = "";
        disabled = false;
        format = "$indicator";
      };
    };
  };
}
