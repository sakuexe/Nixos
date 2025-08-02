{
  config,
  lib,
  ...
}:

{
  options.manpages = {
    enable = lib.mkEnableOption "enables the module that adds some man page tweaks";
  };

  config = lib.mkIf config.manpages.enable {
    documentation = {
      # dev.enable = true;
      man.generateCaches = true; # allow man -k to work
      nixos.includeAllModules = false;
    };
  };
}
