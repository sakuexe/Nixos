{ ... }:
{
  imports = [
    ../../homemodules
  ];

  wallpaper.enable = false;
  hyprland.enable = false;

  programs.alacritty.enable = false;
  dconf.settings = {};
}
