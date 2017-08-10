#!/bin/bash

######## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files=".gitconfig.local .oh-my-zsh/custom/themes .gitconfig .vimrc .zshrc"        # list of files/folders to symlink in homedir
gitname=""
gitemail=""

######## Functions
. "utils.sh" || { echo "Could not find utils.sh"; exit 1; }

function setup-git {
install-git
check-dotfiles
}

function install-git {
if [[ ! $(which git 2>/dev/null) && "$OSTYPE" == "linux-gnu" ]]; then
  sudo apt-get install git
elif [ ! $(which git 2>/dev/null) ]; then
  install-brew
  brew install git
fi
print_result $? "Install git"
}

function check-dotfiles {
  if [ -d "$HOME/dotfiles/" ]; then
    print_warning "dotfiles already exist"
  else
    git clone https://github.com/flygare/dotfiles.git ~/dotfiles
    print_result $? "Clone dotfiles"
  fi
}

function linux {
  setup-git
  setup-gitconfig
    symlink
    print_header "Installs"
    linux-install-curl
    linux-install-zsh
}

function macos {
  setup-git
  setup-gitconfig
    symlink
    print_header "Installs"
    install-brew
    brew install zsh
    print_result $? "Zsh"
    brew install autojump
    print_result $? "Autojump"
}

function linux-install-curl {
  if [ ! $(which curl 2>/dev/null) ]; then
    sudo apt-get install curl
      fi
      print_result $? "Curl"
}

function linux-install-zsh {
  if [ ! $(which curl 2>/dev/null) ]; then
    sudo apt-get install zsh
      fi
      print_result $? "Zsh"
}

function install-brew {
  if [ ! $(which brew 2>/dev/null) ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      fi
      print_result $? "Homebrew"
}

function install-ohmyzsh {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    print_result $? "Oh-my-zsh"
}

function symlink {
  print_header "Symlinks"
    mkdir -p $olddir
    cd $dir
    for file in $files; do
      mv ~/$file ~/dotfiles_old/
        done
        print_result $? "Back up any existing dotfiles from ~ to $olddir"

        for file in $files; do
          ln -s $dir/$file ~/$file
            done
            print_result $? "Symlinking dotfiles"
}

function setup-gitconfig {
  print_header "Set up gitconfig"
    if [ ! -f .gitconfig.local ]; then
      print_warning ".gitconfig.local not found, prompting for git settings"
        echo "Enter name: "
        read -r gitname
        echo "Enter email: "
        read -r gitemail

        printf "[user]\n  email=$gitemail\n  name=$gitname\n" > .gitconfig.local
        fi
        print_result $? "Local gitconfig"
}

########## Main
# Check operating system
if [[ "$OSTYPE" == "linux-gnu" ]]; then
# Linux install
print_warning "Linux detected, starting installation"
linux
print_header_result $? "Installation complete"
elif [[ "$OSTYPE" == "darwin"* ]]; then
# Mac OSX install
print_warning "Mac detected, starting installation"
macos
print_header_result $? "Installation complete"
else
print_error "Your operating system is not supported"
fi
