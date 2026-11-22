{
  config,
  lib,
  userSettings,
  ...
}:

let
  home = "/home/${userSettings.username}";
in
{
  options.syncthing = {
    enable = lib.mkEnableOption "syncthing as a spoke of the observatory hub (nixos_cloud)";
  };

  config = lib.mkIf config.syncthing.enable {
    # gui: http://localhost:8384
    # this device's id (needed on the hub): syncthing --device-id --home ~/.config/syncthing
    services.syncthing = {
      enable = true;
      # run as the user so synced files are owned by them, not a syncthing user
      user = userSettings.username;
      group = "users";
      dataDir = home;
      configDir = "${home}/.config/syncthing";
      guiAddress = "127.0.0.1:8384";
      # nix is the source of truth, devices/folders added in the gui are removed on restart
      overrideDevices = true;
      overrideFolders = true;

      # no openDefaultPorts: this machine only dials out to the hub

      settings = {
        devices.observatory = {
          id = "5LDS7RX-Y2YPCD2-AGA7BNC-WIBHSW7-BMNJIAE-TG6IW67-L7GRDO5-ASZD2QE";
          addresses = [
            "tcp://[2a01:4f9:c014:750f::1]:22000"
            "dynamic"
          ];
        };

        # only the save dir, config.toml (resolution etc.) stays per machine
        # path is ~/.config because the flatpak has host filesystem access
        folders."unleashed-saves" = {
          path = "${home}/.config/UnleashedRecomp/save";
          devices = [ "observatory" ];
        };
      };
    };
  };
}
