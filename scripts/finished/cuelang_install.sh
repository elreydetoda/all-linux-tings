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
  cue_bin="$(curl -fsSL "https://${base_domain}/${org_name}/${proj_name}/releases/download/${stable_version}/${cue_archive}" | base64 -w 0)"
  current_checksum="$(curl -fsSL "https://${base_domain}/${org_name}/${proj_name}/releases/download/${stable_version}/checksums.txt" | grep linux_amd64 | awk '{print $1}')"
  bin_sha="$(base64 -d <<< "${cue_bin}" | sha256sum | awk '{print $1}')"

  diff -s <(echo "${bin_sha}") <(echo "${current_checksum}")

  install <( tar -Oxzvf <( base64 -d <<< "${cue_bin}" ) cue) ./cue
  sudo mv ./cue /usr/local/bin/
}

function main(){
  base_domain='github.com'
  org_name='cuelang'
  proj_name='cue'
  get_latest_stable_version
  cue_archive="cue_${stable_version}_linux_amd64.tar.gz"
  install_cue
}

# https://elrey.casa/bash/scripting/main
if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
