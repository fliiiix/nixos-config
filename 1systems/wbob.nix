{ config, pkgs, ... }:
{
  makefu.awesome = {
    modkey = "Mod1";
    baseConfig = pkgs.awesomecfg.kiosk;
  };
  imports =
    [ # Include the results of the hardware scan.
      ../.
      ../2configs/main-laptop.nix
    ];
  krebs = {
      enable = true;
      retiolum.enable = true;
      build.host = config.krebs.hosts.wbob;
  };
  networking.firewall.allowedUDPPorts = [ 1655 ];
  networking.firewall.allowedTCPPorts = [ 1655 ];
  services.tinc.networks.siem = {
    name = "display";
    extraConfig = ''
      ConnectTo = sjump
      Port = 1655
    '';
  };

  # rt2870.bin wifi card, part of linux-unfree
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  networking.wireless.enable = true;
  # rt2870 with nonfree creates wlp2s0 from wlp0s20u2
  # not explicitly setting the interface results in wpa_supplicant to crash
  networking.wireless.interfaces = [ "wlp2s0" ];


  # nuc hardware
  boot.loader.grub.device = "/dev/sda";
  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
  };

  # DualHead on NUC
  services.xserver = {
      # xrandrHeads = [ "HDMI1" "HDMI2" ];
      # prevent screen from turning off, disable dpms
      displayManager.sessionCommands = ''
        xset s off -dpms
        xrandr --output HDMI2 --right-of HDMI1
      '';
  };
  # TODO: update synergy package with these extras (username)
  # TODO: add crypto layer
  systemd.services."synergy-client" = {
    environment.DISPLAY = ":0";
    serviceConfig.User = "makefu";
  };

  services.synergy = {
    client = {
      enable = true;
      screenName = "wbob";
      serverAddress = "pornocauster.r";
    };
  };
}
