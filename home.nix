{ config, pkgs, lib, home-manager, userSettings, ... }:

let
  dotfiles = "/home/${userSettings.username}/Nixos/.dotfiles";
in
{
  # TODO please change the username & home directory to your own
  home.username = userSettings.username;
  home.homeDirectory = "/home/${userSettings.username}";

  # xdg.configHome == ~/.config
  # xdg.dataHome == ~/.local/share

  # https://mynixos.com/options/xdg.configFile.%3Cname%3E
  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";
      recursive = true;
    };
    tmux = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/tmux";
      recursive = true;
    };
    zsh = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zsh";
      recursive = true;
    };
    omp = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/omp";
      recursive = true;
    };
    # only on desktop environents
    alacritty = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/alacritty";
      recursive = true;
    };
    conky = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/conky";
      recursive = true;
    };
    fastfetch = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/fastfetch";
      recursive = true;
    };
  };

  # add .zshenv to home, it works as an entrypoint to zsh config
  home.file.".zshenv".source = ./.dotfiles/zsh/.zshenv;

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # compression
    zip
    unzip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    fzf # A command-line fuzzy finder (the best util frfr)

    # misc
    cowsay
    tree
    glow # markdown previewer in terminal
    pass # password-store
    wl-clipboard

    # programming languages and etc
    go
    python3
    nodejs_22
    cargo # for now, used for nix lsp
    sqlite

    # nix related
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # system tools
    btop  # replacement of htop
    # nvidia-smi # nvidia overview
    pciutils # lspci
    usbutils # lsusb

    # networking tools
    nmap # A utility for network discovery and security auditing

    # dotfiles dependencies
    # neovim
    gcc9
    gnumake
    xclip
    # tmux plugins
    tmuxPlugins.sensible
    tmuxPlugins.yank
    # prompt (zsh/bash)
    oh-my-posh

    # chromium browser
    brave

    # office suite
    libreoffice

    # video & audio
    obs-studio
    vlc
    audacity
    kdePackages.kdenlive

    # stylizing the desktop (ricing)
    conky
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = userSettings.description;
    userEmail = userSettings.email;
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    shellAliases = {
      la = "ls -laFh --color=auto";
      ll = "ls -lhpg --color=auto";
      l = "ls -F --color=auto";
      vi = "nvim";
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  # TODO: look into this more
  # https://github.com/nix-community/plasma-manager/blob/trunk/examples/home.nix
  programs.plasma = {
    enable = true;
    workspace.wallpaper = ~/.config/rainbow-wallpaper.svg;
    workspace.wallpaperBackground.blur = true;
  };

  # idea from:
  # https://github.com/lucidph3nx/nixos-config/blob/main/modules/home-manager/desktopEnvironment/wallpaper.nix
  home.file.".config/nixos_logo.svg" = {
      text = let
        bgColor = "#18181a";
        bgImage = ./assets/dark_leaves_wp.jpg; # path or an empty string
        bgImageOpacity = 0.5;
        primaryColor = "#8255c2";
        secondaryColor = "#b8a0d9";
        logoScale = 1;
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
        <rect 
          id="background"
          width="2560"
          height="1440"
          style="fill: ${bgColor}; stroke-width: 0px;" />

        <image 
          id="background-image" 
          xlink:href="${bgImage}"
          x="0" y="0" 
          width="2560" height="1440"
          preserveAspectRatio="xMidYMid slice"
          style="opacity: ${toString bgImageOpacity};"/>

        <g id="nixlogo" transform="scale: ${toString logoScale};">
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

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
