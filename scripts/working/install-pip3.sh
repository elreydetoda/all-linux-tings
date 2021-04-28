#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# git.io: https://git.io/Jt9mk

# https://elrey.casa/bash/scripting/deps_check
function deps_install(){

  install_cmd=()
  # setting this, because pip comes pre-installed when installing
  #   python3 on rhel based distros
  needed=true

  if [[ "${EUID}" -ne 0 ]]; then
    install_cmd+=('sudo')
  fi

  # shellcheck disable=SC1091
  ID="$( source /etc/os-release ; [ -n "${ID_LIKE:-}" ] && echo "${ID_LIKE}" || echo "${ID:-}" )"
  packages=( 'curl' )
  case "${ID}" in
    *debian*)
      packages+=( 'python3-distutils' )
      package_manager='apt-get'
      package_manager_install_cmd=('install' '-y')
      package_manager_update_cmd=( 'update' )
      ;;
    alpine)
      packages+=()
      package_manager='apk'
      package_manager_install_cmd=('--update' '--no-cache' 'add')
      package_manager_update_cmd=()
      ;;
    *rhel*)
      packages+=( 'python3' )
      package_manager='dnf'
      package_manager_install_cmd=('install' '-y')
      package_manager_update_cmd=()
      needed=false
      ;;
    *fedora*)
      packages+=( 'python3' )
      package_manager='dnf'
      package_manager_install_cmd=('install' '-y')
      package_manager_update_cmd=()
      needed=false
      ;;
    *)
      echo "This script doesn't officially support your distro"
      exit 1
  esac

  if [[ -n "${package_manager_update_cmd[*]}" ]] ; then
    update_cmd=( "${install_cmd[@]}" "${package_manager}" "${package_manager_update_cmd[@]}" )
    printf '\nusing this command to update your system: %s\n' "${update_cmd[*]}"
    "${update_cmd[@]}"
  fi

  need_to_install=''
  needs=()
  for package in "${packages[@]}"; do
    bin_provided="${package##*|}"
    package_name="${package%%|*}"
    if ! command -v "${bin_provided:-${package_name}}" > /dev/null ; then
      needs+=("${package_name}")
      need_to_install='true'
    fi
  done

  install_cmd=("${install_cmd[@]}" "${package_manager}" "${package_manager_install_cmd[@]}")

  if [[ -n "${need_to_install}" ]]; then
    printf 'need to install: %s\n' "${needs[@]}"
    printf '\nusing this command to install it: %s %s\n' "${install_cmd[*]}" "${needs[*]}"
    "${install_cmd[@]}" "${needs[@]}"
  fi

}

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
  # check_os
  # install_deps
  if command -v pip3 ; then
    echo "You already have pip installed"
    exit 0
  elif [[ "${1:-}" == '-f' ]] || [[ "${1:-}" == '--force' ]] ; then
    deps_install
    if [[ "${needed}" == 'true' ]] ; then
      install_pip3
    fi
  else
    deps_install
    if [[ "${needed}" == 'true' ]] ; then
      install_pip3
    fi
  fi
}


if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
