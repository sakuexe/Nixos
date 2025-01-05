{ ... }:
{
  imports = [
    ../../homemodules
  ];

  wallpaper.ultrawide = true;
  wallpaper.iconScale = 1.0; # does not work yet, the icon is not centered
  wallpaper.backgroundImage = ../../assets/floating-cubes.jpg;
  wallpaper.backgroundImageOpacity = 0.5;
  videoproduction.enable = true;
}
