{
  self,
  lib,
  ...
}:
let
  m = self.nixosModules;
  p = self.nixosProfiles;
in
{
  imports = [
    ./disko.nix
    p.proxmox_vm
    m.server
    m.sshd
    m.users
    m.nix
    m.wireguard
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  users.flufsor = {
    createUser = true;
    nixTrusted = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 1 * 1024;
    }
  ];

  networking.nameservers = [ "10.0.120.1" ];

  systemd.network.networks."20-eth" = {
    matchConfig.MACAddress = "bc:24:11:db:2e:d9";
    address = [
      "10.0.120.60/24"
      "2a02:a03f:84fa:f302:554a:e89b:dc34:8127/64"
    ];
    routes = [
      { Gateway = "10.0.120.1"; }
      {
        Gateway = "fe80::aa9c:6cff:fe8e:2495";
        GatewayOnLink = true;
      }
    ];
    networkConfig = {
      IPv6AcceptRA = false;
      IPv6PrivacyExtensions = false;
    };
  };

  wireguard.wg0 = {
    address = [ "10.100.0.1/24" ];
    listenPort = 51820;
    # peers = [
    #   {
    #     publicKey = "<peer-public-key>";
    #     endpoint = "<peer-ip>:51820";
    #     allowedIPs = [ "10.100.0.2/32" ];
    #     persistentKeepalive = 25;
    #   }
    # ];
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
