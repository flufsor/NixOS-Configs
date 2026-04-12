{
  self,
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
{
  imports = with self.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    ./disko.nix
    server
    sshd
    users
    nix
  ];

  users.flufsor = {
    createUser = true;
    nixTrusted = true;
  };

  boot = {
    growPartition = true;
    initrd.availableKernelModules = [
        "virtio_pci"
        "virtio_net"
        "virtio_scsi"
        "virtio_blk"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 1 * 1024;
    }
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.useNetworkd = true;

  systemd = {
    network = {
      networks = {
        "20-eth" = {
          matchConfig.MACAddress = "bc:24:11:db:2e:d9";
          address = [
            "10.0.120.60/24"
            "2a02:a03f:850a:c001:554a:e89b:dc34:8127/64"
          ];
          routes = [
            { Gateway = "10.0.120.1"; }
            { Gateway = "fe80::aa9c:6cff:fe8e:2495"; GatewayOnLink = true; }
          ];
          networkConfig = {
            IPv6AcceptRA = false;
            IPv6PrivacyExtensions = false;
          };
        };
      };
    };
    services = {
      systemd-growfs-root = {
        enable = true;
      };
    };
  };

  services = {
    resolved = {
      enable = true;
      settings.Resolve = {
        DNS = [
          "10.0.120.1"
        ];
      };
    };
    qemuGuest.enable = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
