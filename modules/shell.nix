{
  config,
  lib,
  userSettings,
  ...
}:

let
  # nh does not tell when the new generation needs a reboot to take effect
  rebootCheck = ''
    if [[ "$(readlink /run/booted-system/{initrd,kernel,kernel-modules})" \
      != "$(readlink /run/current-system/{initrd,kernel,kernel-modules})" ]]; \
    then echo "Reboot required"; fi'';
in
{
  options.shell = {
    enable = lib.mkEnableOption "enables the zsh shell and all the tweaks for it";
  };

  config = lib.mkIf config.shell.enable {
    # zsh
    programs.zsh.enable = lib.mkDefault true;

    # plugins
    # completion files from packages are still linked, but compinit
    # itself is left to the dotfiles' .zshrc (avoids running it twice)
    programs.zsh.enableCompletion = lib.mkDefault true;
    programs.zsh.enableGlobalCompInit = lib.mkDefault false;
    programs.zsh.syntaxHighlighting.enable = lib.mkDefault true;
    programs.zsh.autosuggestions.enable = lib.mkDefault true;

    # nh wraps nixos-rebuild, shows the generation diff and replaces nix.gc
    # --impure is passed in the aliases, nh has no env var for it
    programs.nh.enable = true;
    programs.nh.flake = "/home/${userSettings.username}/Nixos";
    # unlike --delete-older-than, this keeps at least 8 generations after a long break
    programs.nh.clean.enable = true;
    programs.nh.clean.extraArgs = "--keep-since 30d --keep 8";

    # aliases
    programs.zsh.shellAliases = {
      # nixos specific aliases
      rebuild = "nh os switch --impure && ${rebootCheck}";
      nixupdate = "nh os switch --impure --update && ${rebootCheck}";
      nixdev = "nix develop --command zsh";
      openport = "sudo nixos-firewall-tool open tcp";

      # reformat the task manager icons, if they cannot be found (KDE Plasma 6)
      # https://discuss.kde.org/t/plasma-6-1-3-pinned-kde-application-icons-go-blank-after-gc-nixos/19444/3
      reficons = ''
        sed -i 's/file:\/\/\/nix\/store\/[^\/]*\/share\/applications\//applications:/gi' \
          ~/.config/plasma-org.kde.plasma.desktop-appletsrc \
          && systemctl restart --user plasma-plasmashell
      '';

      # snapper aliases
      # https://documentation.suse.com/sles/12-SP5/html/SLES-all/cha-snapper.html#proc-snapper-restore-cmdl
      snapperls = "sudo snapper -c home list";
      snapperstatus = "sudo snapper -c home status $(sudo snapper -c home list | awk 'NR>2 {print $1}' | tail -n 1)..0";
    };
  };
}
