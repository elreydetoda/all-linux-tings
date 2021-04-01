#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# https://elrey.casa/bash/scripting/main
function main(){
  while ./main.py && read -rp 'Ready? ' -n1 ; do : ; done
}

if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
