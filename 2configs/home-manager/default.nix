{
  imports = [ ];
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.makefu = {
    home.stateVersion = "19.03";
  };
  environment.variables = {
    GTK_DATA_PREFIX = "/run/current-system/sw";
  };
}
