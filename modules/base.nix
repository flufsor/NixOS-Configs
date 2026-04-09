{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ];
  boot = {
    # clean /tmp on boot because I fill it with random crap
    tmp.cleanOnBoot = true;
    # kernel console loglevel
    consoleLogLevel = 0;
    loader = {
      # hold any key (e.g. space) to show boot menu
      timeout = 0;
      # whether to copy necessary boot files to /boot (/nix/store is not needed by boot loader)
      generationsDir.copyKernels = true;
    };
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
  };
  time.timeZone = "Europe/Brussels";
  security.sudo.package = pkgs.sudo.override { withInsults = true; };
  services.dbus.implementation = "broker";
  i18n = {
    # apparently we can't have nice things in glibc
    # https://www.localeplanet.com/icu/en-150/index.html
    # https://sourceware.org/bugzilla/show_bug.cgi?id=22473
    # defaultLocale = "en_150.UTF-8/UTF-8";
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
    ];
    # https://sourceware.org/glibc/wiki/Locales
    extraLocaleSettings = {
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      # interpretation of sequences of bytes of text data characters, classification of characters, etc.
      LC_CTYPE = "en_US.UTF-8";
      # collation rules
      LC_COLLATE = "en_IE.UTF-8";
      # affirmative & negative responses for messages and menus
      LC_MESSAGES = "en_IE.UTF-8";
      # monetary-related formatting
      LC_MONETARY = "en_IE.UTF-8";
      # nonmonetary numeric formatting
      LC_NUMERIC = "en_IE.UTF-8";
      # date & time formatting
      LC_TIME = "de_DE.UTF-8";
      # not set here: paper, name, address, telephone, measurement, identification
    };
  };
  networking = {
    useNetworkd = false;
    useDHCP = false;
    dhcpcd.enable = false;
    resolvconf.enable = false;
    firewall.enable = true;
    nftables.enable = true;
  };
  systemd = {
    # https://www.openwall.com/lists/oss-security/2025/12/28/4
    generators.systemd-ssh-generator = "/dev/null";
    sockets.sshd-unix-local.enable = lib.mkForce false;
    sockets.sshd-vsock.enable = lib.mkForce false;
  };
  services = {
    resolved = {
      enable = true;
      settings.Resolve = {
        Domains = [ "~." ];
        FallbackDNS = [
          "1.1.1.1#cloudflare-dns.com"
          "8.8.8.8#dns.google"
          "1.0.0.1#cloudflare-dns.com"
          "8.8.4.4#dns.google"
          "2606:4700:4700::1111#cloudflare-dns.com"
          "2001:4860:4860::8888#dns.google"
          "2606:4700:4700::1001#cloudflare-dns.com"
          "2001:4860:4860::8844#dns.google"
        ];
        LLMNR = "false"; # link-local multicast name resolution (RFC 4795)
      };
    };
    # network time protocol
    ntpd-rs.enable = true;
    # periodic SSD TRIM
    fstrim = {
      enable = true;
      interval = "weekly";
    };
  };
  environment = {
    defaultPackages = lib.mkForce [ ];
    systemPackages = with pkgs; [
      git
      vim
      openssl
      gnupg
      ripgrep
      dig
      strace
      psmisc
      tree
      file
      which
      btop
    ];
  };
}