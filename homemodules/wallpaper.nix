{
  config,
  lib,
  ...
}:
let
  cfg = config.wallpaper;

  filename = if cfg.ultrawide then "nixos_logo_ultrawide.svg" else "nixos_logo.svg";
  width = if cfg.ultrawide then 5120 else 2560;
  height = 1440;
  bgImage = if cfg.backgroundImage != null then cfg.backgroundImage else "";
  primaryColor = "#8255c2";
  secondaryColor = "#b8a0d9";

  # the logo paths are drawn for a 2560x1440 canvas, centered at (1280, 720).
  # scaling is done with an svg transform attribute instead of css transform-origin,
  # because plasma renders svgs with QtSvg (SVG Tiny 1.2), which ignores css transforms
  logoTransform = lib.concatStringsSep " " [
    "translate(${toString (width / 2)} ${toString (height / 2)})"
    "scale(${toString cfg.iconScale})"
    "translate(-1280 -720)"
  ];
in
{

  options.wallpaper = {
    enable = lib.mkEnableOption "enables the wallpaper module";

    ultrawide = lib.mkEnableOption {
      type = lib.types.bool;
      default = false;
      description = "Use the ultrawide (32:9) version of the wallpaper.";
    };

    backgroundImage = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = ../assets/dark_leaves_wp.jpg;
      description = "Path to the image that is used as the background";
    };

    backgroundImageOpacity = lib.mkOption {
      type = lib.types.float;
      default = 0.75;
      description = "Opacity of the background image. The value is between 0 and 1.";
      apply =
        value:
        lib.throwIf (
          value < 0 || value > 1
        ) "wallpaper.backgroundImageOpacity value should be between 0 and 1" value;
    };

    backgroundColor = lib.mkOption {
      type = lib.types.str;
      default = "#18181a";
      description = "Background color of the wallpaper. Supports hex and rgb values.";
    };

    iconScale = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "The scale of the icon if there is one";
      apply =
        value: lib.throwIf (value < 0) "wallpaper.iconScale value should be a positive float." value;
    };
  };

  # only enable the config if the module is enabled
  config = lib.mkIf cfg.enable {
    # idea from:
    # https://github.com/lucidph3nx/nixos-config/blob/main/modules/home-manager/desktopEnvironment/wallpaper.nix
    xdg.configFile.${filename}.text =
      # svg
      ''
        <?xml version="1.0" encoding="UTF-8"?>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="${toString width}"
          height="${toString height}"
          version="1.1"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          viewBox="0 0 ${toString width} ${toString height}">

          <rect id="background"
            width="${toString width}"
            height="${toString height}"
            style="fill: ${cfg.backgroundColor}; stroke-width: 0px;" />

          <image id="background-image"
            xlink:href="${bgImage}"
            x="0" y="0"
            width="${toString width}" height="${toString height}"
            preserveAspectRatio="xMidYMid slice"
            style="opacity: ${toString cfg.backgroundImageOpacity};"/>

          <g id="nixlogo" transform="${logoTransform}">
            <path
              id="part1"
              d="M1384.84,714.4l-130.34-225.77,59.9-.56,34.8,60.66,35.04-60.33h29.76s15.24,26.35,15.24,26.35l-49.93,85.85,35.44,61.68-29.92,52.14Z"
              style="fill: ${primaryColor};" />
            <path
              id="part2"
              d="M1337.5,807.37l130.36-225.76,30.44,51.59-35.13,60.46,69.77.18,14.87,25.78-15.18,26.37-99.31-.31-35.69,61.53-60.11.16Z"
              style="fill: ${secondaryColor};" />
            <path
              id="part3"
              d="M1233.11,813.33h260.69s-29.46,52.17-29.46,52.17l-69.93-.19,34.73,60.52-14.89,25.77-30.43.03-49.39-86.16-71.14-.14-30.19-51.98Z"
              style="fill: ${primaryColor};" />
            <path
              id="part4"
              d="M1176.06,725.86l130.34,225.77-59.9.56-34.8-60.66-35.04,60.33h-29.76s-15.24-26.35-15.24-26.35l49.93-85.85-35.44-61.68,29.92-52.14Z"
              style="fill: ${secondaryColor};" />
            <path
              id="part5"
              d="M1223.11,632.86l-130.36,225.76-30.44-51.59,35.13-60.46-69.77-.18-14.87-25.78,15.18-26.37,99.31.31,35.69-61.53,60.11-.16Z"
              style="fill: ${primaryColor};" />
            <path
              id="part6"
              d="M1327.26,626.41h-260.69s29.46-52.17,29.46-52.17l69.93.19-34.73-60.52,14.89-25.77,30.43-.03,49.39,86.16,71.14.14,30.19,51.98Z"
              style="fill: ${secondaryColor};" />
          </g>
        </svg>
      '';

    # add the wallpaper to kde (plasma-manager is added to every host in flake.nix)
    programs.plasma = {
      enable = true;
      workspace.wallpaper = "${config.xdg.configHome}/${filename}";
      workspace.wallpaperBackground.blur = true;
    };
  };
}
