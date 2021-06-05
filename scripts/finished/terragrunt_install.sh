#!/usr/bin/env bash

# http://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# https://git.io/JGHjf

function get_latest_version(){
  latest_version="$(curl -fsS -o /dev/null -w '%{redirect_url}' "${latest_url}" | grep -oP '\d+\.\d+\.\d+')"
}

function download_latest(){
  install <(curl -fsSLo - "${release_url}/download/v${latest_version}/${file_to_download}") /usr/local/bin/terragrunt
}

# http://elrey.casa/bash/scripting/main
function main(){
  base_url='https://github.com'
  repo_url="${base_url}/gruntwork-io/terragrunt"
  release_url="${repo_url}/releases"
  latest_url="${release_url}/latest"

  case $(uname -m) in
    x86_64)
        arch='amd64'
      ;;
    arm*)
        arch='arm64'
      ;;
    *)
        arch='386'
      ;;
  esac
  file_to_download="terragrunt_$(uname -s | tr '[:upper:]' '[:lower:]' )_${arch}"
  get_latest_version
  download_latest
}

if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
