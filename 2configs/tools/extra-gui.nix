{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs;[
    # media
    gimp
    # mirage - last time available in 19.09
    inkscape
    libreoffice
    # skype
    teams
    synergy
    tdesktop
    virtmanager
    jellyfin-media-player
    # Dev
    saleae-logic
    gitAndTools.gitFull
    signal-desktop
    element-desktop
    # rambox

    vscode

    # 3d Modelling
    chitubox
    freecad
  ];
}
