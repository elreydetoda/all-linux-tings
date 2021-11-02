#!/usr/bin/env bash

# http://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# 

function get_latest_version(){

    latest_version_resp="$(${curl_cmd[@]} "${release_url}" | jq -r '.versions | keys[]' | sort -V | grep -vE '(alpha|beta|rc)' )"

  if [ -n "${version}" ] ; then
    current_version="$( grep "${version}" <<< "${latest_version_resp}" )"
  else
    current_version="$( tail -n 1 <<< "${latest_version_resp}" )"
  fi
}

function latest_download(){

  pushd "${tmp_fld}" > /dev/null
  ${curl_cmd[@]} -Jo "${zip_file}" "https://releases.hashicorp.com/terraform/${current_version}/terraform_${current_version}_linux_amd64.zip"

}

function install_terraform(){
  unzip "${zip_file}" > /dev/null
  install terraform /usr/local/bin/
  popd > /dev/null
}

function cleanup(){
  rm -rf "${tmp_fld}"
}

# http://elrey.casa/bash/scripting/main
function main(){
  release_url='https://releases.hashicorp.com/terraform/index.json'
  version="${VERSION:-}"
  curl_cmd=(
    'curl'
    '-fsSL'
  )
  tmp_fld="$(mktemp -d)"
  zip_file='tform.zip'

  get_latest_version
  latest_download
  install_terraform
  cleanup
}

if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
