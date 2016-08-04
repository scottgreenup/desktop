#!/usr/bin/env bash

pacman -S\
    awesome\
    lightdm\
    lightdm-webkit-theme-material-git\
    lightdm-webkit2-greeter\
    vim\
    xorg-server\
    xf86-video-ati\
    xf86-video-intel\
    xf86-video-nouveau\
    xf86-video-vesa

# Window Manager
mkdir -p ~/.config/awesome
ln -s ./home/config/awesome/rc.lua ~/.config/awesome/rc.lua

# Home directory dotfiles
ln -s ./home/bashrc ~/.bashrc
ln -s ./home/bin ~/bin
ln -s ./home/vim ~/.vim
ln -s ./home/vimrc ~/.vimrc
ln -s ./home/xresources ~/.Xresources
ln -s ./home/xmodmaprc ~/.Xmodmap
ln -s ./home/xprofile ~/.xprofile

# /etc
sudo ln -s ./etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf

