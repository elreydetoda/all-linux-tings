#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/Jmr0j

function get_git_root(){
  # https://stackoverflow.com/questions/957928/is-there-a-way-to-get-the-git-root-directory-in-one-command#answer-957978
  git_root="$(git rev-parse --show-toplevel)"
}

function get_gh_repo(){
  if git remote -v | grep '@' > /dev/null ; then
    gh_repo="$(git remote -v | grep origin | grep fetch | cut -d ':' -f 2- | cut -d '.' -f 1)"
  else
    gh_repo="$(git remote -v | rev | cut -d '/' -f -2 | rev | cut -d ' ' -f 1)"
  fi
}

function get_path_diff(){
  # https://stackoverflow.com/questions/10551981/how-to-perform-a-for-loop-on-each-character-in-a-string-in-bash#answer-10552175
  pathz="$( dirname "$(readlink -f "${1}")")"
  path_diff=''
  for (( i=0; i<${#pathz}; i++ )) ; do
    current_letter="${pathz:$i:1}"
    if ! [[ "${git_root:$i:1}" == "${current_letter}" ]] ; then
      path_diff+="$(printf '%s' "${current_letter}")"
    fi
  done
}

# https://elrey.casa/bash/scripting/main
function main(){
  base_raw_url='https://raw.githubusercontent.com'
  raw_filez="$( basename "${1}" )"
  get_git_root
  get_gh_repo
  branch="${BRANCH:-master}"
  get_path_diff "${1}"
  urlz="${base_raw_url}/${gh_repo}/${branch}${path_diff}/${raw_filez}"
  printf 'https://git.io/%s\n' "$(curl -fsS 'https://git.io/create' --data "url=${urlz}")"
}

if [[ "${0}" = "${BASH_SOURCE[0]}" ]] ; then
  main "${@}"
fi
