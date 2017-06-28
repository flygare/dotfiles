#!/bin/sh

######## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files=".gitconfig.local .gitconfig .inputrc .tmux.conf .bashrc .vimrc .vim .zshrc"        # list of files/folders to symlink in homedir
gitname=""
gitemail=""

##########

# Create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# Change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# Setup git config
if [ ! -f .gitconfig.local ]; then
    echo ".gitconfig.local not found, prompting for git settings"
    echo "Enter name: "
    read -r gitname
    echo "Enter email: "
    read -r gitemail

    printf "[user]\n  email=$gitemail\n  name=$gitname\n" > .gitconfig.local
fi

# Move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done

# Install OS specific
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # Linux install
    apt-get install curl
    apt-get install zsh
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX install
    brew install zsh
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

fi

# Install general
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
