{ ... }:
{
  imports = [
    ../../homemodules
  ];

  wallpaper.enable = false; # does not work yet, the icon is not centered
  programs.alacritty.enable = false;
  dconf.settings = {};
}
