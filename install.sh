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
	sudo apt-get install zsh tmux powertop i3status i3lock xorg-xset scrot feh rofi geoip-bin pianobar acpi whois espeak
else
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

##################################################################

# creating script which is used in .xinitrc
cat >  ~/scripts/lowbat.sh <<EOF
#! /bin/bash

SLEEP_TIME=5   # Default time between checks.
SAFE_PERCENT=30  # Still safe at this level.
DANGER_PERCENT=15  # Warn when battery at this level.
CRITICAL_PERCENT=5  # Hibernate when battery at this level.

NAGBAR_PID=0
export DISPLAY=:0.0

function launchNagBar
{
    i3-nagbar -m 'Battery low!' -b 'Hibernate!' 'pm-hibernate' >/dev/null 2>&1 &
    NAGBAR_PID=$!
}

function killNagBar
{
    if [[ $NAGBAR_PID -ne 0 ]]; then
        ps -p $NAGBAR_PID | grep "i3-nagbar"
        if [[ $? -eq 0 ]]; then
            kill $NAGBAR_PID
        fi
        NAGBAR_PID=0
    fi
}


while [ true ]; do

    killNagBar

    if [[ -n $(acpi -b | grep -i discharging) ]]; then
        rem_bat=$(acpi -b | grep -Eo "[0-9]+%" | grep -Eo "[0-9]+")

        if [[ $rem_bat -gt $SAFE_PERCENT ]]; then
            SLEEP_TIME=10
        else
            SLEEP_TIME=5
            if [[ $rem_bat -le $DANGER_PERCENT ]]; then
                SLEEP_TIME=2
                launchNagBar
            fi
            if [[ $rem_bat -le $CRITICAL_PERCENT ]]; then
                SLEEP_TIME=1
                pm-hibernate
            fi
        fi
    else
        SLEEP_TIME=10
    fi

    sleep ${SLEEP_TIME}m

done
EOF

# giving it execute permissions
chmod +x ~/scripts/lowbat.sh

##################################################################
## last comments

echo "I did most of the work now it is up to you to get the rest to work"
##################################################################
