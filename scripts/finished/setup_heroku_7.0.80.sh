#!/bin/bash

nodeVersion='8.1.3'
herokuVersion='v7.0.80'
nvmUrl='https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh '

# installing node package manager
sudo apt-get install -y npm

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
sudo npm install -g heroku@${herokuVersion}

clear
echo -e "\n\n\n\nPlese now execute the following command: source ~/.profile"
