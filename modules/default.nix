{
  lib,
  ...
}:
{
  # TODO: update these modules to be structured like the home modules
  # since currently this does not work
  imports = [
    ./nvidia.nix
    ./gaming.nix
    ./shell.nix
    ./keyboard.nix
    ./entertainment.nix
    ./docker.nix
    ./virtualization.nix
    ./hyprland.nix
  ];

  # default nix modules
  shell.enable = lib.mkDefault true;
  keyboard.enable = lib.mkDefault true;

  # not on by default
  nvidia.enable = lib.mkDefault false;
  gaming.enable = lib.mkDefault false;
  entertainment.enable = lib.mkDefault false;
  docker.enable = lib.mkDefault false;
  virtualisation.enable = lib.mkDefault false;
  hyprland.enable = lib.mkDefault false;
}
