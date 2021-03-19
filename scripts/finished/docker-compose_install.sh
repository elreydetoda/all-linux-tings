#!/usr/bin/env bash

# http://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# https://git.io/Jmr0O

function get_latest_version(){
  latest_version="$(curl -fsS -o /dev/null -w '%{redirect_url}' "${latest_url}" | grep -oP '\d+\.\d+\.\d+')"
}

function download_latest(){
  install <(curl -fsSLo - "${release_url}/download/${latest_version}/${file_to_download}") /usr/local/bin/docker-compose
}

# http://elrey.casa/bash/scripting/main
function main(){
  base_url='https://github.com'
  repo_url="${base_url}/docker/compose"
  release_url="${repo_url}/releases"
  latest_url="${release_url}/latest"
  file_to_download="docker-compose-$(uname -s)-$(uname -m)"

  get_latest_version
  download_latest
}

if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
