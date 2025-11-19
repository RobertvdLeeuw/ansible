
{ config, pkgs, ... }:
{
  environment = {
    pathsToLink = [ "/share/zsh" ];
    systemPackages = with pkgs; [
      rustc
      cargo

      #  TODO: Cargo2Nix
    ];
  };
}
