{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "sakuk";
  home.homeDirectory = "/home/sakuk";

  # xdg.configHome == ~/.config
  # xdg.dataHome == ~/.local/share
  home.file."${config.xdg.configHome}" = {
    source = ./.dotfiles;
    recursive = true;
  };

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

    # networking tools
    nmap # A utility for network discovery and security auditing

    # misc
    cowsay
    tree
    glow # markdown previewer in terminal

    # programming languages and etc
    go
    python3
    nodejs_22
    cargo # for now, used for nix lsp

    # nix related
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # system tools
    btop  # replacement of htop
    # nvidia-smi # nvidia overview
    pciutils # lspci
    usbutils # lsusb

    # neovim dependencies
    gcc9
    gnumake
    xclip

    # tmux plugins
    tmuxPlugins.sensible
    tmuxPlugins.yank

    # prompt (zsh/bash)
    oh-my-posh
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
