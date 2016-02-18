{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
with config.krebs.lib;
let
  hostname = config.krebs.build.host.name;
  external-ip = head config.krebs.build.host.nets.internet.addrs4;
  wsgi-sock = "${config.services.uwsgi.runDir}/uwsgi.sock";
in {
  services.redis.enable = true;
  services.uwsgi = {
    enable = true;
    user = "nginx";
    plugins = [ "python2" ];
    instance = {
      type = "emperor";
      vassals = {
        mycube-flask = {
          type = "normal";
          python2Packages = self: with self; [ pkgs.mycube-flask flask redis werkzeug jinja2 markupsafe itsdangerous ];
          socket = wsgi-sock;
        };
      };
    };
  };

  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      mybox-connector-one = {
        listen = [ "${external-ip}:80" ];
        server-names = [
          "mycube.connector.one"
          "mybox.connector.one"
        ];
        locations = singleton (nameValuePair "/" ''
          uwsgi_pass unix://${wsgi-sock};
          uwsgi_param         UWSGI_CHDIR     ${pkgs.mycube-flask}/${pkgs.python.sitePackages};
          uwsgi_param         UWSGI_MODULE    mycube.websrv;
          uwsgi_param         UWSGI_CALLABLE  app;

          include ${pkgs.nginx}/conf/uwsgi_params;
        '');
      };
    };
  };
}
