{ config, pkgs, lib, ... }:

let
  username = "sakuk";
  dotfiles = "/home/${username}/Nixos/.dotfiles";
in
{
  # TODO please change the username & home directory to your own
  home.username = username;
  home.homeDirectory = "/home/${username}";

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
  };

  # add .zshenv to home, it works as an entrypoint to zsh config
  home.file.".zshenv".source = ./.dotfiles/zsh/.zshenv;

  # add symlinks to .config

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

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

    # neovim dependencies
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
    userName = "Saku Karttunen";
    userEmail = "saku.karttunen@gmail.com";
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
    workspace.wallpaper = ./assets/dark_leaves_wp.jpg;
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
