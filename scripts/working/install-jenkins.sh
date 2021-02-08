#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JtV4L

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
apt-add-repository 'deb https://pkg.jenkins.io/debian-stable binary/'
sleep 2
apt-get update
apt-get install -y jenkins openjdk-8-jre-headless
systemctl enable --now jenkins
