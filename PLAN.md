# Modernization plan

Working plan for the next round of cleanup. Work through it top to bottom, one
step at a time, and delete this file when it is done.

The first cleanup round (WSL as a flake input, rootless-only docker, scheduler
removed, X11 removed, nvidia/hyprland cleanup, single compinit, ...) is already
committed. Everything below builds on that state.

## Ground rules

- `--impure` stays. It is needed because `homemodules/dotfiles.nix` runs
  `builtins.readDir` on the absolute path `/home/sakuk/Nixos/dotfiles`.
- Two commits, stop between them so the result can be rebuilt and checked.
- Nothing is switched by the agent: build and diff only, the user runs `rebuild`.
- Keep comments that are still accurate (especially links). Drop template cruft.

## Decisions already made (do not re-litigate)

- **`?submodules=1` is not needed.** Verified: ringtail evaluates to the same
  derivation with and without it. It used to be required when the config
  referenced `./dotfiles` as an in-flake path. Dotfiles are now read from an
  absolute path, which `--impure` covers. Remove it from the flake refs, but keep
  `git clone --recurse-submodules` in the install scripts (the dotfiles still
  need to exist on disk for the out-of-store symlinks).
- **nh gets `--impure` through the aliases.** nh 4.x has a native `--impure`
  flag but no env var for it. `nix.settings.pure-eval = false` would also work,
  but was rejected: it makes every flake on the machine impure.
- **`pkgs.unstable` comes from an overlay**, not `specialArgs`. With
  `useGlobalPkgs` home-manager sees it for free, and on ringtail (already on
  unstable) it is just `final`, so nixpkgs is not instantiated twice.
- **Presets go in `machines/`, option-declaring modules stay in `modules/`.**
  Same layout as `~/Code/nixos_cloud` (`hosts/common.nix`).
- **plasma-manager goes into `sharedModules` for every host**, WSL included. It is
  inert unless `programs.plasma.enable` is set. That lets `wallpaper.nix` drop
  the `hasPlasmaManager` probe.
- **nix-flatpak was rejected.** Unleashed Recomp is installed from a bundle
  (origin `unleashedrecomp-origin`, not flathub), and nix-flatpak's updater only
  runs `install --or-update` on declared apps. It would never update the
  `GL.nvidia-*` extension, which is the reason the custom update timer exists.
  Keep `modules/flatpak.nix` as is.
- **Keep as is:** `wallpaper.ultrawide`'s `mkEnableOption` (docs are never
  generated), `useOSProber` (Windows on nvme0n1), both `stateVersion`s, the
  NixOS-level `programs.neovim` (root needs `nvim` as `$EDITOR`, the HM neovim
  is not on root's PATH).

## Commit 1: nh, overlay, small fixes, install scripts, README

### nh (`modules/shell.nix`)

- [ ] `programs.nh.enable = true;` and `programs.nh.flake = "/home/${userSettings.username}/Nixos";`
- [ ] `programs.nh.clean.enable = true;` with
      `programs.nh.clean.extraArgs = "--keep-since 30d --keep 5";`
      (keeps at least 5 generations even after a long break, unlike `--delete-older-than`)
- [ ] Remove `nix.gc.*` from all three hosts (nh clean replaces it). Leave
      `auto-optimise-store` until the small-fixes step below.
- [ ] Aliases:
  - `rebuild` → `nh os switch --impure`, followed by the existing reboot check
    (compare `readlink /run/booted-system/{initrd,kernel,kernel-modules}` with
    `/run/current-system/...`; nh does not do this)
  - `nixupdate` → `nh os switch --impure --update` (+ the same reboot check)
  - remove `nixdiff` (nh shows the diff)
  - `nvd` can then leave `environment.systemPackages` unless still wanted for manual diffs

### `pkgs.unstable` overlay

- [ ] Add an overlay (in `flake.nix` for now, it moves into mkHost in commit 2):
      `unstable = if <host is on unstable> then final else import nixpkgs-unstable { inherit (final.stdenv.hostPlatform) system; config = final.config; };`
- [ ] `homemodules/dotfiles.nix`: drop the `pkgs-unstable = import ...` let binding,
      use `pkgs.unstable.claude-code` / `pkgs.unstable.pi-coding-agent`.
      This removes the last eval warning (`'system' has been renamed to ...`).
- [ ] `dotfiles.nix` no longer needs the `inputs` argument afterwards.

### `.zshenv`

- [ ] `homemodules/dotfiles.nix`: `home.file.".zshenv".source` is currently a plain
      string path, so it is copied into the store (needs a rebuild after edits).
      Use `config.lib.file.mkOutOfStoreSymlink` like the other dotfiles.

### Small fixes

- [ ] `modules/keyboard.nix`: replace the hand-written udev rules and the plugdev
      group with `hardware.keyboard.zsa.enable = true;` (keep `keymapp`).
      Note: WSL adds itself to `plugdev` for the YubiKey rule. Make sure that group
      still exists there (keyboard is disabled on WSL).
- [ ] `modules/gaming.nix`: `programs.steam.gamescopeSession.enable` →
      `programs.gamescope.enable = true;` (the session adds a Steam Deck-like login
      session to SDDM; `gamescope %command%` only needs the binary). Update the
      comment above it.
- [ ] `modules/gaming.nix`: drop `programs.steam.dedicatedServer.openFirewall`.
- [ ] `homemodules/dotfiles.nix`: `nodejs_22` → `nodejs_24`.
- [ ] ringtail: `nix.settings.auto-optimise-store` → `nix.optimise.automatic = true;`
      (do the same on WSL)
- [ ] ringtail: fix the `boot.tmp.useTmpfs` comment. It is backwards: tmpfs on /tmp
      *increases* the out-of-space risk for big builds, since nix-daemon builds in
      /tmp. Fine with 64 GB of RAM.
- [ ] ringtail `configuration.nix` (not the generated hardware file):
      `fileSystems."/home/sakuk/Storage".options = [ "nofail" ];`
- [ ] `flake.nix`: `formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;`

### Install scripts (`flake.nix` packages)

- [ ] `import nixpkgs { system = ...; }` → `nixpkgs.legacyPackages.x86_64-linux`
- [ ] `writeShellScriptBin` → `writeShellApplication` with `runtimeInputs`
      (fzf, git, curl if still used, disko is run through `nix run`).
      This adds `set -euo pipefail` and runs shellcheck at build time. Fix whatever
      shellcheck flags (unquoted `${SYSTEMS[@]}`, `$DEVICE`, the awk quoting, ...).
- [ ] `freshinstall`: use `${./machines/disko-config.nix}` instead of curling it
      from `main` on GitHub, so the script and the layout come from the same commit.
- [ ] Swap sizing: the swap partition starts at 513M and *ends* at `${swap}G`, so it
      is about 0.5 GB smaller than chosen. Fix in `machines/disko-config.nix`
      (for example `end = "${toString (swap * 1024 + 513)}M"`, or use `size`).
- [ ] Drop `?submodules=1` from the `nixos-rebuild` / `nixos-install` flake refs and
      keep `--impure` and `--recurse-submodules`.
- [ ] `SYSTEMS` stays `("nixos-vm" "ringtail")` (WSL is not installed this way).

### README

- [ ] Rewrite for the current setup: hosts (ringtail, nixos-vm, wsl), repo layout
      (`machines/`, `modules/`, `homemodules/`, `dotfiles` submodule), the
      `install` / `freshinstall` scripts, day-to-day commands (`rebuild`,
      `nixupdate`, `nh clean`), why `--impure` is needed.
      Fix the stale bits: laptop mention, `~/nixos/.dotfiles`, the `#L117` line link.
      Keep the useful links (disko quickstart, flake templates).

### Verify commit 1

- [ ] All three hosts evaluate, with no warnings:
      `nix eval --impure --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
- [ ] Build ringtail without switching and diff it against the running system:
      `nix build --impure --no-link --print-out-paths .#nixosConfigurations.ringtail.config.system.build.toplevel`
      then `nvd diff /run/current-system <out>`. Only the expected changes should
      show up, and kernel/initrd/kernel-modules should be unchanged.
- [ ] `nix build .#install .#freshinstall` (shellcheck runs here).
- [ ] Stop. The user rebuilds and checks, then commits.

## Commit 2: mkHost + presets (pure refactor)

### Before touching anything

- [ ] Record the current drvPath of all three hosts. After the refactor they must
      be **identical**. Any hash change means behaviour changed, so find out why
      before going on.

### `machines/common.nix` (all hosts)

Everything the three hosts share: `nix.settings.experimental-features`,
`download-buffer-size`, `nix.optimise`, the user account (`isNormalUser`,
`description`, `shell = pkgs.zsh`, `wheel`), `nixpkgs.config.allowUnfree`,
NixOS-level neovim + `defaultEditor`, `programs.gnupg.agent`, `programs.mtr`,
`programs.nix-ld`.
Use `lib.mkDefault` for anything a host may override.
Only move settings that *all three* hosts already have, otherwise a hash changes.
Timezone and locale are deliberately **not** here: WSL does not want them
(see desktop.nix).

### `machines/desktop.nix` (ringtail + nixos-vm)

Timezone + locale + `extraLocaleSettings` (desktop only, WSL keeps the
defaults on purpose), SDDM + Plasma 6 (Wayland), pipewire, fonts + `defaultFonts`, printing,
firefox, autologin, `networkmanager` (+ the `networkmanager` group), and the
snapper config + tmpfiles rule. Host files keep only what is theirs
(bootloader, hostname, custom module toggles, host packages, guest agents,
`ringtails`/`makapakas` groups, bluetooth, firefox prefs, kdeconnect, ...).

### `mkHost` in `flake.nix`

```nix
mkHost = { hostname, unstable ? false, extraModules ? [ ] }: ...
nixosConfigurations = {
  ringtail = mkHost { hostname = "ringtail"; unstable = true; };
  nixos-vm = mkHost { hostname = "nixos-vm"; };
  wsl      = mkHost { hostname = "wsl"; extraModules = [ inputs.nixos-wsl.nixosModules.default ]; };
};
```

- [ ] `unstable` selects nixpkgs *and* home-manager together (they must match)
      and decides what the `pkgs.unstable` overlay points to.
- [ ] Always imports: `./machines/common.nix`, `./machines/${hostname}/configuration.nix`,
      `./modules`, the HM module with `useGlobalPkgs`, `useUserPackages`,
      `backupFileExtension = "hm-backup"`, `extraSpecialArgs`,
      `sharedModules = [ plasma-manager ]` (for every host) and
      `users.${username} = import ./machines/${hostname}/home.nix`.
- [ ] Remove the duplicate `../../modules` imports from the host files (WSL and
      the VM currently import `./modules` twice).
- [ ] WSL: drop the legacy `system = "x86_64-linux"` argument and set
      `nixpkgs.hostPlatform = "x86_64-linux";` in its configuration.nix.
- [ ] Remove the misplaced `rec` comment.
- [ ] `homemodules/wallpaper.nix`: plasma-manager is now always present, so replace
      the `hasPlasmaManager` probe with plain `programs.plasma = { ... };` inside the
      existing `mkIf`.
- [ ] Pass `hostname` through `specialArgs` (like nixos_cloud) if it is useful,
      for example for `networking.hostName` in common.nix. WSL's hostname comes from
      `wsl.wslConf.network.hostname`, so check what it evaluates to.

### Verify commit 2

- [ ] drvPaths of all three hosts identical to the recorded ones, no exceptions.
- [ ] Stop. The user rebuilds and checks, then commits.

## Known side effects to keep in mind

- Removing X11 also removed `ksshaskpass` (NixOS only wires `SSH_ASKPASS` when
  `services.xserver.enable` is true). If GUI tools stop prompting for SSH
  passphrases: `programs.ssh.enableAskPassword = true;`.
- The VM wallpaper now uses the ultrawide's colour order (logo shades swapped).

## Not doing (for now)

- Dropping `--impure` / making the flake pure.
- nix-flatpak (see above).
- Not urgent, if the user wants them later: the unused *system* flathub remote,
  and the empty leftover browser directories in `~/.var/app`.
