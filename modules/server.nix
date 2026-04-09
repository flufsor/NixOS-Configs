{
  self,
  pkgs,
  ...
}:
{
  imports = [
    self.nixosModules.base
  ];
  # not needed on servers
  # https://nixos.org/manual/nixpkgs/stable/#chap-multiple-output
  documentation = {
    enable = true;
    man.enable = true;
    doc.enable = false;
    dev.enable = false;
    info.enable = false;
    nixos.enable = false;
  };
  programs.bash.interactiveShellInit =
    # https://wiki.archlinux.org/title/Bash#History_customization
    ''
      HISTCONTROL=erasedups:ignoredups:ignorespace
      HISTFILESIZE=100000
      HISTSIZE=10000
    ''
    +
    # control + backspace -> remove word
    ''
      stty werase '^H'
    '';
  environment.systemPackages = with pkgs; [
  ];
}