{
  lib,
  ...
}:

{
  # Default hyprland configuration, to be used as a base
  # for the home-manager configuration.
  # This is done so that the file can be a bit more readable

  # --- MONITORS ---
  # https://wiki.hyprland.org/Configuring/Monitors/
  monitor = [
    ",preferred,auto,auto"
  ];

  # --- PROGRAMS ---
  # https://wiki.hyprland.org/Configuring/Keywords/
  "$terminal" = "ghostty";
  "$fileManager" = "nautilus";
  "$menu" = ''sh $XDG_CONFIG_HOME/hypr/scripts/appmenu.sh'';
  "$browser" = "vivaldi";
  "$powermenu" = "nwg-bar";

  # --- AUTOSTART ---
  "exec-once" = [
    "waybar & hyprpaper"
    ''tmux setenv -g HYPRLAND_INSTANCE_SIGNATURE "$HYPRLAND_INSTANCE_SIGNATURE"''
    "wl-paste --type text --watch cliphist store"
    "wl-paste --type image --watch cliphist store"
    "eww open notifications"
  ];

  # --- ENV ---
  # https://wiki.hyprland.org/Configuring/Environment-variables/
  env = [
    "XCURSOR_SIZE,24"
    "HYPRCURSOR_SIZE,24"
  ];

  # --- LOOK & FEEL ---
  # https://wiki.hyprland.org/Configuring/Variables/

  # https://wiki.hyprland.org/Configuring/Variables/#general
  general = {
    gaps_in = 2;
    gaps_out = 12;
    border_size = 2;
    "col.active_border" = lib.mkDefault "rgba(783cbdee) rgba(ad6e40ee) 45deg";
    "col.inactive_border" = lib.mkDefault "rgba(595959aa)";
    resize_on_border = false;
    allow_tearing = false;
    layout = "master"; # or dwindle
  };

  # https://wiki.hyprland.org/Configuring/Master-Layout/
  master = {
    new_status = "slave";
    orientation = "center";
    slave_count_for_center_master = 0;
    center_master_fallback = "right";
    mfact = 0.5;
  };

  # https://wiki.hyprland.org/Configuring/Dwindle-Layout/
  dwindle = {
    pseudotile = true;
    preserve_split = true;
  };

  # https://wiki.hyprland.org/Configuring/Variables/#decoration
  decoration = {
    rounding = 10;
    active_opacity = 1.0;
    inactive_opacity = 1.0;

    shadow = {
      enabled = true;
      range = 4;
      render_power = 3;
      color = lib.mkDefault "rgba(1a1a1aee)";
    };

    blur = {
      enabled = true;
      size = 3;
      passes = 1;
      vibrancy = 0.1696;
    };
  };

  # Hyprland expects multiple 'bezier' and 'animation' lines
  # https://wiki.hyprland.org/Configuring/Variables/#animations
  bezier = [
    "easeOutQuint,0.23,1,0.32,1"
    "easeInOutCubic,0.65,0.05,0.36,1"
    "linear,0,0,1,1"
    "almostLinear,0.5,0.5,0.75,1.0"
    "quick,0.15,0,0.1,1"
  ];
  animation = [
    "global, 1, 10, default"
    "border, 1, 5.39, easeOutQuint"
    "windows, 1, 4.79, easeOutQuint"
    "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
    "windowsOut, 1, 1.49, linear, popin 87%"
    "fadeIn, 1, 1.73, almostLinear"
    "fadeOut, 1, 1.46, almostLinear"
    "fade, 1, 3.03, quick"
    "layers, 1, 3.81, easeOutQuint"
    "layersIn, 1, 4, easeOutQuint, fade"
    "layersOut, 1, 1.5, linear, fade"
    "fadeLayersIn, 1, 1.79, almostLinear"
    "fadeLayersOut, 1, 1.39, almostLinear"
    "workspaces, 1, 1.94, almostLinear, fade"
    "workspacesIn, 1, 1.21, almostLinear, fade"
    "workspacesOut, 1, 1.94, almostLinear, fade"
  ];
  animations = {
    enabled = "yes, please :)";
  };

  # --- INPUT ---
  # https://wiki.hyprland.org/Configuring/Variables/#input
  input = {
    kb_layout = "us,fi";
    kb_variant = "";
    kb_model = "";
    kb_options = "grp:win_space_toggle,ctrl:nocaps";
    kb_rules = "";
    follow_mouse = 1;
    sensitivity = 0; # -1.0 to 1.0
    touchpad = {
      natural_scroll = true;
    };
  };

  # gestures
  # https://wiki.hyprland.org/Configuring/Variables/#gestures
  gesture = "3, horizontal, workspace";

  # Example of a device specific configuration
  device = [
    {
      name = "epic-mouse-v1";
      sensitivity = "-0.5";
    }
  ];

  # --- BINDS ---
  # https://wiki.hyprland.org/Configuring/Keywords/
  "$mainMod" = "SUPER";

  bind = [
    "$mainMod, Q, exec, $terminal"
    "$mainMod, SUPER_L, exec, $menu"
    ", mouse:278, exec, $menu"
    "$mainMod, F, exec, $browser"
    "$mainMod, E, exec, $fileManager"
    "$mainMod, X, exec, hyprctl kill"
    "$mainMod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

    # murder
    "$mainMod SHIFT, Q, exec, pkill waybar && waybar &"
    "$mainMod, C, killactive,"
    "$mainMod, M, exec, $powermenu"

    "$mainMod, T, togglefloating,"
    "$mainMod, P, layoutmsg, swapwithmaster master"

    # screenshots
    ", Print, exec, sh $XDG_CONFIG_HOME/hypr/scripts/screenshots.sh fullscreen"
    "SUPER_SHIFT, s, exec, sh $XDG_CONFIG_HOME/hypr/scripts/screenshots.sh region"

    # navigation
    "$mainMod, h, movefocus, l"
    "$mainMod, l, movefocus, r"
    "$mainMod, k, movefocus, u"
    "$mainMod, j, movefocus, d"
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"
    "$mainMod SHIFT, 1, movetoworkspace, 1"
    "$mainMod SHIFT, 2, movetoworkspace, 2"
    "$mainMod SHIFT, 3, movetoworkspace, 3"
    "$mainMod SHIFT, 4, movetoworkspace, 4"
    "$mainMod SHIFT, 5, movetoworkspace, 5"
    "$mainMod SHIFT, 6, movetoworkspace, 6"
    "$mainMod SHIFT, 7, movetoworkspace, 7"
    "$mainMod SHIFT, 8, movetoworkspace, 8"
    "$mainMod SHIFT, 9, movetoworkspace, 9"
    "$mainMod SHIFT, 0, movetoworkspace, 10"
    "$mainMod, S, togglespecialworkspace, magic"
    "$mainMod, mouse_down, workspace, e+1"
    "$mainMod, mouse_up, workspace, e-1"
  ];

  # mouse binds
  bindm = [
    # move/resize window with mainmod + mouse buttons
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  # laptop specific binds for volume and lcd brightness
  bindel = [
    ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
    ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ", XF86MonBrightnessUp, exec, brightnessctl s 11%+"
    ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
  ];

  # media player specific binds
  bindl = [
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPause, exec, playerctl play-pause"
    ", XF86AudioPlay, exec, playerctl play-pause"
    ", XF86AudioPrev, exec, playerctl previous"
  ];

  # --- WINDOWS & WORKSPACES / RULES ---
  # https://wiki.hyprland.org/Configuring/Window-Rules/
  # https://wiki.hyprland.org/Configuring/Workspace-Rules/
  "windowrulev2" = [

    "suppressevent maximize, class:.*"
    "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
    "opacity 0.95, floating:1,fullscreen:0"

    # steam friends
    "float, class:steam, initialTitle:Friends List"
    "size 500 800, class:steam, initialTitle:Friends List"
    "center, class:steam, initialTitle:Friends List"

    # system management popups
    "float, class:^\\.blueman.*"
    "size 600 400, class:^\\.blueman.*"
    "move 100%-w-11 3%, class:^\\.blueman.*"
    "float, class:^org\\.pulseaudio\\.pavucontrol$"
    "size 800 500, class:^org\\.pulseaudio\\.pavucontrol$"
    "move 100%-w-11 3%, class:^org\\.pulseaudio\\.pavucontrol$"

    # image viewer
    "float, class:^eog$"
  ];
}
