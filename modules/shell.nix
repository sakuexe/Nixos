{
  config,
  lib,
  pkgs,
  ...
}:

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

    environment.systemPackages = with pkgs; [
      nvd # nix cli tools
    ];

    # aliases
    programs.zsh.shellAliases = {
      # nixos specific aliases
      rebuild = ''
        sudo nixos-rebuild --impure switch \
          --flake ~/Nixos\?submodules=1 \
          && nvd diff $(ls -d1v /nix/var/nix/profiles/system-*-link | tail -n 2) \
          && if [[ "$(readlink /run/booted-system/{initrd,kernel,kernel-modules})" \
            != "$(readlink /run/current-system/{initrd,kernel,kernel-modules})" ]]; \
          then echo "Reboot required"; fi
      '';
      nixupdate = "sudo -v && nix flake update --flake ~/Nixos && rebuild";
      nixdiff = "nvd diff $(ls -d1v /nix/var/nix/profiles/system-*-link|tail -n 2)";
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
