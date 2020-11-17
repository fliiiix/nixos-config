{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  ext-if = config.makefu.server.primary-itf;
  allDisks = [ "/dev/sda" "/dev/sdb" ];
in {
  imports = [
      <stockholm/makefu>
      ./hardware-config.nix
      {
        users.users.lass = {
          uid = 19002;
          isNormalUser = true;
          createHome = true;
          useDefaultShell = true;
          openssh.authorizedKeys.keys = with config.krebs.users; [
            lass.pubkey
            makefu.pubkey
          ];
        };
      }
      <stockholm/makefu/2configs/nur.nix>
      <stockholm/makefu/2configs/support-nixos.nix>
      <stockholm/makefu/2configs/home-manager>
      <stockholm/makefu/2configs/home-manager/cli.nix>
      # <stockholm/makefu/2configs/stats/client.nix>
      # <stockholm/makefu/2configs/stats/netdata-server.nix>

      <stockholm/makefu/2configs/headless.nix>
      <stockholm/makefu/2configs/smart-monitor.nix>
      { services.smartd.devices = builtins.map (x: { device = x; }) allDisks; }

      # Security
      <stockholm/makefu/2configs/sshd-totp.nix>

      # Tools
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/dev.nix>
      <stockholm/makefu/2configs/tools/sec.nix>
      <stockholm/makefu/2configs/tools/desktop.nix>

      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/mosh.nix>
      # <stockholm/makefu/2configs/gui/xpra.nix>

      # networking
      <stockholm/makefu/2configs/vpn/openvpn-server.nix>
      # <stockholm/makefu/2configs/vpn/vpnws/server.nix>
      #<stockholm/makefu/2configs/dnscrypt/server.nix>
      <stockholm/makefu/2configs/iodined.nix>
      # <stockholm/makefu/2configs/backup.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      { # bonus retiolum config for connecting more hosts
        krebs.tinc.retiolum = {
          extraConfig = ''
            ListenAddress = ${external-ip} 53
            ListenAddress = ${external-ip} 655
            ListenAddress = ${external-ip} 21031
          '';
          connectTo = [
            "prism" "ni" "enklave" "eve" "archprism"
          ];
        };
        networking.firewall = {
          allowedTCPPorts =
          [
            53
            655
            21031
          ];
          allowedUDPPorts =
          [
            53
            655
            21031
          ];
        };
      }

      # ci
      # <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/git/cgit-retiolum.nix>

      ###### Shack #####
      # <stockholm/makefu/2configs/shack/events-publisher>
      # <stockholm/makefu/2configs/shack/gitlab-runner>


      <stockholm/makefu/2configs/remote-build/slave.nix>
      <stockholm/makefu/2configs/remote-build/aarch64-community.nix>
      <stockholm/makefu/2configs/taskd.nix>

      # services
      # <stockholm/makefu/2configs/sabnzbd.nix>
      # <stockholm/makefu/2configs/mail/mail.euer.nix>
      { krebs.exim.enable = mkDefault true; }

      # sharing
      <stockholm/makefu/2configs/share/gum.nix>
      <stockholm/makefu/2configs/torrent.nix>
      <stockholm/makefu/2configs/sickbeard>

      { nixpkgs.config.allowUnfree = true; }
      #<stockholm/makefu/2configs/retroshare.nix>
      ## <stockholm/makefu/2configs/ipfs.nix>
      #<stockholm/makefu/2configs/syncthing.nix>
      # <stockholm/makefu/2configs/opentracker.nix>


      ## network
      <stockholm/makefu/2configs/vpn/openvpn-server.nix>
      # <stockholm/makefu/2configs/vpn/vpnws/server.nix>
      <stockholm/makefu/2configs/binary-cache/server.nix>
      <stockholm/makefu/2configs/backup/server.nix>
      <stockholm/makefu/2configs/iodined.nix>
      <stockholm/makefu/2configs/bitlbee.nix>
      <stockholm/makefu/2configs/wireguard/server.nix>
      <stockholm/makefu/2configs/wireguard/wiregrill.nix>

      # Removed until move: no extra mails
      # <stockholm/makefu/2configs/urlwatch>
      # Removed until move: avoid letsencrypt ban
      ### Web
      <stockholm/makefu/2configs/nginx/dl.euer.krebsco.de.nix>
      #<stockholm/makefu/2configs/nginx/euer.test.nix>
      <stockholm/makefu/2configs/nginx/euer.mon.nix>
      <stockholm/makefu/2configs/nginx/euer.wiki.nix>
      <stockholm/makefu/2configs/nginx/euer.blog.nix>
      ## <stockholm/makefu/2configs/nginx/gum.krebsco.de.nix>
      #<stockholm/makefu/2configs/nginx/public_html.nix>
      #<stockholm/makefu/2configs/nginx/update.connector.one.nix>
      <stockholm/makefu/2configs/nginx/misa-felix-hochzeit.ml.nix>
      # <stockholm/makefu/2configs/nginx/gold.krebsco.de.nix>
      # <stockholm/makefu/2configs/nginx/iso.euer.nix>

      # <stockholm/makefu/2configs/deployment/photostore.krebsco.de.nix>
      <stockholm/makefu/2configs/deployment/graphs.nix>
      <stockholm/makefu/2configs/deployment/owncloud.nix>
      <stockholm/makefu/2configs/deployment/board.euer.krebsco.de.nix>
      <stockholm/makefu/2configs/deployment/rss.euer.krebsco.de.nix>
      #<stockholm/makefu/2configs/deployment/feed.euer.krebsco.de>
      <stockholm/makefu/2configs/deployment/boot-euer.nix>
      <stockholm/makefu/2configs/deployment/gecloudpad>
      <stockholm/makefu/2configs/deployment/docker/archiveteam-warrior.nix>
      <stockholm/makefu/2configs/deployment/docker/etherpad.euer.krebsco.de.nix>
      <stockholm/makefu/2configs/shiori.nix>

      <stockholm/makefu/2configs/bgt/download.binaergewitter.de.nix>
      <stockholm/makefu/2configs/bgt/hidden_service.nix>
      <stockholm/makefu/2configs/bgt/backup.nix>

      # <stockholm/makefu/2configs/logging/client.nix>

      # sharing
      <stockholm/makefu/2configs/dcpp/airdcpp.nix>
      { krebs.airdcpp.dcpp.shares = {
          download.path = config.makefu.dl-dir + "/finished";
          sorted.path = config.makefu.dl-dir + "/sorted";
        };
      }
      <stockholm/makefu/2configs/dcpp/hub.nix>

      ## Temporary:
      # <stockholm/makefu/2configs/temp/rst-issue.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>
      <stockholm/makefu/2configs/virtualisation/libvirt.nix>

      # krebs infrastructure services
      <stockholm/makefu/2configs/stats/server.nix>
    ];

  makefu.dl-dir = "/var/download";

  services.openssh.hostKeys = lib.mkForce [
    { bits = 4096; path = (toString <secrets/ssh_host_rsa_key>); type = "rsa"; }
    { path = (toString <secrets/ssh_host_ed25519_key>); type = "ed25519"; } ];
  ###### stable

  services.nginx.virtualHosts."cgit.euer.krebsco.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost/";
    locations."/".extraConfig = ''proxy_set_header Host cgit;'';
  };

  krebs.build.host = config.krebs.hosts.gum;

  # Network
  networking = {
    firewall = {
        allowPing = true;
        logRefusedConnections = false;
    };
    nameservers = [ "8.8.8.8" ];
  };
  users.users.makefu.extraGroups = [ "download" "nginx" ];
  state = [ "/home/makefu/.weechat" ];
}
