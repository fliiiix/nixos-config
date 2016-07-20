#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../.
      ../2configs/main-laptop.nix #< base-gui + zsh
      ../2configs/laptop-utils.nix

      # Krebs
      #../2configs/disable_v6.nix


      # applications

      ../2configs/exim-retiolum.nix
      ../2configs/mail-client.nix
      ../2configs/printer.nix
      ../2configs/virtualization.nix
      ../2configs/virtualization-virtualbox.nix
      ../2configs/wwan.nix

      # services
      ../2configs/git/brain-retiolum.nix
      ../2configs/tor.nix
      ../2configs/steam.nix
      # ../2configs/buildbot-standalone.nix

      # hardware specifics are in here
      ../2configs/hw/tp-x220.nix
      ../2configs/hw/rtl8812au.nix
      # mount points
      ../2configs/fs/sda-crypto-root-home.nix
      # ../2configs/mediawiki.nix
      #../2configs/wordpress.nix
      ../2configs/nginx/public_html.nix

      ../2configs/tinc/retiolum.nix
      # temporary modules
      ../2configs/temp/share-samba.nix
      # ../2configs/temp/elkstack.nix
      # ../2configs/temp/sabnzbd.nix
    ];

  services.tinc.networks.siem = {
    name = "makefu";
    extraConfig = ''
      ConnectTo = sdarth
      ConnectTo = sjump
    '';
  };

  krebs.nginx = {
    default404 = false;
    servers.default.listen = [ "80 default_server" ];
    servers.default.server-names = [ "_" ];
  };

  environment.systemPackages = [ pkgs.passwdqc-utils pkgs.bintray-upload ];

  virtualisation.docker.enable = true;

  # configure pulseAudio to provide a HDMI sink as well
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 24800 ];
  networking.firewall.allowedUDPPorts = [ 665 ];

  krebs.build.host = config.krebs.hosts.pornocauster;
  krebs.hosts.omo.nets.retiolum.via.ip4.addr = "192.168.1.11";

  krebs.tinc.retiolum.connectTo = [ "omo" "gum" "prism" ];

  networking.extraHosts = ''
    192.168.1.11 omo.local
  '';
  # hard dependency because otherwise the device will not be unlocked
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; allowDiscards=true; }];
}
