{
  self,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
  ];

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

  systemd.services.systemd-growfs-root.enable = true;

  services.qemuGuest.enable = true;
}
