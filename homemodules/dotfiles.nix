{
  config,
  pkgs,
  lib,
  userSettings,
  inputs,
  ...
}:
let
  dotfiles = "/home/${userSettings.username}/Nixos/dotfiles";
in
{

  options.dotfiles = {
    enable = lib.mkEnableOption "enables the dotfiles module";

    programming = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "installs programming languages and tools when set to true";
    };
  };

  config = lib.mkIf config.dotfiles.enable {
    # dependencies of the dotfiles
    home.packages =
      with pkgs;
      [
        # neovim
        ripgrep
        gcc9
        gnumake
        xclip # xorg clipboard manager
        wl-clipboard # wayland clipboard manager
        # tmux plugins
        tmuxPlugins.sensible
        tmuxPlugins.yank
        # prompt (zsh/bash)
        oh-my-posh
        # stylizing the desktop (ricing)
        conky
      ]

      ++ lib.optionals config.dotfiles.programming [
        # programming languages
        go
        python3
        sqlite
        nodejs_23
        # language servers
        nixd # nix lsp
        nixfmt-rfc-style # nix formatter
        sumneko-lua-language-server
        typescript-language-server
        gopls
      ];

    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    programs.neovim.enable = true;
    # programs.neovim.extraPackages = with pkgs; [
    # ];
    programs.neovim.withNodeJs = true;
    programs.neovim.withPython3 = true;
    programs.neovim.withRuby = false;

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
      hypr = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr";
        recursive = true;
      };
    };

    # add .zshenv to home, it works as an entrypoint to zsh config
    home.file.".zshenv".source = ../.dotfiles/zsh/.zshenv;
  };
}
