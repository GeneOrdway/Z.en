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
# 4) - Add additional directory information to output.
# 5) - 

# Abort if any command exits with a non-zero value.
set -e

###          ###
### PROGRAMS ###
###          ###
FIND="/usr/bin/find"
XARGS="/usr/bin/xargs"
STAT="/usr/bin/stat"
DATE="/bin/date"
PRINTF="/usr/bin/printf"
BASENAME="/usr/bin/basename"
BYTES2HUMAN="$HOME/.bin/bytes2human.awk"
BASE64="/usr/bin/base64"

###           ###
### VARIABLES ###
###           ###
declare -i NOISE_LEVEL=3  # NOISE_LEVEL Levels:
                          # 1 - Silent 
                          # 2 - Error (aka quiet) 
                          # 3 - Info (default)
                          # 4 - Verbose 
                          # 5 - DebugFILE_SIZES_TOTAL_BYTES=0
# Triggers: 
declare -i NOISE_LEVEL_TRIGGERED=1  # False
declare -i FILE_SIZES_TOTAL_BYTES=0
FILE_SIZES_TOTAL_HUMAN="0"
STAT_ARGS="%Sp %#p %Su %u %Sg %g %Sa %Sm %Sc %SB"
#STAT_TIME_ARGS="%b %e %Y %l:%M:%S %p"
#STAT_TIME_ARGS="%b %e %Y %H:%M:%S"
STAT_TIME_ARGS="%b %e %Y %H:%M"

# Spacing: 
SPACER=" "
# Icons:
ICON_FILE="📄"
ICON_DIRECTORY="📁"
ICON_USER="👤"
ICON_GROUP="👥"
ICON_PERMISSIONS="🔐"
ICON_TIME_CLOCK="⏰"
ICON_TIME_MODIFIED="🕘"

# Set input to a variable. 
#DIRECTORY=$1

###        ###
### ARRAYS ###
###        ###
#declare -a ARRAY_ARGUMENTS=()
declare -a ARRAY_FILE_SIZES=()
declare -a ARRAY_SUBDIRECTORY_LIST=()
declare -a ARRAY_DIRECTORY_INFO=()

###           ###
### FUNCTIONS ###
###           ###

# Show the Help menu:
fn_SHOW_HELP() {
    $PRINTF "$SCRIPTNAME Help:\r
    \rUsage: $SCRIPTNAME [-dhqsv]\r
            \r
\rOr with POSIX-style arguments:\r
\rUsage: $SCRIPTNAME [--debug --help --quiet --silent --verbose] directory\r
\r
\rExample: $SCRIPTNAME -v /usr/local/bin \r
\rOR
\rExample: $SCRIPTNAME --verbose /usr/local/sbin \r
\r
\rGNU-STYLE:    | POSIX-STYLE:            | EXPLANATION:\r
\r______________|_________________________|_______________________________________\r
\r -d           | --debug                 | Debug output - Useful for scripting.\r
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

# Check to make sure NOISE_LEVEL_TRIGGERED hasn't already been triggered. 
fnNOISE_LEVEL_TRIGGERED_CHECK() {
    if [ $NOISE_LEVEL_TRIGGERED -eq 0 ]; then
        if [ $NOISE_LEVEL -ge 2 ]; then
            fn_ERROR_MESSAGE "Program cannot have multiple levels of noise selected."
        fi
        exit 1
    fi
}

###      ###
### MAIN ###
###      ###

# Error Checking:
# Make sure our programs exist at specified locations.
if [ ! -e $PRINTF ]; then
    # Cannot display error message with no program to print it.
    exit 1
fi

# Check for installed programs:
## Thinking about this, should I check for errors in this script, or assume
## what PROGRAMS sends over has already been cleaned? 
#if [ ! -e $FIND ]; then
#    $PRINTF "ERROR: Cannot find program, NAME at location: $FIND. Exiting.\n"
#    exit 1
#fi

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

# Check to make sure NOISE_LEVEL isn't too high.
if [ $NOISE_LEVEL -gt 5 ]; then 
    if [ $NOISE_LEVEL -ge 2 ]; then
        fn_ERROR_MESSAGE "Variable 'NOISE_LEVEL' is out of range."
    fi
    exit 1
fi

# Read in arguments supplied by user.
ARRAY_ARGUMENTS=($@) #Could also use $* for more control.
for ((i=0; i < ${#ARRAY_ARGUMENTS[*]}; i++)) do
    if [ $NOISE_LEVEL -eq 5 ]; then
        $PRINTF "DEBUG - ARRAY_ARGUMENTS[$i] is: ${ARRAY_ARGUMENTS[$i]}\n"
    fi
    
    # Check ARRAY_ARGUMENTS for a directory.
    if [[ "${ARRAY_ARGUMENTS[$i]}" =~ ^[/] ]]; then
        # Execute directory code here.
        DIRECTORY=${ARRAY_ARGUMENTS[$i]}
    fi
        # Check for ~ as home directory list, and make it valid.
    
    # Check for - here, then proceed with case statement.
    if [[ "${ARRAY_ARGUMENTS[$i]}" =~ ^[-][-dhqsTv] ]]; then 
        case ${ARRAY_ARGUMENTS[$i]} in
            *d* | --debug) fnNOISE_LEVEL_TRIGGERED_CHECK; NOISE_LEVEL=5; NOISE_LEVEL_TRIGGERED=0
            ;;
            *Gn* | --group-name)
            ;;
            *Gi* | --group-id)
            ;;
            *h* | --help) fnHELP; exit 0
            ;;
            *Ie* | --icon-emoji)
            ;;
            *Ii* | --icon-image)
            ;;
            *Il* | --icon-letter)
            ;;
            *In* | --icon-none)
            ;;
            *Pl* | --permissions-long)
            ;;
            *Pn* | --permissions-number)
            ;;
            *q* | --quiet) fnNOISE_LEVEL_TRIGGERED_CHECK; NOISE_LEVEL=2; NOISE_LEVEL_TRIGGERED=0
            ;;
            *s* | --silent) fnNOISE_LEVEL_TRIGGERED_CHECK; NOISE_LEVEL=1; NOISE_LEVEL_TRIGGERED=0
            ;;
            *Ta* | --time-access)
            ;;
            *TB* | --time-birth)
            ;;
            *Tc* | --time-change)
            ;;
            *Tm* | --time-modified) 
            ;;
            *Un* | --user-name)
            ;;
            *Ui* | --user-id)
            ;;
            *v* | --verbose) fnNOISE_LEVEL_TRIGGERED_CHECK; NOISE_LEVEL=4; NOISE_LEVEL_TRIGGERED=0
            ;;
            *) exit 1
            ;;
        esac
    fi
done

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

# Populate the arrays.

# Determine the Operating System:
# OS X
if [[ "$OSTYPE" == "darwin"* ]]; then     
    ARRAY_FILE_SIZES=(`$FIND $DIRECTORY/* -maxdepth 1 -prune -type f -print0 | $XARGS -0 $STAT -f '%z'`)
    ARRAY_SUBDIRECTORY_LIST=(`$FIND $DIRECTORY -maxdepth 1 -mindepth 1 -type d -exec $BASENAME {} \;`)
    ARRAY_DIRECTORY_INFO=(`$STAT -f "$STAT_ARGS" -t "$STAT_TIME_ARGS" $DIRECTORY`)
    CURRENT_YEAR=`$DATE +%Y`

# If the Terminal is iTerm, use inline images. 
#    if [ $TERM_PROGRAM == "iTerm.app" ]; then
        # iTerm Color Output goes here.
#        $PRINTF "iTerm!\n"
#    fi

#FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    ARRAY_FILE_SIZES=(`$FIND $DIRECTORY/* -maxdepth 1 -prune -type f -print0 | $XARGS -0 $STAT -f '%z'`)
    ARRAY_SUBDIRECTORY_LIST=(`$FIND $DIRECTORY -maxdepth 1 -mindepth 1 -type d -exec $BASENAME {} \;`)
    ARRAY_DIRECTORY_INFO=(`$STAT -f "$STAT_ARGS" -t "$STAT_TIME_ARGS" $DIRECTORY`)
    CURRENT_YEAR=`$DATE +%Y`
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    ARRAY_FILE_SIZES=()
    ARRAY_SUBDIRECTORY_LIST=()
    ARRAY_DIRECTORY_INFO=(`$STAT -s $DIRECTORY`)
    CURRENT_YEAR=`$DATE +%Y`
else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi

# Count up the number of files: 
NUMBER_OF_FILES=${#ARRAY_FILE_SIZES[@]}

# Count up the number of directories: 
NUMBER_OF_DIRECTORIES=${#ARRAY_SUBDIRECTORY_LIST[@]}

# Count up the bytes:
for ((i=0; i < ${#ARRAY_FILE_SIZES[@]}; i++)) do
    FILE_SIZES_TOTAL_BYTES=$((FILE_SIZES_TOTAL_BYTES+ARRAY_FILE_SIZES[$i]))
done

# Convert bytes to a more human-readable format:
FILE_SIZES_TOTAL_HUMAN=`$BYTES2HUMAN $FILE_SIZES_TOTAL_BYTES`

# Debugging information:
if [ $NOISE_LEVEL -eq 5 ]; then 
    $PRINTF "DEBUG - Number of files in $DIRECTORY: $NUMBER_OF_FILES\n"
    $PRINTF "DEBUG - Number of directories in $DIRECTORY: ${#ARRAY_SUBDIRECTORY_LIST[@]}\n"
    $PRINTF "DEBUG - BYTES2HUMAN script location is: $BYTES2HUMAN\n"
    $PRINTF "DEBUG - FILE_SIZES_TOTAL_BYTES is: $FILE_SIZES_TOTAL_BYTES\n"
    $PRINTF "DEBUG - FILE_SIZES_TOTAL_HUMAN is: $FILE_SIZES_TOTAL_HUMAN\n"
fi

# Assign input array names to variables for easier readability:
PERMISSIONS_LONG="${ARRAY_DIRECTORY_INFO[0]}"
PERMISSIONS_NUMBER="${ARRAY_DIRECTORY_INFO[1]:(-3)}"
USER_NAME="${ARRAY_DIRECTORY_INFO[2]}"
USER_ID="${ARRAY_DIRECTORY_INFO[3]}"
GROUP_NAME="${ARRAY_DIRECTORY_INFO[4]}"
GROUP_ID="${ARRAY_DIRECTORY_INFO[5]}"

if [ $NOISE_LEVEL -eq 5 ]; then
    TIME_ACCESS="${ARRAY_DIRECTORY_INFO[6]} ${ARRAY_DIRECTORY_INFO[7]} ${ARRAY_DIRECTORY_INFO[8]} ${ARRAY_DIRECTORY_INFO[9]}"
    TIME_MODIFIED="${ARRAY_DIRECTORY_INFO[10]} ${ARRAY_DIRECTORY_INFO[11]} ${ARRAY_DIRECTORY_INFO[12]} ${ARRAY_DIRECTORY_INFO[13]}"
    TIME_CHANGE="${ARRAY_DIRECTORY_INFO[14]} ${ARRAY_DIRECTORY_INFO[15]} ${ARRAY_DIRECTORY_INFO[16]} ${ARRAY_DIRECTORY_INFO[17]}"
    TIME_BIRTH="${ARRAY_DIRECTORY_INFO[18]} ${ARRAY_DIRECTORY_INFO[19]} ${ARRAY_DIRECTORY_INFO[20]} ${ARRAY_DIRECTORY_INFO[21]}"
fi

# Old settings for TIME_* variables. These match commented-out 
# STAT_TIME_ARGS above 
#TIME_ACCESS="${ARRAY_DIRECTORY_INFO[6]} ${ARRAY_DIRECTORY_INFO[7]} ${ARRAY_DIRECTORY_INFO[8]} ${ARRAY_DIRECTORY_INFO[9]} ${ARRAY_DIRECTORY_INFO[10]}"
#TIME_MODIFIED="${ARRAY_DIRECTORY_INFO[11]} ${ARRAY_DIRECTORY_INFO[12]} ${ARRAY_DIRECTORY_INFO[13]} ${ARRAY_DIRECTORY_INFO[14]} ${ARRAY_DIRECTORY_INFO[15]}"
#TIME_CHANGE="${ARRAY_DIRECTORY_INFO[16]} ${ARRAY_DIRECTORY_INFO[17]} ${ARRAY_DIRECTORY_INFO[18]} ${ARRAY_DIRECTORY_INFO[19]} ${ARRAY_DIRECTORY_INFO[20]}"
#TIME_BIRTH="${ARRAY_DIRECTORY_INFO[21]} ${ARRAY_DIRECTORY_INFO[22]} ${ARRAY_DIRECTORY_INFO[23]} ${ARRAY_DIRECTORY_INFO[24]} ${ARRAY_DIRECTORY_INFO[25]}"

# Display timestamps in a similar fashion to ls -- If they're in the current
# year, show the hours, minutes and seconds -- If not, show the year. 
# Time - Access:
if [ ${ARRAY_DIRECTORY_INFO[8]} = $CURRENT_YEAR ]; then
    TIME_ACCESS="${ARRAY_DIRECTORY_INFO[6]} ${ARRAY_DIRECTORY_INFO[7]} ${ARRAY_DIRECTORY_INFO[9]}"
else
    TIME_ACCESS="${ARRAY_DIRECTORY_INFO[6]} ${ARRAY_DIRECTORY_INFO[7]} ${ARRAY_DIRECTORY_INFO[8]}"
fi
# Time - Modified:
if [ ${ARRAY_DIRECTORY_INFO[12]} = $CURRENT_YEAR ]; then
    TIME_MODIFIED="${ARRAY_DIRECTORY_INFO[10]} ${ARRAY_DIRECTORY_INFO[11]} ${ARRAY_DIRECTORY_INFO[13]}"
else
    TIME_MODIFIED="${ARRAY_DIRECTORY_INFO[10]} ${ARRAY_DIRECTORY_INFO[11]} ${ARRAY_DIRECTORY_INFO[12]}"
fi 
# Time - Change:
if [ ${ARRAY_DIRECTORY_INFO[16]} = $CURRENT_YEAR ]; then
    TIME_CHANGE="${ARRAY_DIRECTORY_INFO[14]} ${ARRAY_DIRECTORY_INFO[15]} ${ARRAY_DIRECTORY_INFO[17]}"
else
    TIME_CHANGE="${ARRAY_DIRECTORY_INFO[14]} ${ARRAY_DIRECTORY_INFO[15]} ${ARRAY_DIRECTORY_INFO[16]}"
fi
# Time - Birth:
if [ ${ARRAY_DIRECTORY_INFO[20]} = $CURRENT_YEAR ]; then
    TIME_BIRTH="${ARRAY_DIRECTORY_INFO[18]} ${ARRAY_DIRECTORY_INFO[19]} ${ARRAY_DIRECTORY_INFO[21]}"
else
    TIME_BIRTH="${ARRAY_DIRECTORY_INFO[18]} ${ARRAY_DIRECTORY_INFO[19]} ${ARRAY_DIRECTORY_INFO[20]}"
fi

# Debugging information:
if [ $NOISE_LEVEL -eq 5 ]; then 
    $PRINTF "DEBUG - Whole ARRAY_DIRECTORY_INFO is: ${ARRAY_DIRECTORY_INFO[*]}\n"
    $PRINTF "DEBUG - PERMISSIONS_LONG is: $PERMISSIONS_LONG\n"
    $PRINTF "DEBUG - PERMISSIONS_NUMBER is: $PERMISSIONS_NUMBER\n"
    $PRINTF "DEBUG - USER_NAME is: $USER_NAME\n"
    $PRINTF "DEBUG - USER_ID is: $USER_ID\n"
    $PRINTF "DEBUG - GROUP_NAME is: $GROUP_NAME\n"
    $PRINTF "DEBUG - GROUP_ID is: $GROUP_ID\n"
    $PRINTF "DEBUG - TIME_ACCESS is: $TIME_ACCESS\n"
    $PRINTF "DEBUG - TIME_MODIFIED is: $TIME_MODIFIED\n"
    $PRINTF "DEBUG - TIME_CHANGE is: $TIME_CHANGE\n"
    $PRINTF "DEBUG - TIME_BIRTH is: $TIME_BIRTH\n"
    $PRINTF "DEBUG - CURRENT_YEAR is: $CURRENT_YEAR\n"
    $PRINTF "DEBUG - Stat year is: ${ARRAY_DIRECTORY_INFO[12]}\n"
fi

# Standardize the output:
## Extended:
#PERMISSIONS_OUTPUT="$ICON_PERMISSIONS $PERMISSIONS_LONG($PERMISSIONS_NUMBER)"
#USER_OUTPUT="$ICON_USER $USER_NAME($USER_ID)"
#GROUP_OUTPUT="$ICON_GROUP $GROUP_NAME($GROUP_ID)"
#FILE_SIZE_OUTPUT="$ICON_DIRECTORY $NUMBER_OF_DIRECTORIES $ICON_FILE $NUMBER_OF_FILES, $FILE_SIZES_TOTAL_HUMAN"
#TIME_OUTPUT="$ICON_TIME_MODIFIED $TIME_MODIFIED $ICON_TIME_MODIFIED $TIME_BIRTH"
## Normal:
PERMISSIONS_OUTPUT="$ICON_PERMISSIONS_LONG $PERMISSIONS"
USER_OUTPUT="$ICON_USER $USER_NAME"
GROUP_OUTPUT="$ICON_GROUP $GROUP_NAME"
FILE_SIZE_OUTPUT="$ICON_DIRECTORY $NUMBER_OF_DIRECTORIES $ICON_FILE $NUMBER_OF_FILES, $FILE_SIZES_TOTAL_HUMAN"
TIME_OUTPUT="$ICON_TIME_MODIFIED $TIME_MODIFIED"
## Condensed:
#PERMISSIONS_OUTPUT="$ICON_PERMISSIONS $PERMISSIONS_NUMBER"
#USER_OUTPUT="$ICON_USER $USER_ID"
#GROUP_OUTPUT="$ICON_GROUP $GROUP_ID"
#FILE_SIZE_OUTPUT="$ICON_DIRECTORY $NUMBER_OF_DIRECTORIES $ICON_FILE $NUMBER_OF_FILES, $FILE_SIZES_TOTAL_HUMAN"
#TIME_OUTPUT="$ICON_TIME_MODIFIED $TIME_MODIFIED"

# And finally, print the output:
$PRINTF "$PERMISSIONS_OUTPUT$USER_OUTPUT$GROUP_OUTPUT$FILE_SIZE_OUTPUT$TIME_OUTPUT\n"

exit 0
# EOF
