#!/bin/bash
bash -c "$(wget -qO - https://raw.github.com/flygare/dotfiles/$TRAVIS_BRANCH/install.sh)" << EOF
firstname lastname
firstname.lastname@flygare.me
EOF
