{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
let
  hostname = config.krebs.build.host.name;
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  wsgi-sock = "${config.services.uwsgi.runDir}/uwsgi.sock";
in {
  services.redis = { enable = true; };
  systemd.services.redis.serviceConfig.LimitNOFILE=65536;

  services.uwsgi = {
    enable = true;
    user = "nginx";
    plugins = [ "python2" ];
    instance = {
      type = "emperor";
      vassals = {
        mycube-flask = {
          type = "normal";
          pythonPackages = self: with self; [ pkgs.mycube-flask ];
          socket = wsgi-sock;
        };
      };
    };
  };

  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."mybox.connector.one" = {
        locations = {
          "/".extraConfig = ''
          uwsgi_pass unix://${wsgi-sock};
          uwsgi_param         UWSGI_CHDIR     ${pkgs.mycube-flask}/${pkgs.python.sitePackages};
          uwsgi_param         UWSGI_MODULE    mycube.websrv;
          uwsgi_param         UWSGI_CALLABLE  app;

          include ${pkgs.nginx}/conf/uwsgi_params;
        '';
      };
    };
  };
}
