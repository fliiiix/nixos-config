{ config, lib, pkgs, ... }:

# search also generates ddclient entries for all other logs

with import <stockholm/lib>;
let
  ddclientUser = "ddclient";
  sec = toString <secrets>;
  nsupdate = import "${sec}/nsupdate-hub.nix";
  stateDir = "/var/spool/ddclient";
  cfg = "${stateDir}/cfg";
  ext-if = config.makefu.server.primary-itf;
  ddclientPIDFile = "${stateDir}/ddclient.pid";

  # TODO: correct cert generation requires a `real` internet ip address

  gen-cfg = dict: ''
    ssl=yes
    cache=${stateDir}/ddclient.cache
    pid=${ddclientPIDFile}
    ${concatStringsSep "\n" (mapAttrsToList (user: pass: ''

      protocol=dyndns2
      use=web, web=http://ipv4.nsupdate.info/myip
      ssl=yes
      server=ipv4.nsupdate.info
      login=${user}
      password='${pass}'
      ${user}

    '') dict)}
  '';
  uhubDir = "/var/lib/uhub";

in {
  users.extraUsers = singleton {
    name = ddclientUser;
    uid = genid "ddclient";
    description = "ddclient daemon user";
    home = stateDir;
    createHome = true;
  };

  systemd.services = {
    redis.serviceConfig.LimitNOFILE=10032;
    ddclient-nsupdate-uhub = {
      wantedBy = [ "multi-user.target" ];
      after = [ "ip-up.target" ];
      serviceConfig = {
        Type = "forking";
        User = ddclientUser;
        PIDFile = ddclientPIDFile;
        ExecStartPre = pkgs.writeDash "init-nsupdate" ''
          cp -vf ${pkgs.writeText "ddclient-config" (gen-cfg nsupdate)} ${cfg}
          chmod 700 ${cfg}
        '';
        ExecStart = "${pkgs.ddclient}/bin/ddclient -verbose -daemon 1 -noquiet -file ${cfg}";
      };
    };
  };

  networking.firewall.extraCommands = ''
    iptables -A PREROUTING -t nat -i ${ext-if} -p tcp --dport 411 -j REDIRECT --to-port 1511
  '';
  systemd.services.uhub.serviceConfig = {
    PrivateTmp = true;
    PermissionsStartOnly = true;
    ExecStartPre = pkgs.writeDash "uhub-pre" ''
      cp -f ${toString <secrets/wildcard.krebsco.de.crt>} ${uhubDir}/uhub.crt
      cp -f ${toString <secrets/wildcard.krebsco.de.key>} ${uhubDir}/uhub.key
      if test -d ${uhubDir};then
        echo "Directory ${uhubDir} already exists, skipping db init"
      else
        echo "Copying sql user db"
        cp ${toString <secrets/uhub.sql>} ${uhubDir}/uhub.sql
      fi
      chown -R uhub ${uhubDir}
    '';

  };
  users.users.uhub = {
    home = uhubDir;
    createHome = true;
  };
  services.uhub = {
    enable = true;
    port = 1511;
    enableTLS = true;
    hubConfig = ''
      hub_name = "krebshub"
      tls_certificate = ${uhubDir}/uhub.crt
      tls_private_key = ${uhubDir}/uhub.key
      registered_users_only = true
    '';
    plugins = {
      welcome = {
        enable = true;
        motd = "shareit";
        rules = "1. Don't be an asshole";
      };
      history = {
        enable = true;
      };
      authSqlite = {
        enable = true;
        file = "${uhubDir}/uhub.sql";
      };

    };
  };
  networking.firewall.allowedTCPPorts = [ 411 1511 ];
}
