{ config, lib, ... }:

{
  options.nvidia = {
    enable = lib.mkEnableOption "enables nvidia settings and tweaks to make it actually work";

    latestVersion = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "use the latest driver (newest of production/new-feature branches) instead of stable";
    };
  };

  config = lib.mkIf config.nvidia.enable {
    hardware.graphics.enable = true;

    # open kernel modules: recommended by nvidia for turing and newer
    hardware.nvidia.open = true;

    # loads the nvidia driver (also needed on wayland, despite the option name)
    services.xserver.videoDrivers = [ "nvidia" ];

    # driver package version
    hardware.nvidia.package =
      if config.nvidia.latestVersion then
        config.boot.kernelPackages.nvidiaPackages.latest
      else
        config.boot.kernelPackages.nvidiaPackages.stable;

    # power management
    hardware.nvidia.powerManagement.enable = true;

    environment.sessionVariables = {
      # use nvidia-vaapi-driver for hardware video decoding
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };
}
