{ lib, config, userSettings, ... }:

{
  options.scheduler = {
    enable = lib.mkEnableOption "Add scripts to run at a scheduled time with systemd timers";

    # Each item creates one service + one timer.
    items = lib.mkOption {
      type = with lib.types; listOf (submodule ({ config, ... }: {
        options = {
          name = lib.mkOption {
            type = types.str;
            description = "Unique identifier for the service/timer pair.";
          };
          script = lib.mkOption {
            type = types.str;
            description = "The path to the script to run.";
          };
          description = lib.mkOption {
            type = types.str;
            description = "Description to use in systemd service and timer descriptions.";
            default = config.name;
          };
          onCalendar = lib.mkOption {
            type = types.str;
            default = "hourly";
            example = "Mon..Fri 12:00";
            description = ''
              systemd.time(7) OnCalendar expression (e.g. "hourly", "daily", "Mon..Fri 09:00").
            '';
          };
          packages = lib.mkOption {
            type = types.listOf types.package;
            default = [];
            description = "List of dependencies for the script.";
          };
        };
      }));
      default = [];
      description = "List of scheduler scripts to run.";
    };
  };

  config = lib.mkIf config.scheduler.enable (
    let
      services = lib.listToAttrs (map (item: {
        name = "schd-${item.name}";
        value = {
          description = item.description;
          serviceConfig = {
            Type = "oneshot";
            User = userSettings.username;
            WorkingDirectory = /home/${userSettings.username};
          };
          script = item.script;
          path = item.packages;

          # wait for the network to be up before starting the script
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };
      }) config.scheduler.items);

      timers = lib.listToAttrs (map (item: {
        name = "schd-${item.name}";
        value = {
          wantedBy = [ "timers.target" ];
          timerConfig.OnCalendar = item.onCalendar;
          timerConfig.Persistent = true;
        };
      }) config.scheduler.items);

    in {
      systemd.services = services;
      systemd.timers = timers;
    }
  );
}
