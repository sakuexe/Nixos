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

  config = lib.mkIf config.dotfiles.enable {
    home.packages = with pkgs; [
      spotify
    ];
  };
}
