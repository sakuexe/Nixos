{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.hyprland = {
    enable = lib.mkEnableOption "enables hyprland and the hyprland specific programs";
  };

  config = lib.mkIf config.hyprland.enable {
    # enable hyprland
    programs.hyprland.enable = true;
    services.blueman.enable = true;

    # related packages
    environment.systemPackages = with pkgs; [
      waybar # statusbar
      # rofi-wayland # launcher
      fuzzel # launcher (testing for now)
      hyprpaper # wallpaper
      cliphist # clipboard manager
      nwg-bar # power menu
      kdePackages.dolphin
    ];

    # hint electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # enable screensharing
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    };

    services.displayManager.defaultSession = lib.mkForce "hyprland";
  };
}
