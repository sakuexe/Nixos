{ lib, userSettings, ... }:

{
  # docker
  # https://wiki.nixos.org/wiki/Docker
  virtualisation.docker.enable = true;

  # enable rootless mode
  users.users."${userSettings.username}".extraGroups = [
    "docker"
  ];
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;

  # enable btrfs
  virtualisation.docker.storageDriver = lib.mkDefault "btrfs";
}
