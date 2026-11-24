{ pkgs, ... }:
{
  imports = [
    ../../homemodules
  ];

  wallpaper.ultrawide = true;
  wallpaper.iconScale = 1.0;
  wallpaper.backgroundImage = ../../assets/floating-cubes.jpg;
  wallpaper.backgroundImageOpacity = 0.5;
  videoproduction.enable = true;

  home.packages = with pkgs; [
    easyeffects # input audio mixer
  ];
}
