# Desktop

## Upcoming Changes

 - Moving configuration management to Ansible

## Overview

These are my updated dotfiles, that I am using on a daily basis.

This comes with a clean and "safe" deploy script. This will symbolically link
config files for, and more; please read the `./deploy.sh` script.

 - Terminal Coloring
 - Xresources
 - xmodmaprc
 - lightdm
 - bashrc
 - vim
 - vimrc

## Installation

Use `./deploy.sh` after installing the packages from `./packages`

## Adding Submodule

```
$ git submodule add -- url.com/a/b submodules/a/b
$ vim deploy.sh
# Change it to make symlinks
```
