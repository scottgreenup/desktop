#!/usr/bin/env bash

#pacman -S\
#    awesome\
#    lightdm\
#    lightdm-webkit-theme-material-git\
#    lightdm-webkit2-greeter\
#    vim\
#    xorg-server\
#    xf86-video-ati\
#    xf86-video-intel\
#    xf86-video-nouveau\
#    xf86-video-vesa

# Window Manager
#mkdir -p ~/.config/awesome
#ln -s ./home/config/awesome/rc.lua ~/.config/awesome/rc.lua
#
## Home directory dotfiles
#ln -s ./home/bashrc ~/.bashrc
#ln -s ./home/bin ~/bin
#ln -s ./home/vim ~/.vim
#ln -s ./home/vimrc ~/.vimrc
#ln -s ./home/xresources ~/.Xresources
#ln -s ./home/xmodmaprc ~/.Xmodmap
#ln -s ./home/xprofile ~/.xprofile
#
## /etc
#sudo ln -s ./etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf

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
