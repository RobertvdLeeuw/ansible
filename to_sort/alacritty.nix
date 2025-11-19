{ config, pkgs, inputs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      colors = {
        cursor = {
          background = "#ccdbe0";
          foreground = "#0d0f18";
        };
        normal = {
          black = "#282828";
          blue = "#b9aeda";
          cyan = "#aca1cf";
          green = "#90b99f";
          magenta = "#cb6fa1";
          red = "#ca1444";
          white = "#ccdbe0";
          yellow = "#e8a831";
        };
        primary = {
          background = "#0d0d16";
          foreground = "#c9c7cd";
        };

        vi_mode_cursor = {
          background = "#161617";
          foreground = "#c9c7cd";
        };
      };

      font = {
        size = 12;

        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };

        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "BoldItalic";
        };

        glyph_offset = {
          x = 0;
          y = 0;
        };

        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };

        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };

        offset = {
          x = 0;
          y = 0;
        };
      };

      window = {
        opacity = 0.97;

        padding = {
          x = 0;
          y = 0;
        };
      };
    };
  };

  home.packages = with pkgs; [  # TODO: Clean and reorgainze.
    wget
    jq
    which

    neofetch
    bat
    fd
    fzf

    gettext
    tree
    unzip
    zip
    zoxide
    file

    git
    gcc
    ninja
  ];
}
