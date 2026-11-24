# My NixOS Configuration files

My NixOS setup as a flake: system configuration, home-manager and dotfiles for
all of my machines, so that a `git pull` and a rebuild gives the same system
everywhere.

## Hosts

| Host       | What it is                           | nixpkgs  |
| ---------- | ------------------------------------ | -------- |
| `ringtail` | desktop PC (NVIDIA, Plasma 6)        | unstable |
| `nixos-vm` | virtual machine for testing          | 26.05    |
| `wsl`      | NixOS-WSL on the work Windows laptop | 26.05    |

Stable hosts can still pull single packages from unstable through `pkgs.unstable`
(an overlay in `flake.nix`). On ringtail `pkgs.unstable` is just `pkgs`.

## Repo layout

```
flake.nix          hosts, the pkgs.unstable overlay and the install scripts
machines/<host>/   configuration.nix, home.nix and hardware-configuration.nix per host
machines/disko-config.nix   disk layout, only used by the freshinstall script
modules/           NixOS modules, toggled with <name>.enable (gaming, nvidia, docker, ...)
homemodules/       home-manager modules (dotfiles, wallpaper, hyprland, ...)
dotfiles/          git submodule: https://github.com/sakuexe/.dotfiles
assets/            wallpapers
```

The dotfiles are not copied into the Nix store. `homemodules/dotfiles.nix`
symlinks them from `~/Nixos/dotfiles` with `mkOutOfStoreSymlink`, so edits apply
immediately without a rebuild.

### Why `--impure`

`homemodules/dotfiles.nix` reads the dotfiles directory with `builtins.readDir`
from the absolute path `/home/sakuk/Nixos/dotfiles`, which pure evaluation does
not allow. Every build of this flake therefore needs `--impure` (the aliases
below already pass it). This also means the repo has to be cloned to
`~/Nixos`, with submodules.

## Installation

### Existing NixOS install

Clones this repo to `~/Nixos`, copies `/etc/nixos/hardware-configuration.nix`
into the chosen host and switches to it.

```bash
sudo nix --experimental-features "nix-command flakes" run github:sakuexe/Nixos#install
sudo reboot
```

### Fresh install (formats a disk)

Boot the NixOS live installer and run the following as the default `nixos` user
(not with sudo, the script uses sudo itself):

```bash
nix --experimental-features "nix-command flakes" run github:sakuexe/Nixos#freshinstall
```

It formats the chosen disk with [disko](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
(GPT, ESP, swap and btrfs with `@root`, `@home`, `@nix`, `@var/lib`, `@var/log`
subvolumes, see `machines/disko-config.nix`), generates the hardware config,
clones this repo and runs `nixos-install`.

Safety checks, the script refuses to:

- run anywhere but the live installer (needs a tmpfs `/` and `/iso` mounted),
  so it can never format a disk on an installed system
- format a disk that has mounted partitions (for example the installer USB)
- continue unless the full device path is typed out, and disko asks once more
  before wiping

### WSL

Not installed with the scripts. Install [NixOS-WSL](https://github.com/nix-community/NixOS-WSL),
then:

```bash
git clone --recurse-submodules https://github.com/sakuexe/Nixos ~/Nixos
sudo nixos-rebuild switch --impure --flake ~/Nixos#wsl
```

After the first switch the hostname is `wsl` and the normal `rebuild` alias works.

## Day-to-day

[nh](https://github.com/nix-community/nh) is used instead of calling
`nixos-rebuild` directly. It shows a diff of the changed packages after every
build.

```bash
rebuild     # nh os switch --impure, then prints "Reboot required" if the kernel or initrd changed
nixupdate   # same, but updates flake.lock first
nix fmt     # format the nix files with nixfmt
```

Garbage collection runs weekly with `nh clean` (keeps the last 30 days, but at
least 8 generations). It can be run by hand with:

```bash
nh clean all --keep-since 30d --keep 8
```

To push changes to the dotfiles, check out a branch in the submodule first
(submodules are cloned with a detached HEAD):

```bash
cd ~/Nixos/dotfiles
git checkout main
```

## TODO

- Fix nixd lsp not including documentation when hovering over home-manager stuff.

## Useful links

Nix flake examples: [NixOS/templates - Github](https://github.com/NixOS/templates)

[Novice Nix: Flake Templates - Akshav @ oppi.li](https://oppi.li/posts/novice_nix:_flake_templates/)

```bash
# get a template
nix flake init --template templates#full
# more information
nix flake init --help
```
