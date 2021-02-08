#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[s]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JtVBp

if [[ -n "${1}" ]] ; then
  pool="${1}"
else
  pool="${POOL:-rpool}"
fi

for i in $(zfs list -Ht snapshot -o name -r "${pool}" | cut -d '@' -f 2 | sort -u ) ; do

  zfs destroy -vRn "${pool}@${i}"

done | grep -B 1 reclaim | grep -B1 'G$'
