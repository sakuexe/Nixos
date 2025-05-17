{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.entertainment = {
    enable = lib.mkEnableOption "Enables entertainment related packages";
  };

  config = lib.mkIf config.entertainment.enable {
    home.packages = with pkgs; [
      spotify
    ];
  };
}
