#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JtVlq

debian_version="$(curl -fsSL 'https://www.debian.org/releases/stable/' | grep 'Release Information' | grep '<h1>' | grep -oP ';.*&' | tr -d ';|&')"
curl -fsSL 'https://git.io/JtVlL' | sed "s/\$(lsb_release.*)/${debian_version}/" | bash
