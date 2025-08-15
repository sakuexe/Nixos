{
  config,
  lib,
  userSettings,
  ...
}:

{
  options.docker = {
    enable = lib.mkEnableOption "enables docker (rootless)";
  };

  config = lib.mkIf config.docker.enable {
    # docker
    # https://wiki.nixos.org/wiki/Docker
    virtualisation.docker.enable = true;

    # include the user in the docker group
    users.users."${userSettings.username}".extraGroups = [
      "docker"
    ];

    # enable rootless mode
    virtualisation.docker.rootless.enable = true;
    virtualisation.docker.rootless.setSocketVariable = true;

    # enable btrfs
    virtualisation.docker.storageDriver = lib.mkDefault "btrfs";

    # automatically run docker system prune -f periodically
    virtualisation.docker.autoPrune.enable = true;
  };
}
