# My Nixos Configuration files

I became Nix-curious so I decided to try it out. There is no telling yet on how
long I will keep at it, so we will see.

NixOS is a declarative and very innovative Linux distro that allows for system
configurations to be made using the Nix language. This way you will be able to
build the system settings once and run them in all of your systems.

The code based system management piqued my interest and here we are. I loved the
idea of doing a git pull and having the same system on my PC and the laptop.


## Getting Started

0. Use `nix-shell` to install git momentarily, if you do not have git already

```bash
nix-shell -p git
```

1. Clone the repository to your home directory (or wherever)

```bash
git clone --recurse-submodules -j8 https://github.com/sakuexe/nixos ~/nixos
# exit the nix shell
exit
```

2. Copy the `hardware-configuration` -file

This will overwrite the hardware file as well that is in there by default

```bash
cp /etc/nixos/hardware-configuration.nix ~/nixos
```

3. Rebuild the system

On the first build, you need to use this long ass command. You have to choose
which version you would like to use too.

Possible versions:

- Virtual Machine
- Laptop

```bash
# building the vm version
sudo nixos-rebuild switch --flake ~/nixos?submodules=1#vm-nix
# building the laptop version
sudo nixos-rebuild switch --flake ~/nixos?submodules=1#laptop

# reboot the machine afterwards
sudo reboot
```

After you have rebuilt and rebooted, you can just start using the `rebuild` alias.

```bash
rebuild
```

4. To be able to push changes to the `.dotfiles`, use git checkout.

```bash
cd ~/nixos/.dotfiles
git checkout main
```

## To-Try

- [Home Manager](https://github.com/nix-community/home-manager) Home folder
and dotfiles manager using Nix. To make software configuration declarative.

- [plasma-manager](https://github.com/nix-community/plasma-manager). Home Manager
modules for configuring the KDE Plasma settings using Nix.
