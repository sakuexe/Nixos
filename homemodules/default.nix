{ config, lib, ... }:
{
  imports = [
    ./wallpaper.nix
    ./dotfiles.nix
    ./entertainment.nix
  ];

  dotfiles.enable = lib.mkDefault true;
  wallpaper.enable = lib.mkDefault true;
  entertainment.enable = lib.mkDefault true;
}
