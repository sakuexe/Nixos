{ config, lib, ... }:
{
  # allow unfree packages by default
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # OpenGL
  # hardware.opengl.enable = true; # old way
  hardware.graphics.enable = true; # new way

  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  # driver package
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.nvidia.open = false;
  # power management
  hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.powerManagement.finegrained = false;
  # extra settings
  hardware.nvidia.nvidiaSettings = true;
}
