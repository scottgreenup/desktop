#!/usr/bin/env bash

git submodule update --init --recursive

cwd=$(pwd)

function checkfile() {
    filename=${1}
    if [[ -e "${filename}" ]]; then
        if [[ ! -h "${filename}" ]]; then
            mv "${filename}" "${filename}.backup"
            echo "${filename} -> ${filename}.backup"
        else
            rm "${filename}"
        fi
    fi
}

#===============================================================================
# Color
#-------------------------------------------------------------------------------
mkdir --parents "${HOME}/.config"
checkfile "${HOME}/.config/base16-shell"
ln -sT\
    "${cwd}/submodules/github.com/chriskempson/base16-shell"\
    "/${HOME}/.config/base16-shell"
#===============================================================================


#===============================================================================
# VIM
#-------------------------------------------------------------------------------
mkdir --parents "${cwd}/home/vim/autoload"
mkdir --parents "${cwd}/home/vim/bundle"
ln -sTf\
    "${cwd}/submodules/github.com/tpope/vim-pathogen/autoload/pathogen.vim"\
    "${cwd}/home/vim/autoload/pathogen.vim"

ln -sTf\
    "${cwd}/submodules/github.com/chriskempson/base16-vim"\
    "${cwd}/home/vim/bundle/base16-vim"

ln -sTf\
    "${cwd}/submodules/github.com/scrooloose/nerdtree"\
    "${cwd}/home/vim/bundle/nerdtree"

ln -sTf\
    "${cwd}/submodules/github.com/ntpeters/vim-better-whitespace"\
    "${cwd}/home/vim/bundle/vim-better-whitespace"

ln -sTf\
    "${cwd}/submodules/github.com/pangloss/vim-javascript"\
    "${cwd}/home/vim/bundle/vim-javascript"

ln -sTf\
    "${cwd}/submodules/github.com/tpope/vim-fugitive"\
    "${cwd}/home/vim/bundle/vim-fugitive"

ln -sTf\
    "${cwd}/submodules/github.com/tomlion/vim-solidity"\
    "${cwd}/home/vim/bundle/vim-solidity"

checkfile "${HOME}/.vim"
ln -sT "${cwd}/home/vim" "/${HOME}/.vim"

checkfile "${HOME}/.vimrc"
ln -sT "${cwd}/home/vimrc" "/${HOME}/.vimrc"
#===============================================================================

## [ Awesome WM ] ##

mkdir --parents "${HOME}/.config/awesome"
checkfile "${HOME}/.config/awesome/rc.lua"
ln -sTf "${cwd}/home/config/awesome/rc.lua" "${HOME}/.config/awesome/rc.lua"
ln -sTf "${cwd}/home/config/awesome/themes" "${HOME}/.config/awesome/themes"

checkfile "${HOME}/.config/awesome/assault.lua"
ln -sfT\
    "${cwd}/submodules/github.com/NuckChorris/assault/awesomewm/assault.lua"\
    "${HOME}/.config/awesome/assault.lua"
#
#ln -sTf\
#    "${cwd}/submodules/github.com/copycat-killer/lain"\
#    "${HOME}/.config/awesome/lain"

## [ Miscellaneous ] ##

if [[ -h "${HOME}/bin" ]]; then
    rm -rf "${HOME:?}/bin"
else
    echo "${HOME}/bin is not a symbolic link, please remove and re-run script."
fi

checkfile "${HOME}/bin"
ln -sfT "${cwd}/bin" "${HOME}/bin"

checkfile "${HOME}/.Xmodmap"
ln -sfT "${cwd}/home/xmodmaprc"  "${HOME}/.Xmodmap"
checkfile "${HOME}/.xprofile"
ln -sfT "${cwd}/home/xprofile"   "${HOME}/.xprofile"
checkfile "${HOME}/.bashrc"
ln -sfT "${cwd}/home/bashrc"     "${HOME}/.bashrc"
checkfile "${HOME}/.Xresources"
ln -sfT "${cwd}/home/Xresources" "${HOME}/.Xresources"
checkfile "${HOME}/.inputrc"
ln -sfT "${cwd}/home/inputrc" "${HOME}/.inputrc"

mkdir --parents "${HOME}/.urxvt/ext"
checkfile "${HOME}/.urxvt/ext/font-size"
ln -sTf\
    "${cwd}/submodules/github.com/majutsushi/urxvt-font-size/font-size"\
    "${HOME}/.urxvt/ext/font-size"

