{ lib, pkgs, ... }:

{
  # enable hyprland
  programs.hyprland.enable = lib.mkDefault true;

  # related packages
  environment.systemPackages = with pkgs; [
    waybar # statusbar
    rofi-wayland # launcher
    blueman
  ];

  # hint electron apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # enable screensharing
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
}
