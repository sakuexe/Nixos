{ config, pkgs, lib, home-manager, userSettings, ... }:

let
  dotfiles = "/home/${userSettings.username}/Nixos/.dotfiles";
in
{
  imports = [
    ./homemodules/wallpaper.nix
  ];

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

  wallpaper.enable = true;
  wallpaper.iconScale = 1.0; # does not work yet, the icon is not centered
  wallpaper.ultrawide = false;
  # wallpaper.backgroundImage = null;

  # TODO: look into this more
  # https://github.com/nix-community/plasma-manager/blob/trunk/examples/home.nix
  programs.plasma = {
    enable = true;
    workspace.wallpaper = ~/.config/nixos_logo.svg;
    workspace.wallpaperBackground.blur = true;
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
