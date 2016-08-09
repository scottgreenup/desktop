#!/usr/bin/env bash

git submodule update --init --recursive

cwd=$(pwd)

#===============================================================================
# Color
#-------------------------------------------------------------------------------
rm -f "~/.config/base16-shell"
ln -s\
    "${cwd}/submodules/github.com/chriskempson/base16-shell"\
    "/home/$(whoami)/.config/base16-shell"
#===============================================================================


#===============================================================================
# VIM
#-------------------------------------------------------------------------------
rm -f "${cwd}/home/vim/autoload/pathogen.vim"
ln -s\
    "${cwd}/submodules/github.com/tpope/vim-pathogen/autoload/pathogen.vim"\
    "${cwd}/home/vim/autoload/pathogen.vim"

rm ${cwd}/home/vim/bundle/*

ln -s\
    "${cwd}/submodules/github.com/chriskempson/base16-vim"\
    "${cwd}/home/vim/bundle/base16-vim"

ln -s\
    "${cwd}/submodules/github.com/scrooloose/nerdtree"\
    "${cwd}/home/vim/bundle/nerdtree"

ln -s\
    "${cwd}/submodules/github.com/ntpeters/vim-better-whitespace"\
    "${cwd}/home/vim/bundle/vim-better-whitespace"

ln -s\
    "${cwd}/submodules/github.com/pangloss/vim-javascript"\
    "${cwd}/home/vim/bundle/vim-javascript"

[[ -e ~/.vim ]] && rm ~/.vim
ln -s "${cwd}/home/vim" "/home/$(whoami)/.vim"

[[ -e ~/.vimrc ]] && rm ~/.vimrc
ln -s "${cwd}/home/vimrc" "/home/$(whoami)/.vimrc"
#===============================================================================

hm="/home/$(whoami)"

if [[ ! -e "${hm}/.config/awesome" ]]; then
    mkdir --parents "/home/$(whoami)/.config/awesome"
fi
ln -sf\
    "${cwd}/home/config/awesome/rc.lua"\
    "${hm}/.config/awesome/rc.lua"
ln -sf\
    "${cwd}/submodules/github.com/NuckChorris/assault/awesomewm/assault.lua"\
    "${hm}/.config/awesome/assault.lua"

if [[ -h "${hm}/bin" ]]; then
    rm -rf "${hm}/bin"
    ln -sf "${cwd}/bin" "${hm}/bin"
else
    echo "${hm}/bin is not a symbolic link, please remove and re-run script."
fi

ln -sf "${cwd}/home/xmodmaprc"  "${hm}/.Xmodmap"
ln -sf "${cwd}/home/xprofile"   "${hm}/.xprofile"
ln -sf "${cwd}/home/bashrc"     "${hm}/.bashrc"
ln -sf "${cwd}/home/Xresources" "${hm}/.Xresources"

sudo ln -sf\
    "${cwd}/usr/share/awesome/themes/xathereal"\
    "/usr/share/awesome/themes/xathereal"

