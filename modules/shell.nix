{ config, lib, ... }:

{
  options.shell = {
    enable = lib.mkEnableOption "enables the zsh shell and all the tweaks for it";
  };

  config = lib.mkIf config.shell.enable {
    # zsh
    programs.zsh.enable = lib.mkDefault true;

    # plugins
    programs.zsh.enableCompletion = lib.mkDefault true;
    programs.zsh.syntaxHighlighting.enable = lib.mkDefault true;
    programs.zsh.autosuggestions.enable = lib.mkDefault true;

    # aliases
    programs.zsh.shellAliases = {
      # nixos specific aliases
      rebuild = "sudo nixos-rebuild --impure switch --flake ~/Nixos\\?submodules=1";
      nixdev = "nix develop git+file://\${PWD}\\?ref=HEAD --command zsh || nix develop --command zsh";
      openport = "sudo nixos-firewall-tool open tcp";
      # reformat the task manager icons, if they cannot be found
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
      # TODO: this one does not work yet, fix it later
      recover = "sudo snapper -c home -v undochange $(echo $1)..0 $2";
    };
  };
}
