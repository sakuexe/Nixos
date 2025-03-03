{ ... }:
{
  imports = [
    ../../homemodules
  ];

  wallpaper.enable = false;
  entertainment.enable = false;

  programs.alacritty.enable = false;
  dconf.settings = {};
}
