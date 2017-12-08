{config, ... }:{
  networking.firewall.allowedUDPPorts = [ 137 138 ];
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  users.users.smbguest = {
    name = "smbguest";
    uid = config.ids.uids.smbguest;
    description = "smb guest user";
    home = "/home/share";
    createHome = true;
  };
  services.samba = {
    enable = true;
    enableNmbd = true;
    shares = {
      incoming = {
        path = "/data/incoming";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "yes";
      };
      data = {
        path = "/data/";
        "read only" = "yes";
        browseable = "yes";
        "guest ok" = "yes";
      };
    };
    extraConfig = ''
      guest account = smbguest
      map to guest = bad user
      # disable printing
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
    '';
  };
}
