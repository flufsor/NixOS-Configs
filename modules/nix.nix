{ inputs, pkgs, ... }:
{
  imports = [ inputs.nix-index-db.nixosModules.nix-index ];
  config = {
    nix = {
      # see https://docs.lix.systems/manual/lix/stable/command-ref/conf-file.html for a list of options
      settings = {
        # use binary caches when available
        builders-use-substitutes = true;
        # only download binaries from a binary cache if it is signed with a key listed in nix.settings.trusted-public-keys
        require-sigs = true;
        # only allow these users/groups to connect to the Nix daemon
        allowed-users = [
          "root"
          "@wheel"
          "nix-builder"
        ];
        # allow wheel users to push unsigned store paths (needed for remote deploys)
        trusted-users = [
          "root"
          "@wheel"
          "nix-builder"
        ];
        # deduplicate nix store by hardlinking duplicate files
        auto-optimise-store = true;
        # when /nix/store disk space drops below [min-free] bytes, perform GC until [max-free] bytes are available or there is no more garbage
        min-free = "${toString (8 * 1024 * 1024 * 1024)}";
        max-free = "${toString (16 * 1024 * 1024 * 1024)}";
        # respect the xdg base spec please
        use-xdg-base-directories = true;
        # more logs
        log-lines = 30;
        # don't warn if git tree is dirty
        warn-dirty = false;
        # enable flakes, new Nix subcommands & allow Nix to execute builds inside cgroups
        experimental-features = "flakes nix-command";
        # never silently accept a random flake's config
        accept-flake-config = false;
      };
      # disable nix-channel command & state file creation
      channel.enable = false;
      # run Nix daemon on lowest priority to keep system responsible during builds & gc (thanks NotAShelf!)
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;
      # flake registries for nixpkgs unstable & stable, used by e.g. nix shell nixpkgs#hello
      registry = {
        n.flake = inputs.nixpkgs;
        stable.flake = inputs.stable;
      };
    };
    programs = {
      nix-index = {
        enable = true;
        # use the nix-index-database package
        package = inputs.nix-index-db.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-db;
        enableBashIntegration = false;
        enableZshIntegration = false;
        enableFishIntegration = false;
      };
      # wrap comma with nix-index-database & put it in $PATH
      nix-index-database.comma.enable = true;
      # this is a perl script in nixpkgs that relies on nix-channel... no thanks
      command-not-found.enable = false;
    };
  };
}
