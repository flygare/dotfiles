#!/bin/bash

######## Variables
dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files=".gitconfig.local .oh-my-zsh/custom/themes .gitconfig .vimrc .zshrc"        # list of files/folders to symlink in homedir
gitname=""
gitemail=""

######## Functions
function install-generic {
  pkg-install git
  check-dotfiles
  setup-gitconfig
  print_header "Installs"
  pkg-install curl
  pkg-install zsh
  install-ohmyzsh &> /dev/null
  symlink
}

function linux {
  print_header "Linux detected, starting installation"
  install-generic
  print_header_result $? "Installation complete"
}

function macos {
  print_header "Mac detected, starting installation"
  install-brew
  install-generic
  pkg-install autojump
  print_header_result $? "Installation complete"
}

function pkg-install {  
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  # Linux install
  if [ ! $(which $1 2>/dev/null) ]; then
    sudo apt-get install $1 &> /dev/null
  fi
  print_result $? "$1"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # Mac OSX install
  if [ ! $(which $1 2>/dev/null) ]; then
    brew install $1 &> /dev/null
  fi
  print_result $? "$1"
else
  print_error "Your operating system is not supported"
fi
}

function check-dotfiles {
  if [ -d "$HOME/dotfiles/" ]; then
    print_warning "dotfiles already exist"
  else
    git clone https://github.com/flygare/dotfiles.git ~/dotfiles &> /dev/null
    print_result $? "Clone dotfiles"
  fi
}

function install-brew {
  if [ ! $(which brew 2>/dev/null) ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
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
    if [ -e "$HOME/$file" ]; then
      mv ~/$file ~/dotfiles_old/
    fi
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

######## Color helpers
print_error() {
  print_in_red "   [✖] $1 $2\n"
}

print_error_stream() {
  while read -r line; do
    print_error "↳ ERROR: $line"
  done
}

print_header() {
  print_in_purple "\n • $1\n\n"
}

print_header_result() {
  if [ "$1" -eq 0 ]; then
    print_in_green "\n ✔ $2\n\n"
  else
    print_in_red "\n ✖ $2\n\n"
  fi
  return "$1"
}

print_subheader() {
  print_in_purple "   $1\n\n"
}

print_in_color() {
  printf "%b" \
    "$(tput setaf "$2" 2> /dev/null)" \
    "$1" \
    "$(tput sgr0 2> /dev/null)"
}

print_in_green() {
  print_in_color "$1" 2
}

print_in_purple() {
  print_in_color "$1" 5
}

print_in_red() {
  print_in_color "$1" 1
}

print_in_yellow() {
  print_in_color "$1" 3
}

print_warning() {
  print_in_yellow "   [!] $1\n"
}

print_result() {
  if [ "$1" -eq 0 ]; then
    print_success "$2"
  else
    print_error "$2"
  fi
  return "$1"
}

print_success() {
  print_in_green "   [✔] $1\n"
}

########## Main
# Check operating system
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  linux
elif [[ "$OSTYPE" == "darwin"* ]]; then
  macos
else
  print_error "Your operating system is not supported"
fi
