{ lib, pkgs, ... }:

{
  # create a seperate boot menu entry for hyprland
  # so that it does not 
  specialisation.hyprland.configuration = {
    # optional: change the GRUB/systemd-boot name
    system.nixos.tags = [ "hyprland" ];
    system.nixos.label = "NixOS:Hyprland";

    # enable hyprland
    programs.hyprland.enable = true;
    services.blueman.enable = true;

    # disable the KDE Plasma things.
    services.desktopManager.plasma6.enable = lib.mkForce false;
    # services.displayManager.sddm.enable = lib.mkOverride true;

    # related packages
    environment.systemPackages = with pkgs; [
      waybar # statusbar
      rofi-wayland # launcher
      hyprpaper # wallpaper
      kdePackages.dolphin
    ];

    # hint electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # enable screensharing
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    };
  };
}
