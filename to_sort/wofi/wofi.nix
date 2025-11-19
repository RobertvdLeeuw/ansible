{ config, pkgs, inputs, ... }:
{
  programs.wofi = {
    enable = true;

    settings = { layer = "overlay";};
    style = builtins.readFile ./style.css;
  };
}
