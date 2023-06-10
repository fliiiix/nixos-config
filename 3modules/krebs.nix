{ lib }:
# krebs emulation layer
{
  options = with lib.types;{
    krebs.hosts = mkOption {
      default = {};
      type =  attrsOf anything;
    };
    krebs.build = mkOption {
      default = {};
      type = attrsOf anything;
    };
    krebs.users = mkOption {
      default = {};
      type = attrsOf anything;
    };
  };
  config = {
    users.makefu = {
      name = "makefu";
      mail = "makefu@x.r";
      pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCl3RTOHd5DLiVeUbUr/GSiKoRWknXQnbkIf+uNiFO+XxiqZVojPlumQUVhasY8UzDzj9tSDruUKXpjut50FhIO5UFAgsBeMJyoZbgY/+R+QKU00Q19+IiUtxeFol/9dCO+F4o937MC0OpAC10LbOXN/9SYIXueYk3pJxIycXwUqhYmyEqtDdVh9Rx32LBVqlBoXRHpNGPLiswV2qNe0b5p919IGcslzf1XoUzfE3a3yjk/XbWh/59xnl4V7Oe7+iQheFxOT6rFA30WYwEygs5As//ZYtxvnn0gA02gOnXJsNjOW9irlxOUeP7IOU6Ye3WRKFRR0+7PS+w8IJLag2xb makefu@x";
    };
  }
}
