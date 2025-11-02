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

    xdg.mime.enable = true;
    xdg.mime.defaultApplications = {
      "application/pdf" = "firefox.desktop";
      "image/svg+xml" = "firefox.desktop";
      "image/png" = "org.gnome.eog.desktop";
      "image/jpeg" = "org.gnome.eog.desktop";
      "image/gif" = "org.gnome.eog.desktop";
      # "video/mp4" = "vlc.desktop";
      # "video/mp3" = "vlc.desktop";
      # "video/webm" = "vlc.desktop";
    };


    services.displayManager.defaultSession = lib.mkForce "hyprland";
  };
}
