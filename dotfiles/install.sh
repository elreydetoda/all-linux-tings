#!/bin/bash

##################################################################
## getting user input

echo "Please choose the appropriate number per you linux distro."
echo "1 Debian/Ubuntu"
echo "2 arch"

read distro

##################################################################
## installing packages depending on distro
if (( distro == 1 )) ; then
	sudo apt-get install zsh tmux powertop i3status i3lock xorg scrot feh rofi geoip-bin pianobar acpi whois espeak
else
	echo "################################################"
	echo "#This isn't as up to date as the ubuntu install#"
	echo "################################################"
	sudo pacman -S zsh tmux powertop i3status i3lock xorg-xset
fi

##################################################################
## used for making folders for hosting files

mkdir ~/src
mkdir ~/scripts

##################################################################
## getting all the content from github

git clone https://github.com/robbyrussell/oh-my-zsh.git ~/src/oh-my-zsh
git clone https://github.com/Airblader/i3.git ~/src/i3
git clone https://github.com/vim/vim.git ~/src/vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/src/Vundle.vim

##################################################################
## setting up i3-wm-gaps for logging you still need to go in an compile everything (I wouldn't even trust me to do that, you should trust anyone to do it either... :)

sudo mkdir /var/log/i3wm
sudo chown $USER:$USER /var/log/i3wm

##################################################################
## taking care of oh my zsh

cp -r ~/src/oh-my-zsh ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
chsh -s /bin/zsh
##################################################################
## moving all the dot files to your home directory
cp .* ~/

# moving script to do low battery warning and giving it execute permission
chmod +x ~/scripts/lowbat.sh

##################################################################
## last comments

echo "I did most of the work now it is up to you to get the rest to work"
##################################################################
