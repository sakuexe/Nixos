{
  config,
  lib,
  ...
}:

{
  options.docker = {
    enable = lib.mkEnableOption "enables docker (rootless)";
  };

  config = lib.mkIf config.docker.enable {
    # docker, rootless only: the daemon runs as a systemd user service,
    # so no root daemon and no root-equivalent docker group
    # https://wiki.nixos.org/wiki/Docker
    virtualisation.docker.rootless.enable = true;
    # point DOCKER_HOST at the rootless socket
    virtualisation.docker.rootless.setSocketVariable = true;

    # virtualisation.docker.autoPrune only applies to the rootful daemon,
    # so prune the rootless one with a user timer instead
    systemd.user.services.docker-prune = {
      description = "Prune unused rootless docker data";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      path = [ config.virtualisation.docker.rootless.package ];
      environment.DOCKER_HOST = "unix://%t/docker.sock";
      serviceConfig.Type = "oneshot";
      script = "docker system prune -f";
    };

    systemd.user.timers.docker-prune = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };
}
