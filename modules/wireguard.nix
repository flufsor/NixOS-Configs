{ config, lib, pkgs, ... }:
let
  cfg = config.wireguard;
in
{
  options.wireguard = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
      options = {
        address = lib.mkOption {
          description = "Address(es) for this tunnel";
          type = lib.types.listOf lib.types.str;
          example = [ "10.100.0.1/24" ];
        };
        listenPort = lib.mkOption {
          description = "UDP listen port";
          type = lib.types.port;
          default = 51820;
        };
        peers = lib.mkOption {
          description = "WireGuard peers";
          type = lib.types.listOf (lib.types.submodule {
            options = {
              publicKey = lib.mkOption {
                description = "Peer's public key";
                type = lib.types.str;
              };
              endpoint = lib.mkOption {
                description = "Peer endpoint (host:port)";
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              allowedIPs = lib.mkOption {
                description = "Allowed IPs for this peer";
                type = lib.types.listOf lib.types.str;
              };
              persistentKeepalive = lib.mkOption {
                description = "Persistent keepalive interval in seconds (0 to disable)";
                type = lib.types.int;
                default = 0;
              };
            };
          });
          default = [ ];
        };
      };
    }));
    default = { };
  };

  config = lib.mkIf (cfg != { }) {
    # reusable generator for wireguard private keys
    age.generators.wireguard-priv =
      {
        pkgs,
        lib,
        file,
        ...
      }:
      ''
        priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
        ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${
          lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")
        }
        echo "$priv"
      '';

    # generate a secret, netdev, network, and firewall rule per tunnel
    age.secrets = lib.mapAttrs' (name: _: lib.nameValuePair "wg-${name}" {
      generator.script = "wireguard-priv";
      mode = "640";
      owner = "systemd-network";
      group = "systemd-network";
    }) cfg;

    systemd.network.netdevs = lib.mapAttrs' (name: tunnel: lib.nameValuePair "90-${name}" {
      netdevConfig = {
        Name = name;
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets."wg-${name}".path;
        ListenPort = tunnel.listenPort;
        RouteTable = "main";
      };
      wireguardPeers = map (peer: {
        PublicKey = peer.publicKey;
        AllowedIPs = peer.allowedIPs;
      } // lib.optionalAttrs (peer.endpoint != null) {
        Endpoint = peer.endpoint;
      } // lib.optionalAttrs (peer.persistentKeepalive > 0) {
        PersistentKeepalive = peer.persistentKeepalive;
      }) tunnel.peers;
    }) cfg;

    systemd.network.networks = lib.mapAttrs' (name: tunnel: lib.nameValuePair "90-${name}" {
      matchConfig.Name = name;
      address = tunnel.address;
    }) cfg;

    networking.firewall.allowedUDPPorts = lib.mapAttrsToList (_: tunnel: tunnel.listenPort) cfg;
  };
}
