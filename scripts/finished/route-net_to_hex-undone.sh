#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JGZrh

function main(){
  mapfile -t static_route_arr < <( tr ':' '\n' <<< "${1}" | tr '[:lower:]' '[:upper:]' )
  for hex in "${static_route_arr[@]}" ; do
    printf '%s - ' "${hex}"
    # https://linuxhint.com/convert_hexadecimal_decimal_bash/
    printf 'obase=10; ibase=16; %s\n' "${hex}" | bc
  done
}

# https://elrey.casa/bash/scripting/main
if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
