#!/usr/bin/env bash

# debian hashicorp repos from here: https://medium.com/hashicorp-engineering/hashicorp-packaging-is-here-4c6083dee4f6

set -${-//[sc]/}eu${DEBUG+xv}o pipefail

curl -fsS 'https://apt.releases.hashicorp.com/gpg' | sudo apt-key add -
sudo apt-add-repository -u "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
