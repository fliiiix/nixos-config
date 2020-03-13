{ pkgs, ... }:{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/NUR/archive/7bfd0117b359d0f72d086ff7e1f0ba3aeaf8d91e.tar.gz";
      sha256 = "0gb2np1r2m9kkz1s374gxdqrwhkzx48iircy00y6mjr7h14rhyxk";
    }
  ){
      inherit pkgs;
    };
  };
}
