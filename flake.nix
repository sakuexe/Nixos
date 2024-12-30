{
  description = "My Home Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
    in
    {

      # the rec keyword makes the set into a recursive set - this means that the values can reference each other
      # https://nix.dev/manual/nix/2.17/language/constructs
      # desktop pc - using the unstable branch of nixos
      nixosConfigurations.ringtail = nixpkgs-unstable.lib.nixosSystem rec {
        specialArgs = { inherit inputs userSettings; };

        modules = [
          # my own modules
          ./machines/desktop/configuration.nix
          ./machines/desktop/configuration.nix
          ./modules/gaming.nix
          ./modules/entertainment.nix
          ./modules/virtualization.nix
          ./modules/keyboard.nix

          # home manager
          inputs.home-manager-unstable.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
            home-manager.users."${specialArgs.userSettings.username}" = import ./home.nix;
          }
        ];
      };

      # laptop
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem rec {
        specialArgs = { inherit inputs userSettings; };

        modules = [
          ./machines/laptop/configuration.nix
          ./modules/virtualization.nix
          ./modules/keyboard.nix

          # module for taking care of the laptop hardware quirks
          inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503

          # home manager
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
            home-manager.users."${specialArgs.userSettings.username}" = import ./home.nix;
          }
        ];
      };

      # virtual machines
      nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem rec {
        specialArgs = { inherit inputs userSettings; };

        modules = [
          ./machines/nixos-vm/configuration.nix

          # home manager
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
            home-manager.users."${specialArgs.userSettings.username}" = import ./home.nix;
          }
        ];
      };

      # installation script
      # https://ertt.ca/nix/shell-scripts/
      packages.x86_64-linux.install =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          userHome = "/home/${userSettings.username}";
        in
        pkgs.writeShellScriptBin "install" ''
          SYSTEMS=("nixos-vm" "laptop" "desktop")
          echo "Installing Nixos setup from github:sakuexe/Nixos..."
          sleep 1
          echo "Choose a system to use (opens next)"
          sleep 3
          CHOICE=$(printf "%s\n" ''${SYSTEMS[@]} | "${pkgs.fzf}/bin/fzf")
          echo "$CHOICE was chosen, building..."
          ${pkgs.git}/bin/git clone --recurse-submodules -j8 https://github.com/sakuexe/nixos ${userHome}/Nixos
          cp /etc/nixos/hardware-configuration.nix ${userHome}/Nixos/machines/$CHOICE
          # rebuild
          nixos-rebuild switch --impure --flake ${userHome}/Nixos?submodules=1#$CHOICE
          # change the owner of the directory recursively
          chown -R ${userSettings.username} ${userHome}/Nixos
        '';

      # a fresh installation version, that would use disko
      # to format the disk to use btrfs and my preferred subvolume layout
      packages.x86_64-linux.freshinstall =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.writeShellScriptBin "freshinstall" ''
          GRAY="\033[0;37m"
          RESET="\033[0m"
          GREEN="\033[0;32m"
          RED="\033[0;31m"
          PURPLE="\033[0;35m"

          echo "Choose a storage device to install NixOS on..."
          sleep 3
          CHOICE=$(lsblk -nd -o NAME | \
          ${pkgs.fzf}/bin/fzf --preview 'lsblk /dev/{}')

          if [[ "$CHOICE" == "" ]]; then 
            echo -e "''${RED}no disk was chosen... Aborting.$RESET"
            exit 1
          fi

          echo -e $GRAY
          lsblk /dev/$CHOICE
          echo -e $RESET
          echo -e "The script will now format ''$PURPLE$CHOICE$RESET. This cannot be reverted"
          read -p "Continue? (y/N)" -r CONTINUE

          if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then 
            echo "Aborting installation, no changes have been made to the system"
            exit 0
          fi

          echo "cloning the configuration.nix and disko.nix files"
          curl https://raw.githubusercontent.com/sakuexe/Nixos/refs/heads/main/machines/disko-config.nix > disko.nix
          cat disko.nix
        '';
    };
}
