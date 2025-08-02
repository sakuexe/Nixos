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
      nwg-bar # power menu
      kdePackages.dolphin

      # system controls
      cliphist # clipboard manager
      playerctl # cli audio controls
      # mako # notification daemon (for discord to not crash)

      # screenshot stuff
      grim # take the screenshot
      slurp # capture a region of the screen
      satty # quick editor for the screenshot

      # widgets
      eww
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
