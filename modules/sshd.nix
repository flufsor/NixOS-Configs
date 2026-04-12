{
  lib,
  ...
}:
{
  services.openssh = {
    # enable OpenSSH daemon
    enable = true;
    # port on which SSH daemon listens
    ports = [ 22 ];
    # automatically open firewall
    openFirewall = true;
    # text shown upon connecting
    banner = "\n\tThe great gates have been sealed.\n\t\tNone shall enter.\n\t\tNone shall leave.\n\n\n";
    # some security stuff
    settings = {
      X11Forwarding = false;
      UseDns = false;
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # only use strong ciphers
      Ciphers = [
         "chacha20-poly1305@openssh.com"
         "aes256-gcm@openssh.com"
         "aes128-gcm@openssh.com"
      ];
      # only use post-quantum key exchange algorithms
      KexAlgorithms = [
        "sntrup761x25519-sha512"
        "sntrup761x25519-sha512@openssh.com"
        "mlkem768x25519-sha256"
      ];
    };
    hostKeys = [
      {
        type = "rsa";
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
      }
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
      }
    ];
  };
}