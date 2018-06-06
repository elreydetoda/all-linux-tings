#!/bin/bash

boxcryptorFolder="~/.Boxcryptor"
rm -rf $boxcryptorFolder
mkdir -p $boxcryptorFolder
curl -L 'https://ptc.secomba.com/api/boxcryptor/linuxPortable/latest' | bsdtar -xvf- -C $boxcryptorFolder
