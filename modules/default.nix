_: {
  sshd = import ./sshd.nix;
  users = import ./users.nix;
  server = import ./server.nix;
  wireguard = import ./wireguard.nix;
  nix = import ./nix.nix;
  secret_config = import ./secret_config.nix;
  base = import ./base.nix;
}
