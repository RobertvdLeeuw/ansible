{ config, pkgs, inputs, ... }:  
let 
  base_config = {
    height = 30;
    spacing = 4; # Gaps between modules (4px)
    modules-left = [ "clock" "pulseaudio" "bluetooth" ];
    modules-center = ["custom/workspaces"];
    modules-right = [];
    clock = {
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      format = "󰃰 {:%H:%M  <b>%d %b</b>}";
      tooltip = false;
    };

    pulseaudio = {
      scroll-step = 5; # %; can be a float
      format-muted = "󰓃 󰖁";
      format = "󰓃 {volume}%";
      format-source = "󰓃";
      format-icons = {
        headphone = "󰋋";
        hands-free = "󰓃";
        headset = "󰋋";
        phone = "󰓃";
        portable = "󰓃";
        car = "󰓃";
        default = ["󰕿" "󰖀" "󰕾"];
      };
      on-click = "pavucontrol";
      on-click-right = "pavucontrol";
      tooltip = false;
    };
    bluetooth = {
      format = "󰂯";
      format-off = "󰂲";
      format-connected = "{count} 󰂰";
      tooltip = false;
    };
  };

  screens = map (screen: screen // 
    {"custom/workspaces" = {
      exec = "workspaces ${screen.output}";
      return-type = "json";
      format = "{}";
      tooltip = false;
      escape = false;
    };} // (if screen.bar_id != "3" then {  # Horizontal only
      network = {
        format-wifi = "{essid} ({signalStrength}%) 󰤨 ";
        format-ethernet = " 󰌘 ";
        format-linked = "{ifname} (No IP) 󰤩 ";
        format-disconnected = " 󰌙 ";
        # format-alt = "{ifname}: {ipaddr}/{cidr}";
        tooltip = false;
      };
      "custom/cpu_info" = {
        exec = "resources CPU";
        return-type = "json";
        format = "{}";
        tooltip = false;
        escape = false;
      };
      "custom/gpu_info" = {
        exec = "resources GPU";
        return-type = "json";
        format = "{}";
        tooltip = false;
        escape = false;
      };
      modules-right = [
        "network"
        "custom/cpu_info"
        "custom/gpu_info"
      ];
    } else {  # Vertical only
    })) 
    [
      { bar_id = "1"; ipc = true; output = "DP-1"; }  # UW
      { bar_id = "2"; ipc = true; output = "HDMI-A-1"; }  # Top
      { bar_id = "3"; output = "DP-3"; }  # Ver
    ];

  configs = map (extra: base_config // extra) screens;
in
{
  programs = {
    waybar = {
      enable = true;

      settings = configs;
      style = ./style.css;
    };
    eww = {
      enable = true;
      enableZshIntegration = true;

      configDir = ./modules/eww;
    };
  };

  home.packages = 
    let
      config_dir = "/mnt/storage/nc/Personal/nixos";
      workspaces = (builtins.getFlake "${config_dir}/modules/waybar/modules/workspaces").packages.x86_64-linux.default;
      resources = (builtins.getFlake "${config_dir}/modules/waybar/modules/resources").packages.x86_64-linux.default;
    in [ workspaces resources ];

}
