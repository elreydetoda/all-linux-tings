#!/bin/bash

sudo -u root sh -c 'sed -i "s/autoconnect=false//" /etc/NetworkManager/system-connections/*'
sudo -u root sh -c 'sed -i "s/type=wifi/type=wifi\nautoconnect=false/" /etc/NetworkManager/system-connections/*'
