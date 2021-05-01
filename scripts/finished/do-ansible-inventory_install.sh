#!/usr/bin/env bash

# http://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# https://git.io/JOdWr

function get_latest_version(){
  latest_version="$(curl -fsS -o /dev/null -w '%{redirect_url}' "${latest_url}" | grep -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]')"
}

function download_latest(){
  install <(
    tar -Oxzxf <(
      curl -fsSLo - "${release_url}/download/v${latest_version}/${file_to_download}"
    ) do-ansible-inventory
  ) /usr/local/bin/do-ansible-inventory
}

# http://elrey.casa/bash/scripting/main
function main(){
  base_url='https://github.com'
  repo_url="${base_url}/do-community/do-ansible-inventory"
  release_url="${repo_url}/releases"
  latest_url="${release_url}/latest"

  get_latest_version

  file_to_download="do-ansible-inventory_${latest_version}_$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m).tar.gz"

  download_latest
}

if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
