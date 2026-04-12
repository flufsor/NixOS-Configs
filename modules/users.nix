{ lib, config, ... }:
{
  options.users = lib.attrsets.genAttrs [ "flufsor" ] (user: {
    createUser = lib.options.mkOption {
      description = "Whether to create user ${user}";
      type = lib.types.bool;
      default = false;
    };
    nixTrusted = lib.options.mkOption {
      description = "Whether to add user ${user} to nix.settings.trusted-users";
      type = lib.types.bool;
      default = false;
    };
  });
  config = {
    nix.settings.trusted-users = lib.mkIf config.users.flufsor.nixTrusted [ "flufsor" ];
    users = {
      mutableUsers = false;
      users = {
        # no root login allowed
        root.hashedPassword = "!";
        # create users according to config.users
        flufsor = lib.mkIf config.users.flufsor.createUser {
          isNormalUser = true;
          hashedPassword = "$y$j9T$yp88zrq25ZzUzqWlkgvyb0$2bPwxBC.ldz8HZqdBuOzgBz5AJPZS/cNpV17u3N9YO/";
          extraGroups = [
            "wheel"
            "input"
            "video"
            "audio"
            "systemd-journal"
          ]
          ++ builtins.filter (g: builtins.hasAttr g config.users.groups) [
            "libvirtd"
            "networkmanager"
            "docker"
            "podman"
            "wireshark"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJoALKNbxiuAqWOqz9nDMBl8nBDUNfhzDSC8TFXH92de flufsor@Mephisto"
          ];
        };
      };
    };
  };
}
