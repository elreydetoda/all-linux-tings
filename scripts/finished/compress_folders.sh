#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[s]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JtVBC


function build_exclusion(){

  mapfile -t exclude_array < <( echo "${exclusions}" | tr '|' '\n' )
  
  for exclude in "${exclude_array[@]}" ; do
    exclude_string_array+=("-name ${exclude} -o ")
  done
  
  ## bash string manipulation
  # exclude_string="${exclude_string/% -o /}"
  
  # shellcheck disable=SC2001
  read -ra exclude_string < <( echo "${exclude_string_array[@]}" | sed 's/ -o $//' )

}

function choose_compression_prog(){
  compress_prog='pigz'
}

function statz(){
  # printf 'started compression of all folders, and now waiting for %s processes to finish\n' "${#pid_array}"
  printf 'if you would like to follow the status of the above processes you can run this:\n\n%s\n' "watch -n 1 'ps -u$(printf ' -p %s' "${pid_array[@]}")'"
  printf 'if you would like to follow the folder size increasing you can run this:\n\n%s\n' "du -hs$(printf ' %s.tgz' "${folder_array[@]}")"

}

function compress_folders(){

  declare -a pid_array
  declare -a folder_array

  while IFS= read -r -d '' folderz
  do
  
    # echo "${folderz}"
    sudo tar -cf - "${folderz}" | ${compress_prog} -9 > "${folderz}.tgz" &
    pid_array+=( $! )
    folder_array+=( "${folderz}" )
  
  done < <( find . -maxdepth 1 -type d -not \( "${exclude_string[@]}" \) -print0 )

  statz

  wait "${pid_array[@]}"
  printf 'finished compressing all folders\n'
  sudo rm -Irf "${folder_array[@]}"


}

# script to compress all folders listed in CWD 
function main(){

  if [[ $# -ne 1 ]] ; then
    exclusions="."
  else
    exclusions=".|${1}"
  fi
  
  declare -a exclude_string_array

  build_exclusion
  choose_compression_prog
  compress_folders

}

# https://elrey.casa/bash/scripting/main
if [[ "${0}" = "${BASH_SOURCE[0]}" ]] ; then
  main "${@}"
fi
