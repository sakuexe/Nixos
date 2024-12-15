{ config, lib, home-manager, ... }: {

  options.wallpaper = {
    enable = 
      lib.mkEnableOption "enables the wallpaper module";

    backgroundImage = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = ../assets/dark_leaves_wp.jpg;
      description = "Path to the image that is used as the background";
    };

    backgroundImageOpacity = lib.mkOption {
      type = lib.types.float;
      default = 0.75;
      description = "Opacity of the background image. The value is between 0 and 1.";
      apply = value: lib.throwIf (value < 0 || value > 1) "wallpaper.backgroundImageOpacity value should be between 0 and 1" value;
    };

    backgroundColor = lib.mkOption {
      type = lib.types.str;
      default = "#18181a";
      description = "Background color of the wallpaper. Supports hex and rgb values.";
    };

    iconScale = lib.mkOption {
      type = lib.types.float;
      default = 1;
      description = "The scale of the icon if there is one";
      apply = value: lib.throwIf (value < 0) "wallpaper.iconScale value should be a positive float." value;
    };
  };

  # only enable the config if the module is enabled
  config = lib.mkIf config.wallpaper.enable {
    # idea from:
    # https://github.com/lucidph3nx/nixos-config/blob/main/modules/home-manager/desktopEnvironment/wallpaper.nix
    home.file.".config/nixos_logo.svg" = {
        text = let
          bgImage = if (config.wallpaper.backgroundImage != null) then config.wallpaper.backgroundImage else "";
          primaryColor = "#8255c2";
          secondaryColor = "#b8a0d9";
        in
        /* svg */
        ''
        <?xml version="1.0" encoding="UTF-8"?>
        <svg 
          xmlns="http://www.w3.org/2000/svg"
          width="2560"
          height="1440"
          version="1.1"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          viewBox="0 0 2560 1440">

          <rect id="background"
            width="2560"
            height="1440"
            style="fill: ${config.wallpaper.backgroundColor}; stroke-width: 0px;" />

          <image id="background-image" 
            xlink:href="${bgImage}"
            x="0" y="0" 
            width="2560" height="1440"
            preserveAspectRatio="xMidYMid slice"
            style="opacity: ${toString config.wallpaper.backgroundColor};"/>

          <g id="nixlogo" 
            transform="scale(${toString config.wallpaper.iconScale})"
            style="transform-origin: center; transform-box: border-box;">
            <path 
              id="part1"
              d="M1384.84,714.4l-130.34-225.77,59.9-.56,34.8,60.66,35.04-60.33h29.76s15.24,26.35,15.24,26.35l-49.93,85.85,35.44,61.68-29.92,52.14Z" 
              style="fill: ${secondaryColor};"/>
            <path 
              id="part2"
              d="M1337.5,807.37l130.36-225.76,30.44,51.59-35.13,60.46,69.77.18,14.87,25.78-15.18,26.37-99.31-.31-35.69,61.53-60.11.16Z" 
              style="fill: ${primaryColor};" />
            <path 
              id="part3"
              d="M1233.11,813.33h260.69s-29.46,52.17-29.46,52.17l-69.93-.19,34.73,60.52-14.89,25.77-30.43.03-49.39-86.16-71.14-.14-30.19-51.98Z" 
              style="fill: ${secondaryColor};" />
            <path 
              id="part4" 
              d="M1176.06,725.86l130.34,225.77-59.9.56-34.8-60.66-35.04,60.33h-29.76s-15.24-26.35-15.24-26.35l49.93-85.85-35.44-61.68,29.92-52.14Z" 
              style="fill: ${primaryColor};" />
            <path 
              id="part5" 
              d="M1223.11,632.86l-130.36,225.76-30.44-51.59,35.13-60.46-69.77-.18-14.87-25.78,15.18-26.37,99.31.31,35.69-61.53,60.11-.16Z" 
              style="fill: ${secondaryColor};" />
            <path 
              id="part6" 
              d="M1327.26,626.41h-260.69s29.46-52.17,29.46-52.17l69.93.19-34.73-60.52,14.89-25.77,30.43-.03,49.39,86.16,71.14.14,30.19,51.98Z" 
              style="fill: ${primaryColor};" />
            </g>
          </svg>
        '';
    };
  };
}
