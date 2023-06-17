{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "uas"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "mitigations=off" ];
  # kernelPackages = pkgs.linuxPackages_latest;      # <====  Remove # to enable to update to the latest kernel automatically, use at own risk!

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e465813a-xxxxxx";
    fsType = "ext4";
    # for ssd
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/mnt/nixos_share" = {
    device = "//192.168.0.20/LinuxData/HOME/PROFILES/NIXOS-23-05/TOLGA/";
    fsType = "cifs";
    options = let
      automount_opts =
        "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      uid = "1000";    # <========= Use sudo id <YOUR USERNAME> to establish your uid
      gid = "100";      # <========= Use sudo id <YOUR USERNAME> to establish your gid

    in [
      "${automount_opts},credentials=/etc/nixos/smb-secrets,uid=${uid},gid=${gid}"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp3s0.useDHCP = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
