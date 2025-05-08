{ lib, pkgs, ... }:

{
  # enable hyprland
  programs.hyprland.enable = lib.mkDefault true;

  # related packages
  environment.systemPackages = with pkgs; [
    kitty
  ];

  # hint electron apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
