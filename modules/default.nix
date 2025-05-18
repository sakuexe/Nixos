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
    ./docker.nix
    ./virtualization.nix
    ./hyprland.nix
    ./manpages.nix
  ];

  # default nix modules
  shell.enable = lib.mkDefault true;
  manpages.enable = lib.mkDefault true;
  keyboard.enable = lib.mkDefault true;

  # not on by default
  nvidia.enable = lib.mkDefault false;
  gaming.enable = lib.mkDefault false;
  docker.enable = lib.mkDefault false;
  virtualization.enable = lib.mkDefault false;
  hyprland.enable = lib.mkDefault false;
}
