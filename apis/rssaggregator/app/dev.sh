#!/usr/bin/env bash

set -${-//[sc]/}eu${DEBUG+xv}o pipefail


function main(){
  while ./main.py && read -rp 'Ready? ' -n1 ; do : ; done
}

if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
