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
BASENAME="/usr/bin/basename"
DIRNAME="/usr/bin/dirname"
CP="/bin/cp"
MV="/bin/mv"
LN="/bin/ln"
PIP="/usr/local/bin/pip"

###        ###
### ARRAYS ###
###        ###
PAYLOAD=()

###           ###
### FUNCTIONS ###
###           ###

# 
fn_SYMLINK_PROGRAMS() {
    echo "asdf"
}

#
fn_COPY_PROGRAMS() {
    echo "asdf"
}

# Install third-party applications that are helpful
fn_THIRD_PARTY_PROGRAMS() {
    # Pygments for colorized cat output
    $PIP install Pygments
    if [[ $? != 0 ]]; then
        $PRINTF "Failed to install Pygments.\n"
    fi    
}

###      ###
### MAIN ###
###      ###

# Create symbolic links for all configuration files
for file in $FILES
do
    SOURCE="$HOME/Z.en/current/$file"
	TARGET="$HOME/.$file"

	# Create backup file if the target already exists and is not a symlink
	if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
		echo "WARNING: $TARGET already exists; moving to $file.old"
		$MV "$TARGET" "$TARGET.old"
    fi

    # Detect operating system:
    case $OSTYPE in
		darwin*)
			$LN -hnfsv "$SOURCE" "$TARGET"
			;;
        *bsd)
            $LN -hnfsv "$SOURCE" "$TARGET"
            ;;
        linux*)
			$LN -fnsv "$SOURCE" "$TARGET"
			;;
	esac
done

exit 0
#EOF
