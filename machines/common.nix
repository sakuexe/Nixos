# settings shared by every host (imported by mkHost in flake.nix)
# only things that all hosts want go here, desktop only things are in desktop.nix
{
  pkgs,
  userSettings,
  ...
}:

{
  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${userSettings.username}" = {
    isNormalUser = true;
    description = userSettings.description;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # system-wide neovim as $EDITOR, so root (sudo, systemctl edit) gets it too.
  # the user's configured neovim comes from home-manager (homemodules/dotfiles.nix)
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # Allows to run dynamically linked binaries (for example LSPs downloaded by neovim)
  programs.nix-ld.enable = true;

  # traceroute + ping, the module adds the capability wrapper mtr needs
  programs.mtr.enable = true;

  # hard link identical store files, on a timer instead of during every build
  nix.optimise.automatic = true;

  # enable if nixdev still redownloads after nh clean; they keep the build-time closure of all GC roots, system-wide
  # nix.settings.keep-outputs = true;
  # nix.settings.keep-derivations = true;
}
