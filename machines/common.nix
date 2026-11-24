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
}
