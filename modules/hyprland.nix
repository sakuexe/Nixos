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
    programs.hyprland.withUWSM = true;
    services.blueman.enable = true;

    services.displayManager.defaultSession = lib.mkForce "hyprland-uwsm";

    # hint electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # enable screensharing
    # (programs.hyprland already adds xdg-desktop-portal-hyprland)
    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.common = {
        default = [ "hyprland" "gtk" ];
        # Important for dark mode / prefers-color-scheme
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };

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

    # gvfs provides the udisks2 volume monitor nautilus needs to list/mount drives
    # (normally enabled by the gnome desktop module, which isn't used here)
    services.gvfs.enable = true;
  };
}
