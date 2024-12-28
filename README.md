# My Nixos Configuration files

I became Nix-curious so I decided to try it out. There is no telling yet on how
long I will keep at it, so we will see.

NixOS is a declarative and very innovative Linux distro that allows for system
configurations to be made using the Nix language. This way you will be able to
build the system settings once and run them in all of your systems.

The code based system management piqued my interest and here we are. I loved the
idea of doing a git pull and having the same system on my PC and the laptop.

For a fresh install of NixOS, follow [disko quickstart guide](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
for easy btrfs subvolume configurations.

## Install and build this setup

1. Use the `install` script to clone and build one of my configurations

This will also use your `hardware-configuration.nix` file by copying it from `/etc/nixos`.

To check what this installation script does, check it out from the 
[flake.nix](https://github.com/sakuexe/Nixos/blob/main/flake.nix#L117) file.

```bash
sudo nix --experimental-features "nix-command flakes" run github:sakuexe/Nixos#install
```

2. Reboot the system

```bash
sudo reboot
```

**Extra**: To be able to push changes to the `.dotfiles`, use git checkout.

```bash
cd ~/nixos/.dotfiles
git checkout main
```

## To-Try

- [Home Manager](https://github.com/nix-community/home-manager) Home folder
and dotfiles manager using Nix. To make software configuration declarative.

- [plasma-manager](https://github.com/nix-community/plasma-manager). Home Manager
modules for configuring the KDE Plasma settings using Nix.

## Useful commands

Nix flake examples: [NixOS/templates - Github](https://github.com/NixOS/templates)

[Novice Nix: Flake Templates - Akshav @ oppi.li](https://oppi.li/posts/novice_nix:_flake_templates/)

```bash
# get a template
nix flake init --template templates#full
# more information
nix flake init --help
```
