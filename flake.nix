{
  description = "Flufsor's NixOS config";

  outputs =
    {
      self,
      nixpkgs,
      agenix-rekey,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs lib.systems.flakeExposed (system: function nixpkgs.legacyPackages.${system});
    in
    {
      # all my hosts -> ./hosts
      nixosConfigurations =
        let
          hostNames = builtins.attrNames (
            lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./hosts)
          );
          baseModules = hostName: [
            ./hosts/${hostName}
            { networking.hostName = hostName; }
            (
              { lib, ... }:
              {
                options.nodes = lib.mkOption {
                  type =
                    with lib.types;
                    attrsOf (submoduleWith {
                      modules = [ { freeformType = anything; } ];
                    });
                  default = { };
                  description = "An attrs containing all NixOS configurations.";
                };
              }
            )
            self.nixosModules.secret_config
            inputs.agenix.nixosModules.default
            inputs.agenix-rekey.nixosModules.default
          ];
        in
        lib.genAttrs hostNames (
          hostName:
          nixpkgs.lib.nixosSystem {
            system = null;
            specialArgs = { inherit self lib inputs; };
            modules =
              baseModules hostName
              # evaluate all hosts & gather all instances of config.nodes.$hostName
              # so that attrs can be included as a module here
              ++ (lib.genAttrs hostNames (
                hostName:
                lib.concatMap
                  (
                    system:
                    let
                      cross = system.config.nodes.${hostName} or { };
                    in
                    lib.optional (cross != { }) cross
                  )
                  (
                    # evaluate once with nodes={} to avoid inf rec
                    # this way we can extract config.nodes.$hostName
                    lib.attrValues (
                      lib.genAttrs hostNames (
                        hostName:
                        nixpkgs.lib.nixosSystem {
                          system = null;
                          modules = baseModules hostName;
                          specialArgs = {
                            inherit self lib inputs;
                            nodes = { };
                          };
                        }
                      )
                    )
                  )
                # select this host's config from the nodes.* attrs
                # & include that as a module
              )).${hostName};
          }
        );

      # NixOS modules -> ./modules
      nixosModules = import ./modules { inherit inputs; };
      nixosProfiles = import ./profiles { inherit inputs; };

      rekeyConfig = {
        masterIdentities = [ "/home/flufsor/.ssh/id_ed25519" ];
        extraEncryptionPubkeys = [ (builtins.readFile "${self}/secrets/flufsor.pub") ];
      };

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        inherit (self) nixosConfigurations;
      };

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    nix-index-db = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:oddlama/agenix-rekey";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
