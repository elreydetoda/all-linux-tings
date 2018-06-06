#!/bin/bash

nodeVersion='8.1.3'
herokuVersion='v7.0.80'
nvmUrl='https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh '
OS=$(grep -oE 'amzn|ID=fedora'  /etc/os-release)

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
sudo ln -s /usr/bin/nodejs /usr/bin/node

# installing nvm for new node version
curl -sL $nvmUrl | bash

# loading nvm
# . ~/.profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# installing the node version
nvm install $nodeVersion

# installing working version of heroku
sudo npm install heroku@${herokuVersion}


# had to do this because amazon was weird about global npm
mkdir -p ~/.local/bin/
sudo ln -s ${HOME}/node_modules/.bin/heroku ~/.local/bin/heroku

clear
echo -e "\n\n\n\nPlese now execute the following command: source ~/.bashrc"
