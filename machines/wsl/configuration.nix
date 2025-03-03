# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, pkgs, userSettings, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = userSettings.username;
  wsl.wslConf.network.hostname = "wsl";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${userSettings.username}" = {
    isNormalUser = true;
    description = userSettings.description;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };
  users.groups.ringtails = {};
  users.groups.ringtails.members = [ userSettings.username ];
  
  # Install neovim and use it as the default editor
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    fastfetch
    tmux
  ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Nix garbage collection - keep 10 generations
  # https://nix.dev/manual/nix/2.18/command-ref/nix-env/delete-generations#generations-time
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than +10";


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
