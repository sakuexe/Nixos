{
  description = "My Home Flake";
  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # use the follows attribute to use the same dependencies as nixpkgs
      # this way there wont be unnecessary duplications and inconsistensies
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }@inputs:
    let
      # changing these changes all the builds
      userSettings = {
        username = "sakuk";
        description = "Saku Karttunen";
        email = "saku.karttunen@gmail.com";
      };

      # pkgs.unstable for hosts on the stable branch, so single packages can be pulled from unstable
      # hosts already on unstable just point it at their own pkgs (no second nixpkgs instance)
      unstableOverlay = onUnstable: {
        nixpkgs.overlays = [
          (final: prev: {
            unstable =
              if onUnstable then
                final
              else
                import nixpkgs-unstable {
                  inherit (final.stdenv.hostPlatform) system;
                  config = final.config;
                };
          })
        ];
      };

      # unstable selects nixpkgs and home-manager together (they must match)
      mkHost =
        {
          hostname,
          unstable ? false,
          extraModules ? [ ],
        }:
        let
          nixpkgs' = if unstable then nixpkgs-unstable else nixpkgs;
          home-manager' = if unstable then inputs.home-manager-unstable else home-manager;
          specialArgs = { inherit inputs userSettings hostname; };
        in
        nixpkgs'.lib.nixosSystem {
          inherit specialArgs;
          modules = extraModules ++ [
            ./machines/common.nix
            # the config name is the hostname, so nh / nixos-rebuild pick the right config by default
            # (on WSL this also sets wsl.wslConf.network.hostname)
            { networking.hostName = hostname; }
            ./machines/${hostname}/configuration.nix
            ./modules
            (unstableOverlay unstable)

            # home manager
            home-manager'.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              # plasma-manager does nothing unless programs.plasma.enable is set
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
              home-manager.users.${userSettings.username} = import ./machines/${hostname}/home.nix;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        # desktop pc - using the unstable branch of nixos
        ringtail = mkHost {
          hostname = "ringtail";
          unstable = true;
        };
        # virtual machine for testing
        nixos-vm = mkHost { hostname = "nixos-vm"; };
        # wsl (for the work windows laptop)
        wsl = mkHost {
          hostname = "wsl";
          extraModules = [ inputs.nixos-wsl.nixosModules.default ];
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

      # installation script
      # https://ertt.ca/nix/shell-scripts/
      packages.x86_64-linux.install =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          userHome = "/home/${userSettings.username}";
        in
        pkgs.writeShellApplication {
          name = "install";
          runtimeInputs = with pkgs; [
            fzf
            git
          ];
          text = ''
            SYSTEMS=("nixos-vm" "ringtail")
            echo "Installing Nixos setup from github:sakuexe/Nixos..."
            sleep 1
            echo "Choose a system to use (opens next)"
            sleep 3
            CHOICE=$(printf "%s\n" "''${SYSTEMS[@]}" | fzf) || true
            if [[ -z "$CHOICE" ]]; then
              echo "No system was chosen. Aborting."
              exit 1
            fi
            echo "$CHOICE was chosen, building..."
            git clone --recurse-submodules -j8 https://github.com/sakuexe/Nixos "${userHome}/Nixos"
            cp /etc/nixos/hardware-configuration.nix "${userHome}/Nixos/machines/$CHOICE"
            # rebuild
            nixos-rebuild switch --flake "${userHome}/Nixos#$CHOICE"
            # change the owner of the directory recursively
            chown -R ${userSettings.username} "${userHome}/Nixos"
          '';
        };

      # a fresh installation version, that would use disko
      # to format the disk to use btrfs and my preferred subvolume layout
      packages.x86_64-linux.freshinstall =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          userHome = "/home/${userSettings.username}";
        in
        pkgs.writeShellApplication {
          name = "freshinstall";
          runtimeInputs = with pkgs; [
            fzf
            git
            util-linux # lsblk, findmnt (the safety checks rely on these)
          ];
          text = ''
            GRAY="\033[0;37m"
            RESET="\033[0m"
            RED="\033[0;31m"
            PURPLE="\033[0;35m"
            SYSTEMS=("nixos-vm" "ringtail")

            # safety: this script wipes a disk, so only ever run it from the NixOS live installer.
            # the installer runs from a tmpfs root with the boot media mounted at /iso,
            # an installed system never has either.
            if [[ "$(findmnt -n -o FSTYPE /)" != "tmpfs" ]] || ! findmnt -n /iso > /dev/null; then
              echo -e "''${RED}Not running from the NixOS live installer. Refusing to touch any disk.$RESET"
              exit 1
            fi

            echo "Choose a storage device to install NixOS on..."
            sleep 3
            DEVICE=$(lsblk -nd -o NAME | fzf --preview 'lsblk /dev/{}') || true

            if [[ -z "$DEVICE" ]]; then
              echo -e "''${RED}No disk was chosen. Aborting.$RESET"
              exit 1
            fi
            DEVICE="/dev/$DEVICE"

            # safety: never format a disk that has something mounted (for example the installer usb itself)
            if [[ -n "$(lsblk -n -o MOUNTPOINTS "$DEVICE" | tr -d '[:space:]')" ]]; then
              echo -e "''${RED}$DEVICE has mounted partitions. Refusing to format it.$RESET"
              lsblk -o NAME,SIZE,MOUNTPOINTS "$DEVICE"
              exit 1
            fi

            echo -e "$GRAY"
            lsblk "$DEVICE"
            echo -e "$RESET"
            echo -e "The script will now format $PURPLE$DEVICE$RESET. This cannot be reverted"
            # safety: a reflexive "y" is too easy, make the disk be typed out in full
            read -p "Type the full device path ($DEVICE) to continue: " -r CONTINUE || true

            if [[ "$CONTINUE" != "$DEVICE" ]]; then
              echo "Aborting installation, no changes have been made to the system"
              exit 0
            fi

            CHOICE=$(printf "%s\n" "''${SYSTEMS[@]}" | fzf) || true
            if [[ -z "$CHOICE" ]]; then
              echo -e "''${RED}No system was chosen. Aborting.$RESET"
              exit 1
            fi

            # whole gigabytes only, disko gets the size as a nix integer
            MEM=$(free --giga | awk '/^Mem:/ {print $2}')
            SWAP=("$MEM" "$((MEM / 2))" 2)
            SWAP_CHOICE=$(printf "%s\n" "''${SWAP[@]}" \
              | fzf --preview "echo 'setting the SWAP partition to {}G'") || true
            if [[ -z "$SWAP_CHOICE" ]]; then
              echo -e "SWAP is required. Using the default of $PURPLE'8G'$RESET"
              SWAP_CHOICE="8"
              sleep 3
            fi

            echo -e "Formatting device $PURPLE$DEVICE$RESET..."
            # the disk layout comes from the same commit as this script, disko is pinned by flake.lock.
            # no --yes-wipe-all-disks on purpose: disko asks for its own confirmation before destroying
            sudo ${pkgs.disko}/bin/disko \
              --mode destroy,format,mount ${./machines/disko-config.nix} --argstr disk "$DEVICE" --arg swap "$SWAP_CHOICE"

            sudo nixos-generate-config --root /mnt
            # /mnt is owned by root, clone as the current user (uid 1000, same as the installed user)
            sudo mkdir -p "/mnt${userHome}"
            sudo chown "$(id -u):$(id -g)" "/mnt${userHome}"
            git clone --recurse-submodules -j8 https://github.com/sakuexe/Nixos "/mnt${userHome}/Nixos"

            sudo mv /mnt/etc/nixos/hardware-configuration.nix "/mnt${userHome}/Nixos/machines/$CHOICE"

            # the config reads the dotfiles from ${userHome}/Nixos,
            # so make that path exist on the live system too
            sudo mkdir -p "${userHome}"
            sudo ln -sfn "/mnt${userHome}/Nixos" "${userHome}/Nixos"

            sudo nixos-install --flake "/mnt${userHome}/Nixos#$CHOICE"
          '';
        };
    };
}
