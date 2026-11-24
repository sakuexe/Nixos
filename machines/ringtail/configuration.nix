# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  userSettings,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../desktop.nix
  ];

  # custom modules
  gaming.enable = true;
  virtualization.enable = true;
  docker.enable = true;
  nvidia.enable = true;
  hyprland.enable = true;
  flatpak.enable = true;
  syncthing.enable = true;

  # Bootloader. (using grub, because it's nice and keeps the generations tidy)
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  # mount /tmp as tmpfs (ram based)
  # note: nix-daemon builds in /tmp, so this *increases* the risk of running out of space
  # on big builds. fine with 64 GB of RAM, but drop it on machines with less
  # boot.tmp.tmpfsSize = 50%; # by default
  boot.tmp.useTmpfs = true;

  # secondary drive (from hardware-configuration.nix), don't fail the boot if it is missing
  fileSystems."/home/sakuk/Storage".options = [ "nofail" ];

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # disable hsp/hfp and a2dp mode switching (automatically using headset microphone)
  # https://wiki.nixos.org/wiki/PipeWire
  services.pipewire.wireplumber.extraConfig."11-bluetooth-policy" = {
    "wireplumber.settings" = {
      "bluetooth.autoswitch-to-headset-profile" = false;
    };
  };

  # Define custom groups
  users.groups.ringtails = { };
  users.groups.ringtails.members = [ userSettings.username ];

  # firefox: enable Qt (kde) file picker in firefox instead of the GTK (gnome) one
  programs.firefox.preferences = {
    "widget.use-xdg-desktop-portal.file-picker" = 1;
    "widget.use-xdg-desktop-portal.mime-handler" = 1;
  };

  # share clipboard and other data between devices on the same network
  programs.kdeconnect.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fastfetch
    tmux
    vscode
    blender
    wineWow64Packages.stable
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # 512 MiB
  nix.settings.download-buffer-size = 512 * 1024 * 1024;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
