{config, pkgs, lib, ...}:
with <stockholm/lib>;
let
  selenium-pw = <secrets/selenium-vncpasswd>;
in {
  services.jenkinsSlave.enable = true;
  users.users.selenium = {
    uid = genid "selenium";
    extraGroups = [ "plugdev" ];
  };

  fonts.enableFontDir = true;

  # networking.firewall.allowedTCPPorts = [ 5910 ];

  systemd.services.selenium-X11 =
  {
    description = "X11 vnc for selenium";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.xorg.xorgserver pkgs.tightvnc pkgs.dwm ];
    environment =
    {
      DISPLAY = ":10";
    };
    script = ''
      set -ex
      [ -e /tmp/.X10-lock ] && ( set +e ; chmod u+w /tmp/.X10-lock ; rm /tmp/.X10-lock )
      [ -e /tmp/.X11-unix/X10 ] && ( set +e ; chmod u+w /tmp/.X11-unix/X10 ; rm /tmp/.X11-unix/X10 )
      mkdir -p ~/.vnc
      cp -f ${selenium-pw} ~/.vnc/passwd
      chmod go-rwx ~/.vnc/passwd
      echo > ~/.vnc/xstartup
      chmod u+x ~/.vnc/xstartup
      vncserver $DISPLAY -geometry 1280x1024 -depth 24 -name jenkins -ac
      dwm
    '';
    preStop = ''
      vncserver -kill $DISPLAY
    '';
    serviceConfig = {
      User = "selenium";
    };
  };

  systemd.services.selenium-server =
  {
    description = "selenium-server";
    wantedBy = [ "multi-user.target" ];
    requires = [ "selenium-X11.service" ];
    path = [ pkgs.chromium
             pkgs.firefoxWrapper ];
    environment =
    {
      DISPLAY = ":10";
    };
    script = ''
      ${pkgs.selenium-server-standalone}/bin/selenium-server -Dwebdriver.enable.native.events=1
    '';
    serviceConfig = {
      User = "selenium";
    };
  };


}
