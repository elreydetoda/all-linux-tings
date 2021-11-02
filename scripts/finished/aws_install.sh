#!/usr/bin/env bash

# http://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# short url: 

function latest_download(){

  pushd "${tmp_fld}" > /dev/null
  ${curl_cmd[@]} -o "${zip_file}" "${release_url}"

}

function install_to_os(){
  unzip "${zip_file}" 
  if command -v aws ; then
    install_cmd+=( '--update' )
  fi
  "${install_cmd[@]}"
  popd > /dev/null
}

function cleanup(){
  rm -rf "${tmp_fld}"
}

# http://elrey.casa/bash/scripting/main
function main(){
  release_url='https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip'
  curl_cmd=(
    'curl'
    #'-fsSL'
  )
  tmp_fld="$(mktemp -d)"
  zip_file='awscliv2.zip'
  install_cmd=(
    './aws/install'
    '-i' '/usr/local/aws-cli'
    '-b' '/usr/local/bin'
  )

  latest_download
  install_to_os
  cleanup
}

if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
