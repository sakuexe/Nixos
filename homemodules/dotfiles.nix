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
  # returns an attribute list of { DIRNAME = "directory" }
  directories = builtins.filterSource (_: type: type == "directory") dotfiles;
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
        gcc15
        gnumake
        xclip # xorg clipboard manager
        wl-clipboard # wayland clipboard manager
        # tmux plugins
        tmuxPlugins.sensible
        tmuxPlugins.yank
        # prompt (zsh/bash)
        oh-my-posh
      ]

      ++ lib.optionals config.dotfiles.programming [
        # programming languages
        go
        # python313
        (python313.withPackages (python313Packages: with python313Packages; [
          pip
        ]))
        sqlite
        nodejs_22
        # language servers
        nixd # nix lsp
        nixfmt-rfc-style # nix formatter
        lua-language-server
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

    # dynamically add all dotfiles folders as a symlink to xdgconfig
    # this way I can modify them and see the changes without a reload
    # some nix-heads would propably not approve of this impurity
    xdg.configFile = builtins.mapAttrs (name: path: {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${name}";
      recursive = true;
    }) (builtins.readDir directories);

    # add .zshenv to home, it works as an entrypoint to zsh config
    home.file.".zshenv".source = "${dotfiles}/zsh/.zshenv";
  };
}
