#!/bin/sh
#
# Install script for dotfiles
#

###              ###
### LICENSE INFO ###
###              ###

# Written by Gene Ordway
# http://www.geneordway.com
# GeneOrdway@Gmail.com
#
# 

###       ###
### TO DO ###
###       ###

# 1 - 

###           ###
### VARIABLES ###
###           ###

FILES="
gitconfig
gitignore
screenrc
vim
vimrc
Xdefaults
xmonad
xsession
zsh
zshrc
"

###          ###
### PROGRAMS ###
###          ###
CP="/bin/cp"
MV="/bin/mv"
LN="/bin/ln"

###      ###
### MAIN ###
###      ###

# Create symbolic links for all configuration files
for file in $FILES
do
	SOURCE="$HOME/dots/$file"
	TARGET="$HOME/.$file"

	# Create backup file if the target already exists and is not a symlink
	if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
		echo "WARNING: $TARGET already exists; moving to $file.old"
		$MV "$TARGET" "$TARGET.old"
	fi
	case $OSTYPE in
		darwin*)
			$LN -hnfsv "$SOURCE" "$TARGET"
			;;
		linux*)
			$LN -fnsv "$SOURCE" "$TARGET"
			;;
	esac
done

exit 0
#EOF
