#!/bin/bash

##################################################################
# This script was created because heroku had a code freeze
#
# https://github.com/heroku/cli/issues/880#issuecomment-394772570
#
# When this happened I wasn't able to use heroku and so I made
# this script to downgrade to a version that was known good
# environments this script works for is aws cloud9, ubuntu 16.04
# and Fedora 27 desktop. It might work for other os's, but those
# are what I trialed this script on.
##################################################################

# adding to path
pathExt='PATH=$HOME/.local/bin/:$PATH'

# used to come back to current directory after install npm modules
currDir=$(pwd)

# variables need for specific version of the software
nodeVersion='8.1.3'
herokuVersion='v7.0.80'

# nvm url to install nvm at
nvmUrl='https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh '

# small detection to what environment script is in
OS=$(grep -oE 'amzn|ID=fedora'  /etc/os-release)

# determine what os
if [[ ! -z "$OS" ]] ; then 
	# all amazon cloud9 or fedora based distros
	installer='yum'
else
	# else it is ubuntu
	installer='apt-get'
fi

# installing node package manager
sudo $installer install -y npm

# linking so programs see node as executable
# and redirecting stderr because not important if it fails
sudo ln -s /usr/bin/nodejs /usr/bin/node 2> /dev/null

# installing nvm for new node version
# taken from the https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh script
curl -sL $nvmUrl | bash

# loading nvm env from 
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# installing the node version for heroku
nvm install $nodeVersion


# installing working version of heroku
cd $HOME
npm install heroku@${herokuVersion}

# go back to directory user was in
cd $currDir

# had to do this because amazon was weird about global npm
echo "export $pathExt" >> ~/.bashrc
mkdir -p ~/.local/bin/
sudo ln -s ${HOME}/node_modules/.bin/heroku ~/.local/bin/heroku


if [[ $(grep '$HOME/.local/bin/' ~/.bashrc 2> /dev/null ) ]] || [[ $(grep '$HOME/.local/bin/' ~/.bash_profile 2> /dev/null) ]] || [[ $(grep '$HOME/.local/bin/' ~/.profile 2> /dev/null ) ]] ; then
       echo export 'PATH=$HOME/.local/bin/:$PATH' >> ${HOME}/.bashrc
fi


# displaying user output to refresh env
clear
echo -e "\n\n\n\nPlese now execute the following commands"
echo 'source ~/.bashrc'

# amazon specific comments
if [[ $OS == "amzn" ]] ; then
	echo -e "nvm install $nodeVersion \n\n\n\n"
	
	echo "for some reason amazon doesn't load everything right."
	echo "sorry didn't want you to have to run commands"
fi
