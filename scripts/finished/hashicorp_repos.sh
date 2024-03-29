#!/usr/bin/env bash

# debian hashicorp repos from here: https://medium.com/hashicorp-engineering/hashicorp-packaging-is-here-4c6083dee4f6
# short link: https://git.io/JtVlL

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

curl -fsS 'https://apt.releases.hashicorp.com/gpg' | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/hashicorp.gpg > /dev/null
sudo apt-add-repository -u "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
