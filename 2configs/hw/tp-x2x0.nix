{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  imports = [
    ./tpm.nix
  ];

  boot.kernelModules = [
    "kvm-intel"
  ];

  networking.wireless.enable = lib.mkDefault true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  hardware.cpu.intel.updateMicrocode = true;

  zramSwap.enable = true;
  zramSwap.numDevices = 2;

  # enable synaptics so we can easily disable the touchpad
  #   enable the touchpad with `synclient TouchpadOff=0`

  services.xserver.libinput.enable = false;
  services.xserver.synaptics = {
    enable = true;
    additionalOptions = ''Option "TouchpadOff" "1"'';
  };
  hardware.trackpoint = {
    enable = true;
    sensitivity = 220;
    speed = 220;
    emulateWheel = true;
  };

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    # BUG: http://linrunner.de/en/tlp/docs/tlp-faq.html#erratic-battery
    START_CHARGE_THRESH_BAT0=67
    STOP_CHARGE_THRESH_BAT0=100


    CPU_SCALING_GOVERNOR_ON_AC=performance
    CPU_SCALING_GOVERNOR_ON_BAT=ondemand
    CPU_MIN_PERF_ON_AC=0
    CPU_MAX_PERF_ON_AC=100
    CPU_MIN_PERF_ON_BAT=0
    CPU_MAX_PERF_ON_BAT=30
  '';

  powerManagement.resumeCommands = ''
    ${pkgs.rfkill}/bin/rfkill unblock all
  '';
}
