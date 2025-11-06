{ ... }:
{
  imports = [
    ../../homemodules
  ];

  wallpaper.iconScale = 1.0; # does not work yet, the icon is not centered
  wallpaper.backgroundImage = ../../assets/dark_leaves_wp.jpg;
  wallpaper.backgroundImageOpacity = 0.5;
  videoproduction.enable = true;
  hyprland.enable = true;
  hyprland.scaleFactor = 1.2;
}
