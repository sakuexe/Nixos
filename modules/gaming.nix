{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    heroic
    discord
    betterdiscordctl
    space-cadet-pinball
  ];
  
  # steam
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;
}
