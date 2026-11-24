{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.keyboard = {
    enable = lib.mkEnableOption "enables the Moonlander MK1 related software and required tweaks";
  };

  config = lib.mkIf config.keyboard.enable {
    environment.systemPackages = [ pkgs.keymapp ];

    # udev rules for Oryx web flashing, live training and Keymapp flashing
    # (uses uaccess, so the logged in user gets access without a plugdev group)
    hardware.keyboard.zsa.enable = true;
  };
}
