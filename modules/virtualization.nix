{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.virtualization = {
    enable = lib.mkEnableOption "enables virtualization related settings and packages";
  };

  config = lib.mkIf config.virtualization.enable {
    # virtualization
    # https://nixos.wiki/wiki/Virt-manager
    virtualisation.libvirtd.enable = true;
    virtualisation.libvirtd.qemu.vhostUserPackages = with pkgs; [
      # enable sharing of folders between host and guest
      virtiofsd
    ];
    programs.virt-manager.enable = true;
  };
}
