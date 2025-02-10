{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    heroic
    discord
    discord-canary # use canary until wayland screenshare comes to stable
    betterdiscordctl
    space-cadet-pinball
    mangohud
    protontricks
    prismlauncher
  ];

  # steam
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;

  # Use these in steam by setting launch options:
  # mangohud %command%
  # gamescope %command%
  # gamemoderun %command%
  # can help if the game running has problems upscaling
  programs.steam.gamescopeSession.enable = true;
  # performance optimizations
  programs.gamemode.enable = true;
}
