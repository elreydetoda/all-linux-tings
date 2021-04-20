#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

function get_latest_stable_version(){
  stable_version=$(
    curl -fsS "https://api.${base_domain}/repos/${org_name}/${proj_name}/tags" |
      jq -r '.[].name' |
      grep -vE 'alpha|beta' |
      sort -Vr | head -n 1
  )
}

function install_cue(){
  # https://github.com/cuelang/cue/releases/download/v0.3.2/cue_v0.3.2_linux_amd64.tar.gz
  install <(
    tar -Oxzvf <(
      curl -fsSL "https://${base_domain}/${org_name}/${proj_name}/releases/download/${stable_version}/cue_${stable_version}_linux_amd64.tar.gz"
    ) cue
  ) ./cue
  sudo mv ./cue /usr/local/bin/
}

function main(){
  base_domain='github.com'
  org_name='cuelang'
  proj_name='cue'
  get_latest_stable_version
  install_cue
}

# https://elrey.casa/bash/scripting/main
if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
