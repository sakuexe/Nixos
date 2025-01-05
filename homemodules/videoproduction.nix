{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.videoproduction = {
    enable = lib.mkEnableOption "Enables the software I use for video production";
  };

  config = lib.mkIf config.videoproduction.enable {
    # video & audio software for video production
    home.packages = with pkgs; [
      obs-studio
      vlc
      audacity
      kdePackages.kdenlive
    ];
  };
}
