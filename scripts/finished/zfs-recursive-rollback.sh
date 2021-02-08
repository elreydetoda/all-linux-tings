#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[s]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JtVB4

#
# Dr. Martin Menzel
# Dr. Menzel IT - www.dr-menzel-it.de
# 11.08.2013
# https://blog.woopi.org/wordpress/?p=60
# alteration on 2020-05-16 by @elreydetoda: https://github.com/elreydetoda
# cmd: curl -fsSL 'https://git.io/Jf047' | bash -s '<zpool_name>' '<snapshot_name>'
# debug: export DEBUG=true ; curl -fsSL 'https://git.io/Jf047' | bash -s '<zpool_name>' '<snapshot_name>'


# Use at your own risk. No warranty. No fee.
#
# parameter list:
#   (1) the filesystem to be used to start decendant recursion
#       example: 'apool/zones/webzone'
#   (2) the snapshot to which the filesystems should be rolled back
#       example: '@2013-07-21-083500'
#   (3) (OPTIONAL) the pattern of directories you want to ignore (i.e. home directory so you don't loose personal data)
#       example: 'home|docker'
#
zpool_name="${1}"
snapshot_name="${2}"
set +u
if [[ -z "${3}" ]] ; then
  ignore_pattern=''
else
  ignore_pattern="${3}"
fi
set -u



function error {
  echo "An error occured remove a snapshot"
  printf 'The snapshot that was affected was %s\n' "${snap}"
}

list_cmd="zfs list -H -t snapshot -r ${zpool_name} | grep ${snapshot_name} |  cut -f 1"

if [[ -n "${ignore_pattern}" ]] ; then
  list_cmd+="| grep -vP '(${ignore_pattern})'"
fi

trap error ERR

for snap in $(eval "${list_cmd}"); do
        # -r : also destroys the snapshots newer than the specified one
        # -R : also destroys the snapshots newer than the one specified and their clones
        # -f : forces an unmount of any clone file systems that are to be destroyed
        echo -n "rolling back to [${snap}] : ";zfs rollback -r -R -f "${snap}";       echo "  Done."
done
