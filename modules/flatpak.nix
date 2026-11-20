{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:

{
  options.flatpak = {
    enable = lib.mkEnableOption "enables flatpak and the flathub remote";
  };

  config = lib.mkIf config.flatpak.enable {
    # https://wiki.nixos.org/wiki/Flatpak
    services.flatpak.enable = true;

    # the flatpak module asserts that a portal is enabled
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # services.flatpak does not configure any remotes, add flathub system-wide
    systemd.services.flatpak-add-flathub = {
      description = "Add the flathub remote to flatpak";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      serviceConfig.Type = "oneshot";
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };

    # same for the user installation (~/.local/share/flatpak)
    systemd.services.flatpak-add-flathub-user = {
      description = "Add the flathub remote to flatpak for ${userSettings.username}";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      serviceConfig = {
        Type = "oneshot";
        User = userSettings.username;
      };
      script = ''
        flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
