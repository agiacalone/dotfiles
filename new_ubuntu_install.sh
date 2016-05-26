#!/bin/bash

# Perform a full system update
sudo apt-get update
sudo apt-get dist-upgrade -y

# Install dev tools
sudo apt-get install -y netcat nmap build-essential bison flex bison-doc gawk git

# Install programming languages
sudo apt-get install -y gfortran fort77 erlang swi-prolog clojure

# Install editors
sudo apt-get install -y vim emacs nano

# Install shell tools
sudo apt-get install -y mc tmux screen arj rar unrar gpm p7zip-full p7zip-rar

# Install network tools
sudo apt-get install -y netcat openssh-server tftp mosh

# Install mail clients
sudo apt-get install -y alpine mutt postfix mailutils

# Install shell browsers
sudo apt-get install -y lynx elinks links gopher

# Install shells
sudo apt-get install -y ash ksh tcsh csh zsh zsh-doc

# Install news programs
sudo apt-get install -y newsbeuter slrn

# Install chat programs
sudo apt-get install -y pidgin pidgin-otr finch irssi weechat irssi-scripts znc tf5 tintin++

# Install games
sudo apt-get install -y bsdgames bsdgames-nonfree nethack-console crawl frotz inform inform-docs dosbox wine

# Install fonts
sudo apt-get install -y msttcorefonts ttf-liberation ttf-dejavu texlive-full

# Install LAMP server
sudo apt-get install -y lamp-server^

# Generate the SSH key
ssh-keygen

# Display the public key for copying
cat ~/.ssh/id_rsa.pub
read -p "Copy the public key to Github and then press [Enter] to continue..."

# Make the directories and copy stuff from Github
mkdir ~/bin
mkdir ~/git

git clone git@github.com:agiacalone/dotfiles.git ~/git/dotfiles

# First copy the non-dot files, then the dot files
cp -R ~/git/dotfiles/* ~/
cp -R ~/git/dotfiles/.* ~/

# The initial installation setup should be complete!