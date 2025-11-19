{ config, pkgs, ... }:

{
	programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        # Notification daemon  TODO: Don't I just need 1, not both?
        libnotify
        mako  

        waybar

        pick
        playerctl

        wofi

        # Clipboard
        wl-clipboard
        clipman
        cliphist

        # Screenshots
        grim
        slurp

        # kdePackages.dolphin
      ];
    };
	};
}
