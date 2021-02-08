#!/usr/bin/env bash

set -${-//[sc]/}eu${DEBUG+xv}o pipefail

debian_version="$(curl -fsSL 'https://www.debian.org/releases/stable/' | grep 'Release Information' | grep '<h1>' | grep -oP ';.*&' | tr -d ';|&')"
curl -fsSL 'https://git.io/JtVlL' | sed "s/\$(lsb_release.*)/${debian_version}/" | bash
