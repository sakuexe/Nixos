{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.hyprland = {
    enable = lib.mkEnableOption "Enables Hyprland configuration";
  };

  config = lib.mkIf config.hyprland.enable {
    # hyprland ricing dependencies
    home.packages = with pkgs; [
      waybar # statusbar
      # rofi-wayland # launcher
      fuzzel # launcher (testing for now)
      hyprpaper # wallpaper
      nwg-bar # power menu
      nautilus
      gsettings-qt

      # system controls
      cliphist # clipboard manager
      playerctl # cli audio controls
      pavucontrol

      # screenshot stuff
      grim # take the screenshot
      slurp # capture a region of the screen
      satty # quick editor for the screenshot

      # images
      eog

      # widgets
      eww
    ];

    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;
      colorScheme = "dark";

      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      gtk4.theme = null;

      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };
  };
}
