#!/bin/bash

# Perform a full system update
sudo apt-get update
sudo apt-get dist-upgrade -y

# Install dev tools
sudo apt-get install -y netcat nmap build-essential bison flex bison-doc gawk git pv task taskd tasksh

# Install programming languages
sudo apt-get install -y gfortran fort77 erlang swi-prolog clojure fp-ide gcj-4.9-jre-headless clojure1.6 ghc ghc-doc haskell-doc alex happy

# Install some libraries
sudo apt-get install -y libgl1-mesa-dev libglc-dev freeglut3-dev libedit-dev libglw1-mesa libglw1-mesa-dev

# Install some admin tools
sudo apt-get install -y parted gparted xfsprogs reiserfsprogs reiser4progs jfsutils dmraid gpart xfsdump hfsprogs secure-delete

# Install editors
sudo apt-get install -y vim emacs nano hexedit sc

# Install shell tools
sudo apt-get install -y mc tmux screen arj rar unrar gpm p7zip-full
p7zip-rar htop sshfs moreutils ddate htop

# Install network tools
sudo apt-get install -y netcat openssh-server tftp mosh oidentd lftp rtorrent net-tools

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

# Install X programs
sudo apt-get install -y hexchat pan liferea

# Install games
sudo apt-get install -y bsdgames bsdgames-nonfree nethack-console crawl frotz inform inform-docs dosbox wine

# Install fonts
sudo apt-get install -y msttcorefonts ttf-liberation ttf-dejavu texlive-full fonts-hack fonts-ibm-plex
curl -L https://github.com/hbin/top-programming-fonts/raw/master/install.sh | bash

# Install music programs
sudo apt-get install -y pianobar pithos vlc

# Install LAMP server
sudo apt-get install -y lamp-server^

# Generate the SSH key
ssh-keygen

# Install Vundle for VIM
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install TPM for tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Display the public key for copying
cat ~/.ssh/id_rsa.pub
read -p "Copy the public key to Github and then press [Enter] to continue..."

# Make the directories and copy stuff from Github
mkdir ~/bin
mkdir ~/git
mkdir ~/git/dotfiles
git clone git@github.com:agiacalone/dotfiles.git ~/git/dotfiles

# First copy the non-dot files, then the dot files
cp -R ~/git/dotfiles/* ~/
cp -R ~/git/dotfiles/.* ~/

# The initial installation setup should be complete!
