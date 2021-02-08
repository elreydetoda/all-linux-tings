#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[s]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JtVB6

if [[ $# -ne 3 ]] ; then
  printf 'Please provide 3 arguements: "%s" "%s" "%s" \n' "subnet mask of dest net" "base of range for dest net" "src gateway ip"
  exit 1
fi

subnet_mask_dst_net="${1}"
base_address_route_to="${2}"
src_gateway_ip="${3}"

# i.e. if you want to route from 10.0.0.2 --> 192.168.22.0/24
# "subnet mask of dest net" "base of range for dest net" "src gateway ip"
# format of args are as follows: 24 '192.168.22.0' '10.0.0.1'

# mapfile comes from: https://github.com/koalaman/shellcheck/wiki/SC2207
mapfile -t base_address_route_to_array < <(printf '%s' "${base_address_route_to}" | grep -oP '\d+' | head -n 3)
mapfile -t src_gateway_ip_array < <(printf '%s' "${src_gateway_ip}" | grep -oP '\d+')

printf '%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n' "${subnet_mask_dst_net}" "${base_address_route_to_array[@]}" "${src_gateway_ip_array[@]}"
