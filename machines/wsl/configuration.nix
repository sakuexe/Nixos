# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ pkgs, userSettings, ... }:

{
  # the NixOS-WSL module is imported from the flake input (see flake.nix)
  imports = [
    ../../modules
  ];

  # wsl modules
  wsl.enable = true;
  wsl.defaultUser = userSettings.username;
  wsl.wslConf.network.hostname = "wsl";
  networking.resolvconf.enable = false;
  wsl.usbip = {
    enable = true;
    autoAttach = [ "2-1" "3-1" ];  # YubiKey 1050:0407 lands on either bus ID
  };
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", MODE="0660", GROUP="plugdev"
  '';
  boot.kernelModules = [ "vhci_hcd" ];

  # custom nixos modules
  keyboard.enable = false;
  docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${userSettings.username}" = {
    isNormalUser = true;
    description = userSettings.description;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
  users.groups.plugdev.members = [ userSettings.username ];

  # system-wide neovim as $EDITOR, so root (sudo, systemctl edit) gets it too.
  # the user's configured neovim comes from home-manager (homemodules/dotfiles.nix)
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    fastfetch
    tmux
    wget
    kmod
    libfido2 
    yubikey-manager
  ];

  programs.nix-ld.enable = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.ssh.extraConfig = ''
    Host helmiala
      HostName 157.180.122.131
      Port 2001
      User sakuk
      IdentityFile ~/.ssh/id_ed25519_sk_rk
      IdentitiesOnly yes
  '';

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # hard link identical store files, on a timer instead of during every build
  nix.optimise.automatic = true;

  nix.settings.download-buffer-size = 67108864 * 2;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
