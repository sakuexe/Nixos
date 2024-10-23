# My Nixos Configuration files

I became Nix-curious so I decided to try it out. There is no telling yet on how
long I will keep at it, so we will see.

NixOS is a declarative and very innovative Linux distro that allows for system
configurations to be made using the Nix language. This way you will be able to
build the system settings once and run them in all of your systems.

The code based system management piqued my interest and here we are. I loved the
idea of doing a git pull and having the same system on my PC and the laptop.


## Getting Started

0. Use `nix-shell` to install git momentarily

```bash
nix-shell -p git
```

1. Clone the repository to your home directory

```bash
git clone https://github.com/sakuexe/nixos ~/nixos
# exit the nix shell
exit
```

2. Remove the `/etc/nixos` -directory

```bash
# backup the original just in case
sudo cp -r /etc/nixos ~/nixos-backup
# remove
sudo rm -rf /etc/nixos
```

3. Create a symbolic link to `/etc/nixos`

```bash
sudo ln -s ~/nixos /etc/nixos
```

4. Rebuild the `hardware-configuration`-file

```bash
nixos-generate-config
```

5. Rebuild the system

```bash
sudo nixos-rebuild switch
```


## To-Try

- [Home Manager](https://github.com/nix-community/home-manager) Home folder
and dotfiles manager using Nix. To make software configuration declarative.

- [plasma-manager](https://github.com/nix-community/plasma-manager). Home Manager
modules for configuring the KDE Plasma settings using Nix.
