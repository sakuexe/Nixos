# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  userSettings,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../desktop.nix
  ];

  # custom nixos modules
  keyboard.enable = false;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;

  # Guest Agent - Paravirtualization
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Define custom groups
  users.groups.makapakas = { };
  users.groups.makapakas.members = [ userSettings.username ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    git
    fastfetch
    tmux
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
