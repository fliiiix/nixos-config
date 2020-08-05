{ config, lib, pkgs, ... }:

# fork of https://github.com/Mic92/dotfiles/blob/master/nixos/vms/modules/netdata.nix
with lib;
let
  cfg = config.makefu.netdata;
in
{
  options.makefu.netdata = {
    enable = mkEnableOption "netdata";

    # TODO only apikey from file, set remote host manually
    stream.file = mkOption {
      type = types.str;
      default = toString <secrets/netdata-stream.conf>;
      description = "path to stream data file";
    };
    stream.role = mkOption {
      type = types.enum [ "master" "slave" ];
      default = "slave";
      description = "Wether to stream data";
    };

    httpcheck.checks = mkOption {
      type = types.attrsOf (types.submodule ({
        options = {
          url = mkOption {
            type = types.str;
            example = "https://thalheim.io";
            description = "Url to check";
          };
          regex = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "My homepage";
            description = "Regex that is matched against the returned content";
          };
          statusAccepted = mkOption {
            type = types.listOf types.int;
            default = [ 200 ];
            example = [ 401 ];
            description = "Expected http status code";
          };
        };
      }));
      default = {};
      description = ''
        httpcheck plugin: https://github.com/netdata/netdata/blob/master/collectors/python.d.plugin/httpcheck/httpcheck.conf
      '';
    };

    portcheck.checks = mkOption {
      type = types.attrsOf (types.submodule ({
        options = {
          host = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Dns name/IP to check";
          };
          port = mkOption {
            type = types.int;
            description = "Tcp port number";
          };
        };
      }));
      default = {};
      description = ''
        portcheck plugin: https://github.com/netdata/netdata/tree/master/collectors/python.d.plugin/portcheck
      '';
    };
  };
  config = mkIf cfg.enable {
    systemd.services.netdata = {
      after = [
        config.krebs.secret.files.netdata-stream.service
      ];
      partOf = [
        config.krebs.secret.files.netdata-stream.service
      ];
    };
    krebs.secret.files.netdata-stream = {
      path = "/run/secret/netdata-stream.conf";
      owner.name = "netdata";
      source-path = cfg.stream.file;
    };
    environment.etc."netdata/stream.conf".source = "/run/secret/netdata-stream.conf";

    services.netdata = {
      enable = true;
      config = {
        global = {
          "bind to" = "0.0.0.0:19999 [::]:19999";
          "error log" = "stderr";
          "update every" = "5";
        };
        health.enable = if cfg.stream.role == "master" then "yes" else "no";
      };
    };
  services.netdata.python.extraPackages = ps: [
    ps.psycopg2 ps.docker ps.dnspython
  ];

    makefu.netdata.portcheck.checks.openssh.port = (lib.head config.services.openssh.ports);

    networking.firewall.allowedTCPPorts = [ 19999 ];

    environment.etc."netdata/python.d/httpcheck.conf".text = ''
    update_every: 30
    ${lib.concatStringsSep "\n" (mapAttrsToList (site: options:
    ''
      ${site}:
        url: '${options.url}'
        ${optionalString (options.regex != null) "regex: '${options.regex}'"}
        status_accepted: [ ${lib.concatStringsSep " " (map toString options.statusAccepted) } ]
      '') cfg.httpcheck.checks)
      }
    '';

    environment.etc."netdata/python.d/portcheck.conf".text = ''
    ${lib.concatStringsSep "\n" (mapAttrsToList (service: options:
    ''
      ${service}:
        host: '${options.host}'
        port: ${toString options.port}
      '') cfg.portcheck.checks)
      }
    '';
    systemd.services.netdata.restartTriggers = [
      config.environment.etc."netdata/python.d/httpcheck.conf".source
      config.environment.etc."netdata/python.d/portcheck.conf".source
      config.environment.etc."netdata/stream.conf".source
    ];

    environment.etc."netdata/health.d/httpcheck.conf".text = ''
      # taken from the original but warn only if a request is at least 300ms slow
      template: web_service_slow
      families: *
      on: httpcheck.responsetime
      lookup: average -3m unaligned of time
      units: ms
      every: 10s
      warn: ($this > ($1h_web_service_response_time * 4) && $this > 1000)
      crit: ($this > ($1h_web_service_response_time * 6) && $this > 1000)
      info: average response time over the last 3 minutes, compared to the average over the last hour
      delay: down 5m multiplier 1.5 max 1h
      options: no-clear-notification
      to: webmaster
    '';

  };
  # TODO: notification
  # environment.etc."netdata/health_alarm_notify.conf".source = "/run/keys/netdata-pushover.conf";

}
