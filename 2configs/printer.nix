{ config, pkgs, ... }:

let
  mainUser = config.krebs.build.user.name;
in {
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      samsungUnifiedLinuxDriver
      cups-dymo # dymo labelwriter
      foo2zjs # magicolor 1690mf
      cups-zj-58
    ];
  };

  # scanners are printers just in reverse anyway
  services.saned.enable = true;
  users.users."${mainUser}".extraGroups = [ "scanner" "lp" ];

  hardware.sane = {
    enable = true;
    extraBackends = [ ];

    # $ scanimage -p --format=jpg --mode=Gray --source="Automatic Document Feeder" -v --batch="lol%d.jpg" --resolution=150

    # requires 'sane-extra', scan via:
    #extraConfig."magicolor" = ''
    #  net 10.42.20.30 0x2098
    #''; # 10.42.20.30: uhrenkind.shack magicolor 1690mf
    extraConfig."xerox_mfp" = ''
      tcp 192.168.1.5
    ''; #home printer SCX-3205W
  };
}
