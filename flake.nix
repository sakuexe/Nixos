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

  outputs = { 
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    home-manager-unstable,
    ... }@inputs:
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

      system = "x86_64-linux";
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
        home-manager-unstable.nixosModules.home-manager
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
      system = "x86_64-linux";
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
    nixosConfigurations.vm-nix = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs userSettings; };

      modules = [
        ./machines/vm/configuration.nix

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
    packages.x86_64-linux.install = 
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        userHome = "/home/${userSettings.username}";
      in 
      pkgs.writeShellScriptBin "install" ''
          echo "Installing Nixos setup from github:sakuexe/Nixos..."
          sleep 1
          ${pkgs.git}/bin/git clone --recurse-submodules -j8 https://github.com/sakuexe/nixos ${userHome}/Nixos
          cp /etc/nixos/hardware-configuration.nix ${userHome}/Nixos/machines/vm
          # rebuild
          nixos-rebuild switch --impure --flake ${userHome}/Nixos?submodules=1#vm-nix
      '';
  };
}
