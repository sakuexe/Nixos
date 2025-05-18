{ config, lib, ... }:

{
  options.nvidia = {
    enable = lib.mkEnableOption "enables nvidia settings and tweaks to make it actually work";

    laptopSpecifics = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enables laptop specific tweaks to make nvidia work";
    };

    openDriver = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enables open source nvidia kernel modules";
    };

    betaVersion = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether to use the unstable driver or not";
    };

    offload = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether to use nvidia prime for hybrid graphics";
    };
  };

  config = lib.mkIf config.nvidia.enable {
    # allow unfree packages by default
    nixpkgs.config.allowUnfree = lib.mkDefault true;

    # OpenGL
    # hardware.opengl.enable = true; # old way
    hardware.graphics.enable = true; # new way

    hardware.enableAllFirmware = config.nvidia.laptopSpecifics;
    hardware.nvidia.open = config.nvidia.openDriver;

    # nvidia
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.modesetting.enable = true;

    # driver package version
    hardware.nvidia.package =
      if config.nvidia.betaVersion then
        config.boot.kernelPackages.nvidiaPackages.beta
      else
        config.boot.kernelPackages.nvidiaPackages.stable;

    # power management
    hardware.nvidia.powerManagement.enable = false;
    hardware.nvidia.powerManagement.finegrained = false;

    # extra settings
    hardware.nvidia.nvidiaSettings = true;

    hardware.nvidia.prime = lib.mkIf config.nvidia.offload {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      # these are set in the nixos hardware fix module for now
      # amdgpuBusId = "PCI:6:0:0";
      # nvidiaBusId = "PCI:1:0:0";
    };
  };
}
