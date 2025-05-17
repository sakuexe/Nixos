{
  config,
  pkgs,
  lib,
  userSettings,
  ...
}:

{
  options.keyboard = {
    enable = lib.mkEnableOption "enables the Moonlander MK1 related software and required tweaks";
  };

  config = lib.mkIf config.keyboard.enable {
    environment.systemPackages = [ pkgs.keymapp ];

    # create the plugdev group and add the user to it
    users.groups.plugdev.members = [ userSettings.username ];

    # add an udev rule, so that the permissions get set accordingly
    services.udev.extraRules = ''
      # Rules for Oryx web flashing and live training
      KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"
      # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    '';
  };
}
