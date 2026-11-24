# settings shared by the desktop hosts (ringtail, nixos-vm)
# timezone and locale are here on purpose, WSL keeps the defaults
{
  lib,
  pkgs,
  userSettings,
  ...
}:

{
  networking.networkmanager.enable = true;
  users.users."${userSettings.username}".extraGroups = [ "networkmanager" ];

  time.timeZone = lib.mkDefault "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

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

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = lib.mkDefault true;
  services.displayManager.autoLogin.user = userSettings.username;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

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
}
