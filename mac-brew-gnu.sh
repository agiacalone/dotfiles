# Installer for new Mac installs
# This script will install homebrew, oh-my-zsh, and others


# First, install homebrew
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install oh-my-zsh
brew install curl
brew install zsh
#sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# core
brew install coreutils

# key commands
brew install binutils
brew install inetutils
brew install diffutils
brew install ed
brew install findutils
brew install gawk
brew install gnu-indent
brew install gnu-sed
brew install gnu-tar
brew install gnu-which
brew install gnutls
brew install grep
brew install gzip
brew install screen
brew install watch
brew install wdiff
brew install wget

# OS X ships a GNU version, but too old
brew install bash
brew install emacs
brew install gdb  # gdb requires further actions to make it work. See `brew info gdb`.
brew install gpatch
brew install m4
brew install make
brew install nano

# Other commands (non-GNU)
brew install file-formula
brew install git
brew install less
brew install openssh
brew install python
brew install rsync
brew install svn
brew install unzip
brew install unrar
brew install tmux
brew install vim
brew install neovim
brew install htop
brew install newsboat
brew install neomutt
brew install slrn
brew install weechat
brew install nethack
brew install moreutils
brew install ddate
brew install frotz
brew install inform6
brew install mosh
brew install swi-prolog
brew install lftp
brew install netcat
brew install bison
brew install flex
brew install tintin
brew install tinyfugue
brew install youtube-dl
brew install rtorrent
brew install speedtest-cli
brew install --cask signal
brew install --cask spatterlight
brew install --cask obs
brew install --cask audacity
brew install --cask wine-stable
brew install winetricks
#brew install --cask vmware-fusion

# Special for BSD Games
brew install bsdmake
brew tap ctdk/ctdk
brew install bsdgames-osx

# GUI stuff
brew install vlc
brew insatll docker
brew install multipass
brew install --cask lagrange
brew install --cask iterm2
brew install --cask firefox
brew install --cask element
brew install --cask textual
brew install --cask postbox
brew install --cask 1password
brew install --cask caffeine
brew install --cask vscodium
brew install hexedit
brew install dosbox
brew install boxer
brew install pidgin
brew install --cask macvim
brew install --cask usenapp
brew install --cask nvidia-geforce-now
brew install --cask spotify
brew install --cask discord
brew install --cask mactex
brew install --cask lyx
brew install --cask gog-galaxy
brew install --cask steam
brew install --cask cardhop
brew install --cask fantastical
brew install --cask zoom
brew install --cask macdown
brew install --cask whalebird
brew install toot
brew install --cask little-snitch

# Fonts
brew tap homebrew/cask-fonts
brew install font-hack
brew install font-ibm-plex
brew install font-inconsolata

# Generate the SSH key
ssh-keygen

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

# Install vundle for vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install tpm for tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# The initial installation setup should be complete!
