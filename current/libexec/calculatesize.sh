#!/bin/sh
# 
# Shell script to calculate the number of files in a directory and the
# directory's size. 

###       ###
### TO DO ###
###       ###

# 1) - Add support for iTerm graphical output on OS X.
# 2) - Finish help menu output display.
# 3) - Add support for checking programs.
# 4) - 

###          ###
### PROGRAMS ###
###          ###
FIND="/usr/bin/find"
XARGS="/usr/bin/xargs"
STAT="/usr/bin/stat"
PRINTF="/usr/bin/printf"
BASENAME="/usr/bin/basename"
DIRNAME="/usr/bin/dirname"
BYTES2HUMAN="$HOME/.libexec/bytes2human.awk"
BASE64="/usr/bin/base64"

###           ###
### VARIABLES ###
###           ###
FILE_SIZES_TOTAL_BYTES=0
FILE_SIZES_TOTAL_HUMAN=0
FILE_ICON="📄"
DIRECTORY_ICON="📁"

# Set input to a variable. 
DIRECTORY=$1

###        ###
### ARRAYS ###
###        ###
ARRAY_DIRECTORY_FILE_SIZES=()

###           ###
### FUNCTIONS ###
###           ###

# Show the Help menu:
fn_SHOW_HELP() {
    $PRINTF "HELP MENU:\n"
    exit 0
}

# Check for installed programs:
fn_CHECK_PROGRAMS() {
    $PRINTF "Programs.\n"
}

# Error Messages:
fn_ERROR_MESSAGE() {
    $PRINTF "ERROR: $*\n" 1>&2 
}

###      ###
### MAIN ###
###      ###

# Error Checking:
# Check for installed programs:
## Thinking about this, should I check for errors in this script, or assume
## what PROGRAMS sends over has already been cleaned? 
#if [ ! -e $FIND ]; then
#    $PRINTF "ERROR: Cannot find program, NAME at location: $FIND. Exiting.\n"
#    exit 1
#fi

# Check the directory:
if [ -z $DIRECTORY ]; then
# Is a directory supplied? No? Show the help menu.
    fn_SHOW_HELP
elif [ ! -d $DIRECTORY ]; then
# Is the supplied directory actually a directory?
    fn_ERROR_MESSAGE "$DIRECTORY is not a directory."
    exit 1
elif [ ! -r $DIRECTORY ]; then
# Is the supplied directory readable?
    fn_ERROR_MESSAGE "Directory $DIRECTORY is not readable."
    exit 1
fi

# External Scripts:
if [ ! -e $BYTES2HUMAN ]; then
# Does the script bytes2human exist?
    fn_ERROR_MESSAGE "Cannot find $BYTES2HUMAN."
    exit 1
elif [ ! -x $BYTES2HUMAN ]; then
# Is the script bytes2human executable?
    fn_ERROR_MESSAGE "$BYTES2HUMAN is not executable."
    exit 1
fi

# Populate the arrays.

# Determine the Operating System:
# OS X
if [[ "$OSTYPE" == "darwin"* ]]; then     
    ARRAY_DIRECTORY_FILE_SIZES=(`$FIND $DIRECTORY/* -maxdepth 1 -prune -type f -print0 | $XARGS -0 $STAT -f '%z'`)
    echo "ARRAY_DIRECTORY_FILE_SIZES is: ${ARRAY_DIRECTORY_FILE_SIZES[*]}"

    # If the Terminal is iTerm, use inline images. 
    if [ $TERM_PROGRAM == "iTerm.app" ]; then
        # iTerm Color Output goes here.
        $PRINTF "iTerm!\n"
    fi

#FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    #ARRAY_DIRECTORY_FILE_SIZES=`$LS -Al | $AWK '!/\// {print $5}'`
    ARRAY_DIRECTORY_FILE_SIZES=""
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    ARRAY_DIRECTORY_FILE_SIZES=""
else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi

# 
NUMBER_OF_FILES=${#ARRAY_DIRECTORY_FILE_SIZES[@]}
$PRINTF "Number of files in $DIRECTORY: $NUMBER_OF_FILES\n"

# Count up the bytes:
for ((i=0; i<${#ARRAY_DIRECTORY_FILE_SIZES[@]}; i++)) do
    FILE_SIZES_TOTAL_BYTES=$((FILE_SIZES_TOTAL_BYTES+ARRAY_DIRECTORY_FILE_SIZES[$i]))
done

echo "FILE_SIZES_TOTAL_BYTES is: $FILE_SIZES_TOTAL_BYTES"

# Convert bytes to human-readable:
$FILE_SIZES_TOTAL_HUMAN=$(eval $BYTES2HUMAN $FILE_SIZES_TOTAL_BYTES) 
#$FILE_SIZES_TOTAL_HUMAN=`$BYTES2HUMAN $FILE_SIZES_TOTAL_BYTES`

#for ((i=0; i<${#ARRAY_DIRECTORY_FILE_SIZES}; i++;)); do 
#    DIRECTORY_SIZE="DIRECTORY_SIZE+ARRAY_DIRECTORY_FILE_SIZES[i]"
#done

# Final output:
$PRINTF "$DIRECTORY_ICON $NUMBER_OF_DIRECTORIES $FILE_ICON $NUMBER_OF_FILES, $FILE_SIZES_TOTAL_HUMAN\n"

exit 0
# EOF
