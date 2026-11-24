{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.gaming = {
    enable = lib.mkEnableOption "enables gaming related settings and packages";
  };

  config = lib.mkIf config.gaming.enable {
    environment.systemPackages = with pkgs; [
      heroic
      discord
      space-cadet-pinball
      mangohud
      protontricks
      prismlauncher
    ];

    # steam
    programs.steam.enable = true;
    programs.steam.remotePlay.openFirewall = true;
    programs.steam.localNetworkGameTransfers.openFirewall = true;

    # Use these in steam by setting launch options:
    # mangohud %command%
    # gamescope %command%
    # gamemoderun %command%
    # gamescope can help if the game running has problems upscaling
    # (only the binary, steam.gamescopeSession would add a Steam Deck-like login session to SDDM)
    programs.gamescope.enable = true;
    # performance optimizations
    programs.gamemode.enable = true;
  };
}
