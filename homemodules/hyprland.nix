{
  config,
  pkgs,
  lib,
  ...
}:
let
  hyprconfig = import ./utils/hyprconfig.nix;

  appmenuScript = pkgs.pkgs.writeShellScriptBin "appmenu" ''
    error_message="$(fuzzel 2>&1 >/dev/null)"

    # program was found and everything works
    if [[ $? == 0 ]] then
      exit 0
    fi

    # fallback to web seach
    failed_command="$(echo $error_message | cut -d ':' -f 4 | xargs)"

    # if the prompt is prefixed with g (to make sure the search works)
    # remove it, before searching.

    # it is there to bypass fuzzel's feature where it tries to run the
    # failed command if it starts with something that can be found in
    # the user's $PATH (example: "cut in bash" would not work because it
    # would be interpeted as cut ...)
    prefix="g"
    failed_command=$(echo $failed_command | sed "s/^$prefix//i")

    # google search in default web browser (remove the whitespaces)
    xdg-open https://google.com/search?q=$(echo $failed_command | sed 's/ /+/g')
  '';

  screenshotScript = pkgs.pkgs.writeShellScriptBin "screenshot" ''
    set -e # exit on error

    # TODO: research freezing screen during 
    # screenshot region picking

    SELECTION_COLOR="C778DD0D"
    BACKGROUND_COLOR="1B1F28CC"
    BORDER_COLOR="E06B74ff"

    function region() {
      grim -g \
        "$(slurp -b $BACKGROUND_COLOR -c $BORDER_COLOR -s $SELECTION_COLOR -w 0)" - \
        | satty --filename - \
        --output-filename ~/Pictures/Screenshots/screenshot-$(date '+%Y%m%d_%H%M%S').png \
        --early-exit \
        --initial-tool brush \
        --disable-notifications \
        --actions-on-escape save-to-clipboard \
        --copy-command wl-copy
    }

    function fullscreen() {
      grim -o "$(hyprctl monitors | awk '/Monitor/{mon=$2} /focused: yes/{print mon}')" - \
        | satty --filename - \
        --fullscreen \
        --output-filename ~/Pictures/Screenshots/screenshot-$(date '+%Y%m%d_%H%M%S').png \
        --early-exit \
        --initial-tool brush \
        --disable-notifications \
        --actions-on-escape save-to-clipboard \
        --copy-command wl-copy
    }

    if [[ $1 == "" ]]; then
      echo "screenshots.sh usage: screenshots.sh <region || fullscreen>"
      exit 1
    fi

    if [[ $1 == "region" ]]; then
      region
      exit 0
    fi

    if [[ $1 == "fullscreen" ]]; then
      fullscreen
      exit 0
    fi

    echo "no valid mode was given (region || fullscreen)"
    exit 1
  '';
in
{
  options.hyprland = {
    enable = lib.mkEnableOption "Enables Hyprland configuration";

    ultrawide = lib.mkEnableOption {
      type = lib.types.bool;
      default = false;
      description = "Use settings meant for the ultrawide (32:9) monitor at home.";
    };

    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ../assets/floating-cubes.jpg;
      description = "Path to the wallpaper image";
    };
  };

  config = lib.mkIf config.hyprland.enable {
    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.settings = hyprconfig // {

      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor = [
        (
          if config.hyprland.ultrawide then
            ", highres, auto, auto, vrr, 1" # 32:9 home monitor
          else
            ", preferred,auto,auto" # default
        )
      ];

      "$menu" = "${appmenuScript}/bin/appmenu";
      # append instead of replace
      bind = hyprconfig.bind ++ [
        # screenshots
        ", Print, exec, ${screenshotScript}/bin/screenshot fullscreen"
        "SUPER_SHIFT, s, exec, ${screenshotScript}/bin/screenshot region"
      ];
    };

    # hyprland ricing dependencies
    home.packages = with pkgs; [
      waybar # statusbar
      # rofi-wayland # launcher
      fuzzel # launcher (testing for now)
      hyprpaper # wallpaper
      nwg-bar # power menu
      nautilus

      # system controls
      cliphist # clipboard manager
      playerctl # cli audio controls
      pavucontrol

      # screenshot stuff
      grim # take the screenshot
      slurp # capture a region of the screen
      satty # quick editor for the screenshot

      # images
      eog

      # widgets
      eww
    ];

    xdg.configFile."hypr/hyprpaper.conf" = {
      # enable = true;
      text = ''
        preload = ${config.hyprland.wallpaper}
        wallpaper = ,${config.hyprland.wallpaper}
      '';
    };
  };
}
