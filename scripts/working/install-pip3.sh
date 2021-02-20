#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# git.io: https://git.io/Jt9mk

function check_os(){
  ID_LIKE="$(source /etc/os-release && echo "${ID_LIKE}")"
  case "${ID_LIKE:-}" in
    debian)
        pkg_mgr='apt-get'
        update_cmd=('update')
        install_cmd=( 'install' '-y' )
        deps=(
          'python3-distutils'
          'curl'
        )
      ;;
    *)
        printf 'Did not recognize the OS: %s' "${ID_LIKE}"
        exit 2
      ;;
  esac
}

function install_deps(){
  ${pkg_mgr} "${update_cmd[@]}"
  ${pkg_mgr} "${install_cmd[@]}" "${deps[@]}"
}

function install_pip3(){
  if [[ "${EUID}" == 0 ]] ; then
    curl -s https://bootstrap.pypa.io/get-pip.py | python3
  else
    curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3
  fi
}

# https://elrey.casa/bash/scripting/main
function main(){
  check_os
  install_deps
  install_pip3
}


if [[ "${0}" = "${BASH_SOURCE[0]:-0}" ]] ; then
  main "${@}"
fi
