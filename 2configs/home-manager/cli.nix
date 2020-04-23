{pkgs, ... }: {
  imports = [ ./zsh.nix ];
  home-manager.users.makefu = {
    programs.direnv = {
      stdlib = ''
use_nix() {
  local cache=".direnv.$(nixos-version --hash)"

  if [[ ! -e "$cache" ]] || \
    [[ "$HOME/.direnvrc" -nt "$cache" ]] || \
    [[ ".envrc" -nt "$cache" ]] || \
    [[ "default.nix" -nt "$cache" ]] || \
    [[ "shell.nix" -nt "$cache" ]];
  then
    local tmp="$(mktemp "$${cache}.tmp-XXXXXXXX")"
    trap "rm -rf '$tmp' >/dev/null" EXIT
    nix-shell --show-trace "$@" --run 'direnv dump' > "$tmp" && \
    mv "$tmp" "$cache"
  fi

  direnv_load cat "$cache"

  if [[ $# = 0 ]]; then
    watch_file default.nix
    watch_file shell.nix
    rm direnv.* 2>/dev/null
  fi
}
'';
      enableZshIntegration = true;
    };
  };
  services.udev.packages = [
    pkgs.libu2f-host
    pkgs.yubikey-personalization
  ];
}
