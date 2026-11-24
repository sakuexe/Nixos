# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  lib,
  userSettings,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules
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
  # enable tmpfs (ram based) to be mounted to /tmp
  # nixos rebuilds use a lot of /tmp, so machines with small amounts of RAM can run into OOM errors
  # boot.tmp.tmpfsSize = 50%; # by default
  boot.tmp.useTmpfs = true;

  networking.hostName = "ringtail";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  # Fonts
  # https://nixos.wiki/wiki/Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Fira Code NF" ];
  };

  # KDE Plasma 6 (wayland only, no X server)
  services.displayManager.sddm.enable = lib.mkDefault true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = lib.mkDefault true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # disable hsp/hfp and a2dp mode switching (automatically using headset microphone)
  # https://wiki.nixos.org/wiki/PipeWire
  services.pipewire.wireplumber.extraConfig."11-bluetooth-policy" = {
    "wireplumber.settings" = {
      "bluetooth.autoswitch-to-headset-profile" = false;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${userSettings.username}" = {
    isNormalUser = true;
    description = userSettings.description;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # Define custom groups
  users.groups.ringtails = { };
  users.groups.ringtails.members = [ userSettings.username ];

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = userSettings.username;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;
  # enable Qt (kde) file picker in firefox instead of the GTK (gnome) one
  programs.firefox.preferences = {
    "widget.use-xdg-desktop-portal.file-picker" = 1;
    "widget.use-xdg-desktop-portal.mime-handler" = 1;
  };

  # system-wide neovim as $EDITOR, so root (sudo, systemctl edit) gets it too.
  # the user's configured neovim comes from home-manager (homemodules/dotfiles.nix)
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # share clipboard and other data between devices on the same network
  programs.kdeconnect.enable = true;

  # snapper
  # https://git.eisfunke.com/config/nixos/-/blob/fdb9668693f270ca6c32d2ed95b19111f31dc134/nixos/snapshots.nix
  services.snapper.snapshotInterval = "hourly";
  services.snapper.cleanupInterval = "1d";
  # create the .snapshot subvolumes (snapper doesn't do this automatically)
  # https://www.mankier.com/5/tmpfiles.d
  systemd.tmpfiles.rules = [
    "v /home/.snapshots 0700 root root -"
  ];
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    # how many snapshots will be kept
    TIMELINE_LIMIT_HOURLY = "10";
    TIMELINE_LIMIT_DAILY = "7";
    TIMELINE_LIMIT_WEEKLY = "2";
    TIMELINE_LIMIT_MONTHLY = "0";
    TIMELINE_LIMIT_YEARLY = "0";
    BACKGROUND_COMPARISON = "yes";
    NUMBER_CLEANUP = "no";
    NUMBER_MIN_AGE = "1800";
    NUMBER_LIMIT = "50";
    NUMBER_LIMIT_IMPORTANT = "10";
    EMPTY_PRE_POST_CLEANUP = "yes";
    EMPTY_PRE_POST_MIN_AGE = "1800";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fastfetch
    tmux
    vscode
    blender
    wineWow64Packages.stable
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Nix garbage collection - every day remove files older than 30 days
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 30d";
  nix.settings.auto-optimise-store = true;

  # 512 MiB
  nix.settings.download-buffer-size = 512 * 1024 * 1024;

  # Allows to run dynamically linked binaries
  programs.nix-ld.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
