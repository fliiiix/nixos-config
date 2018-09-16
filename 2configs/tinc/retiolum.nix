{ pkgs, ... }:
{
  imports = [
    ../binary-cache/lass.nix
  ];
  krebs.tinc.retiolum.enable = true;
  environment.systemPackages = [ pkgs.tinc ];
}
