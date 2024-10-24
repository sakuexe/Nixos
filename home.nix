{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "sakuk";
  home.homeDirectory = "/home/sakuk";

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

    # nix related
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # system tools
    btop  # replacement of htop
    # nvidia-smi # nvidia overview
    pciutils # lspci
    usbutils # lsusb
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
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
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
