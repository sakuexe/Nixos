{
  pkgs,
  lib,
  userSettings,
  ...
}:
{
  imports = [
    ./wallpaper.nix
    ./dotfiles.nix
    ./entertainment.nix
    ./videoproduction.nix
    ./hyprland.nix
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/${userSettings.username}";

  # custom home manager modules
  dotfiles.enable = lib.mkDefault true;
  wallpaper.enable = lib.mkDefault true;
  entertainment.enable = lib.mkDefault true;
  hyprland.enable = lib.mkDefault true;
  videoproduction.enable = lib.mkDefault false;

  # basic configuration of git
  programs.git = {
    enable = lib.mkDefault true;
    settings = {
      user.name = userSettings.description;
      user.email = userSettings.email;
    };
  };

  programs.bash = {
    enable = lib.mkDefault true;
    enableCompletion = lib.mkDefault true;
    bashrcExtra = lib.mkDefault ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    shellAliases = {
      la = "ls -laFh --color=auto";
      ll = "ls -lhpg --color=auto";
      l = "ls -F --color=auto";
      vi = "nvim";
    };
  };

  # automatically start virt-manager network
  dconf.settings = lib.mkDefault {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # terminal emulator
    ghostty

    # compression
    zip
    unzip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    fzf # A command-line fuzzy finder (the best util frfr)
    yazi # TUI file-manager of choice
    lazygit
    tldr

    # misc
    cowsay
    tree
    glow # markdown previewer in terminal
    pass # password-store
    wl-clipboard

    # nix related
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # system tools
    btop # replacement of htop
    # nvidia-smi # nvidia overview
    pciutils # lspci
    usbutils # lsusb

    # networking tools
    nmap # A utility for network discovery and security auditing

    # chromium browser
    vivaldi

    # office suite
    libreoffice
  ];

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
