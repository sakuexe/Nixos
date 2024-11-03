{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    heroic
    betterdiscordctl
  ];
  
  # steam
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;
}
