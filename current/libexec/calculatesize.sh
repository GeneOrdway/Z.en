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
ARRAY_FILE_SIZES=()
ARRAY_SUBDIRECTORY_LIST=()

###           ###
### FUNCTIONS ###
###           ###

# Show the Help menu:
fn_SHOW_HELP() {
    $PRINTF "$SCRIPTNAME Help:\r
    \rUsage: $SCRIPTNAME [-dhqsv] [-a directory] [-b directory] [-f file]\r
            \r
\rOr with POSIX-style arguments:\r
\rUsage: $SCRIPTNAME [--debug --help --quiet --silent --verbose]\r
\r
\rExample: $SCRIPTNAME -v -a /usr/local/bin /usr/local/sbin -b /bin \r
\rOR
\rExample: $SCRIPTNAME --verbose --pre-append /usr/local/sbin --post-append /bin \r
\r
\rGNU-STYLE:    | POSIX-STYLE:            | EXPLANATION:\r
\r______________|_________________________|_______________________________________\r
\r -d           | --debug                 | Debug output - Useful for scripting.\r
\r -f file      | --file                  | Specify configuration file.\r
\r -h           | --help                  | Print this help menu.\r
\r -q           | --quiet                 | Quiet output - Errors messages only.\r
\r -s           | --silent                | Silent output - No messages.\r
\r -v           | --verbose               | Verbose output - See all messages. \n"
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
    ARRAY_FILE_SIZES=(`$FIND $DIRECTORY/* -maxdepth 1 -prune -type f -print0 | $XARGS -0 $STAT -f '%z'`)
    ARRAY_SUBDIRECTORY_LIST=(`$FIND $DIRECTORY -maxdepth 1 -mindepth 1 -type d -exec $BASENAME {} \;`)
    echo "ARRAY_FILE_SIZES is: ${ARRAY_FILE_SIZES[*]}"
    echo "ARRAY_SUBDIRECTORY_LIST is: ${#ARRAY_SUBDIRECTORY_LIST[@]}"

    # If the Terminal is iTerm, use inline images. 
    if [ $TERM_PROGRAM == "iTerm.app" ]; then
        # iTerm Color Output goes here.
        $PRINTF "iTerm!\n"
    fi

#FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    #ARRAY_FILE_SIZES=`$LS -Al | $AWK '!/\// {print $5}'`
    ARRAY_FILE_SIZES=""
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    ARRAY_FILE_SIZES=""
else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi

# 
NUMBER_OF_FILES=${#ARRAY_FILE_SIZES[@]}
$PRINTF "Number of files in $DIRECTORY: $NUMBER_OF_FILES\n"

# 
NUMBER_OF_DIRECTORIES=${#ARRAY_SUBDIRECTORY_LIST[@]}
$PRINTF "Number of directories in $DIRECTORY: ${#ARRAY_SUBDIRECTORY_LIST[@]}\n"

# Count up the bytes:
for ((i=0; i<${#ARRAY_FILE_SIZES[@]}; i++)) do
    FILE_SIZES_TOTAL_BYTES=$((FILE_SIZES_TOTAL_BYTES+ARRAY_FILE_SIZES[$i]))
done

echo "FILE_SIZES_TOTAL_BYTES is: $FILE_SIZES_TOTAL_BYTES"

echo "BYTES2HUMAN is: $BYTES2HUMAN"

# Convert bytes to human-readable:
$FILE_SIZES_TOTAL_HUMAN=$("$BYTES2HUMAN $FILE_SIZES_TOTAL_BYTES")
#$FILE_SIZES_TOTAL_HUMAN=$($BYTES2HUMAN $FILE_SIZES_TOTAL_BYTES) 
#$FILE_SIZES_TOTAL_HUMAN=`$BYTES2HUMAN $FILE_SIZES_TOTAL_BYTES`

# Final output:
$PRINTF "$DIRECTORY_ICON $NUMBER_OF_DIRECTORIES $FILE_ICON $NUMBER_OF_FILES, $FILE_SIZES_TOTAL_HUMAN\n"

exit 0
# EOF
