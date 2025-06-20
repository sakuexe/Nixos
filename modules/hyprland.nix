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
      playerctl # cli audio controls
    ];

    environment.sessionVariables = {
      # hint electron apps to use Wayland
      NIXOS_OZONE_WL = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    # enable screensharing
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    };

    services.displayManager.defaultSession = lib.mkForce "hyprland";
  };
}
