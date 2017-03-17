#!/bin/sh
# 
# Shell script to calculate the number of files in a directory and the
# directory's size. 

###       ###
### TO DO ###
###       ###

# 1) - Add support for checking programs.
# 2) - Add support for iTerm graphical output on OS X - image icons.
# 3) - Display information based upon order in which user specified
#       parameters at execution time.
# 4) - 
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
declare -i NOISE_LEVEL_TRIGGERED=1      # False
declare -i ICON_TRIGGERED=1             # False
declare -i FORMAT_TRIGGERED=1           # False

# Flags:
declare -i ICON_EMOJI_FLAG=1            # False
declare -i ICON_LETTER_FLAG=1           # False
declare -i ICON_IMAGE_FLAG=1            # False
declare -i PERMISSIONS_LONG_FLAG=1      # False
declare -i PERMISSIONS_NUMBER_FLAG=1    # False
declare -i USER_NAME_FLAG=1             # False
declare -i USER_ID_FLAG=1               # False
declare -i GROUP_NAME_FLAG=1            # False
declare -i GROUP_ID_FLAG=1              # False
declare -i TIME_ACCESS_FLAG=1           # False
declare -i TIME_CHANGE_FLAG=1           # False
declare -i TIME_MODIFIED_FLAG=1         # False
declare -i TIME_BIRTH_FLAG=1            # False
declare -i CONDENSED_FLAG=1             # False
declare -i EXTENDED_FLAG=1              # False

declare -i FILE_SIZES_TOTAL_BYTES=0
FILE_SIZES_TOTAL_HUMAN="0"
# FILE_SIZES_TOTAL_HUMAN will become a 'floating point' variable, which the
# shell interprets as a string, so therefore, we cannot declare it as an
# integer without breaking things.

# I should probably re-integrate these back into the OS section where they
# are called.
#STAT_TIME_ARGS="%b %e %Y %l:%M:%S %p"
#STAT_TIME_ARGS="%b %e %Y %H:%M:%S"
STAT_TIME_ARGS="%b %e %Y %H:%M"

# Spacing: 
SPACER=""
# Icons:
ICON_FILE=""
ICON_DIRECTORY=""
ICON_USER=""
ICON_GROUP=""
ICON_PERMISSIONS=""
ICON_TIME_ACCESS=""
ICON_TIME_MODIFIED=""
ICON_TIME_CHANGE=""
ICON_TIME_BIRTH=""

# After adding program checks, there should be error-checking for this to 
# make sure basename is installed before setting the variable's name.
SCRIPTNAME=`$BASENAME $0`

###        ###
### ARRAYS ###
###        ###
declare -a ARRAY_ARGUMENTS=()
declare -a ARRAY_FILE_SIZES=()
declare -a ARRAY_SUBDIRECTORY_LIST=()
declare -a ARRAY_DIRECTORY_INFO=()

###           ###
### FUNCTIONS ###
###           ###

# Show the Help menu:
fn_SHOW_HELP() {
    $PRINTF "$SCRIPTNAME Help:\r
    \rUsage: $SCRIPTNAME [-abCcdEeGghilmPpqsUuv]\r
            \r
\rOr with POSIX-style arguments:\r
\rUsage: $SCRIPTNAME [--debug --group-name --group-id --help --icon-emoji --icon-image\r 
\r          --icon-letter --permission-long --permissions-id --quiet --silent --time-access\r 
\r          --time-birth --time-change --time-modified --user-name --user-id --verbose] directory\r
\r
\rExample: $SCRIPTNAME -v /usr/local/bin \r
\rOR
\rExample: $SCRIPTNAME --verbose /usr/local/sbin \r
\r
\rGNU-STYLE: | POSIX-STYLE:         | EXPLANATION:\r
\r___________|______________________|_____________________________________________\r
\r -a        | --time-access        | Display the last time files were accessed.\r
\r -b        | --time-birth         | Display the creation time of the directory.\r
\r -C        | --format-condensed   | Display directory access in condensed format\r
\r -c        | --time-change        | Display the last time files were changed.\r 
\r -d        | --debug              | Debug output - Useful for scripting.\r
\r -e        | --icon-emoji         | Display 'icons' as emojis.\r
\r -G        | --group-name         | Display the group name.\r 
\r -g        | --group-id           | Display the group ID.\r
\r -h        | --help               | Print this help menu.\r
\r -i        | --icon-image         | Display 'icons' as images. Note: OS X Only.\r 
\r -l        | --icon-letter        | Display 'icons' as letters.\r
\r -m        | --time-modified      | Display the last time files were modified.\r
\r -P        | --permissions-long   | Display directory permissions as rwxrwxrwx\r 
\r -p        | --permissions-number | Display directory permissions as numbers.\r 
\r -q        | --quiet              | Quiet output - Errors messages only.\r
\r -s        | --silent             | Silent output - No messages.\r
\r -U        | --user-name          | Display the user name.\r
\r -u        | --user-id            | Display the user ID.\r
\r -v        | --verbose            | Verbose output - See all messages. \n"
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

# Check to make sure ICON_CHECK_TRIGGERED hasn't already been triggered.
fnICON_CHECK() {
    if [ $ICON_TRIGGERED -eq 0 ]; then
        if [ $NOISE_LEVEL -ge 2 ]; then
            fn_ERROR_MESSAGE "Program cannot have multiple types of icons selected."
        fi
        exit 1
    fi
}

# Check to make sure FORMAT_TRIGGERED hasn't already been triggered.
fnFORMAT_CHECK() {
    if [ $FORMAT_TRIGGERED -eq 0 ]; then
        if [ $NOISE_LEVEL -ge 2 ]; then
            fn_ERROR_MESSAGE "Program cannot have multiple format options selected."
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
ARRAY_ARGUMENTS_LENGTH=${#ARRAY_ARGUMENTS[*]}
for ((i=0; i < $ARRAY_ARGUMENTS_LENGTH; i++)) do
ARRAY_ARGUMENTS_POSITION=$i
    if [ $NOISE_LEVEL -eq 5 ]; then
        $PRINTF "DEBUG - ARRAY_ARGUMENTS[$i] is: ${ARRAY_ARGUMENTS[$i]}\n"
        $PRINTF "DEBUG - ARRAY_ARGUMENTS_LENGTH is: $ARRAY_ARGUMENTS_LENGTH\n"
        $PRINTF "DEBUG - ARRAY_ARGUMENTS_POSITION is: $ARRAY_ARGUMENTS_POSITION\n"
    fi
    # Check ARRAY_ARGUMENTS for a directory.
    if [[ "${ARRAY_ARGUMENTS[$i]}" =~ ^[/] ]]; then
        # Execute directory code here.
        DIRECTORY=${ARRAY_ARGUMENTS[$i]}
    fi
    # Check for - here, then proceed with case statement.
    if [[ "${ARRAY_ARGUMENTS[$i]}" =~ ^[-][-a-zA-Z0-9]* ]]; then 
        # The above checks for a legitimate argument, whether GNU or POSIX-styled.
        # The below checks for GNU-specific arguments.
        if [[ "${ARRAY_ARGUMENTS[$i]}" =~ ^[-][a-zA-Z0-9]{1} ]]; then
            # If the length of a GNU-style argument is greater than 1,
            # break it apart into new elements of ARRAY_ARGUMENTS.
            if [[ "${#ARRAY_ARGUMENTS[$i]}" -gt 1 ]]; then
                # Figure out where we are in ARRAY_ARGUMENTS
                ARG_LENGTH=${#ARRAY_ARGUMENTS[$i]}
                for ((ARG_POSITION=0; ARG_POSITION < $ARG_LENGTH; ARG_POSITION++)) do 
                    ((ARG_COUNT++))
                done
                # Now move the elements.
            ((ARG_REMAIN=$ARG_LENGTH - $ARG_POSITION))
            fi
        fi 
        # Now we can read in the arguments.
        case ${ARRAY_ARGUMENTS[$i]} in
            -a | --time-access) TIME_ACCESS_FLAG=0
            ;;
            -b | --time-birth) TIME_BIRTH_FLAG=0
            ;;
            -C | --format-condensed) fnFORMAT_CHECK; CONDENSED_FLAG=0; FORMAT_TRIGGERED=0 
            ;;
            -c | --time-change) TIME_CHANGE_FLAG=0
            ;; 
            -d | --debug) fnNOISE_LEVEL_TRIGGERED_CHECK; NOISE_LEVEL=5; NOISE_LEVEL_TRIGGERED=0
            ;;
            -E | --format-extended) fnFORMAT_CHECK; EXTENDED_FLAG=0; FORMAT_TRIGGERED=0
            ;;
            -e | --icon-emoji) fnICON_CHECK; ICON_EMOJI_FLAG=0; ICON_TRIGGERED=0; SPACER=""
            ;;
            -G | --group-name) GROUP_NAME_FLAG=0
            ;;
            -g | --group-id) GROUP_ID_FLAG=0
            ;;
            -h | --help) fnHELP; exit 0
            ;;
            -i | --icon-image) fnICON_CHECK; ICON_IMAGE_FLAG=0; ICON_IMAGE_FLAG=0
            ;;
            -l | --icon-letter) fnICON_CHECK; ICON_LETTER_FLAG=0; ICON_TRIGGERED=0
            ;;
            -m | --time-modified) TIME_MODIFIED_FLAG=0 
            ;;
            -P | --permissions-long) PERMISSIONS_LONG_FLAG=0
            ;;
            -p | --permissions-number) PERMISSIONS_NUMBER_FLAG=0
            ;;
            -q | --quiet) fnNOISE_LEVEL_TRIGGERED_CHECK; NOISE_LEVEL=2; NOISE_LEVEL_TRIGGERED=0
            ;;
            -s | --silent) fnNOISE_LEVEL_TRIGGERED_CHECK; NOISE_LEVEL=1; NOISE_LEVEL_TRIGGERED=0
            ;;
            -U | --user-name) USER_NAME_FLAG=0
            ;;
            -u | --user-id) USER_ID_FLAG=0
            ;;
            -v | --verbose) fnNOISE_LEVEL_TRIGGERED_CHECK; NOISE_LEVEL=4; NOISE_LEVEL_TRIGGERED=0
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
    ARRAY_DIRECTORY_INFO=(`$STAT -f "%Sp %#p %Su %u %Sg %g %Sa %Sm %Sc %SB" -t "$STAT_TIME_ARGS" $DIRECTORY`)
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
    ARRAY_DIRECTORY_INFO=(`$STAT -f "%Sp %#p %Su %u %Sg %g %Sa %Sm %Sc %SB" -t "$STAT_TIME_ARGS" $DIRECTORY`)
    CURRENT_YEAR=`$DATE +%Y`
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    ARRAY_FILE_SIZES=(`$FIND $DIRECTORY/* -maxdepth 1 -prune -type f -print0 | $XARGS -0 $STAT -f '%z'`)
    ARRAY_SUBDIRECTORY_LIST=(`$FIND $DIRECTORY -maxdepth 1 -mindepth 1 -type d -exec $BASENAME {} \;`)
    ARRAY_DIRECTORY_INFO=(`$STAT -f "%Sp %#p %Su %u %Sg %g %Sa %Sm %Sc %SB" -t "$STAT_TIME_ARGS" $DIRECTORY`)
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

# Debugging Information:
if [ $NOISE_LEVEL -eq 5 ]; then
    TIME_ACCESS="${ARRAY_DIRECTORY_INFO[6]} ${ARRAY_DIRECTORY_INFO[7]} ${ARRAY_DIRECTORY_INFO[8]} ${ARRAY_DIRECTORY_INFO[9]}"
    TIME_MODIFIED="${ARRAY_DIRECTORY_INFO[10]} ${ARRAY_DIRECTORY_INFO[11]} ${ARRAY_DIRECTORY_INFO[12]} ${ARRAY_DIRECTORY_INFO[13]}"
    TIME_CHANGE="${ARRAY_DIRECTORY_INFO[14]} ${ARRAY_DIRECTORY_INFO[15]} ${ARRAY_DIRECTORY_INFO[16]} ${ARRAY_DIRECTORY_INFO[17]}"
    TIME_BIRTH="${ARRAY_DIRECTORY_INFO[18]} ${ARRAY_DIRECTORY_INFO[19]} ${ARRAY_DIRECTORY_INFO[20]} ${ARRAY_DIRECTORY_INFO[21]}"
fi

# Assign input array names to variables for easier readability:
# Icons - Emoji:
# Note: Emojis need an additional space to accommodate for their size.
if [ $ICON_EMOJI_FLAG -eq 0 ]; then
    ICON_FILE="📄 "
    ICON_DIRECTORY="📁 "
    ICON_USER="👤 "
    ICON_GROUP="👥 "
    ICON_PERMISSIONS="🔐 "
    ICON_TIME_ACCESS="🕘 "
    ICON_TIME_MODIFIED="🕘 "
    ICON_TIME_CHANGE="🕘 "
    ICON_TIME_BIRTH="🕘 "
fi

# Icons - Letter:
if [ $ICON_LETTER_FLAG -eq 0 ]; then
    ICON_FILE="F:"
    ICON_DIRECTORY="D:"
    ICON_USER="U:"
    ICON_GROUP="G:"
    ICON_PERMISSIONS="P:"
    ICON_TIME_ACCESS="Ta:"
    ICON_TIME_MODIFIED="Tm:"
    ICON_TIME_CHANGE="Tc:"
    ICON_TIME_BIRTH="Tb:"
fi
    
# Icons - Image:
# Note: This is only supported under OS X with iTerm 2.
if [ $ICON_IMAGE_FLAG -eq 0 ]; then
    ICON_FILE=""
    ICON_DIRECTORY=""
    ICON_USER=""
    ICON_GROUP=""
    ICON_PERMISSIONS=""
    ICON_TIME_ACCESS=""
    ICON_TIME_MODIFIED=""
    ICON_TIME_CHANGE=""
    ICON_TIME_BIRTH=""
fi

# Icons - None:
if [[ $ICON_EMOJI_FLAG -eq 1 && $ICON_LETTER_FLAG -eq 1 && $ICON_IMAGE_FLAG -eq 1 ]]; then
    ICON_FILE="Files:"
    ICON_DIRECTORY="Directories:"
    ICON_USER=" "
    ICON_GROUP=" "
    ICON_PERMISSIONS=" "
    ICON_TIME_ACCESS=" "
    ICON_TIME_MODIFIED=" "
    ICON_TIME_CHANGE=" "
    ICON_TIME_BIRTH=" "
fi

# Permissions long format: 
if [ $PERMISSIONS_LONG_FLAG -eq 0 ]; then
    PERMISSIONS_LONG="${ARRAY_DIRECTORY_INFO[0]}"
else
    PERMISSIONS_LONG=""
    ICON_PERMISSIONS=""
fi

# Permissions number:
if [ $PERMISSIONS_NUMBER_FLAG -eq 0 ]; then
    # Note: We need only the last 3 numbers from this string.
    PERMISSIONS_NUMBER="${ARRAY_DIRECTORY_INFO[1]:(-3)}"
else
    PERMISSIONS_NUMBER=""
fi

# User Name:
if [ $USER_NAME_FLAG -eq 0 ]; then
    USER_NAME="${ARRAY_DIRECTORY_INFO[2]}"
else
    USER_NAME=""
    ICON_USER=""
fi

# User ID:
if [ $USER_ID_FLAG -eq 0 ]; then
    USER_ID="${ARRAY_DIRECTORY_INFO[3]}"
else
    USER_ID=""
fi

# Group Name:
if [ $GROUP_NAME_FLAG -eq 0 ]; then
    GROUP_NAME="${ARRAY_DIRECTORY_INFO[4]}"
else
    GROUP_NAME=""
    ICON_GROUP=""
fi

# Group ID:
if [ $GROUP_ID_FLAG -eq 0 ]; then    
    GROUP_ID="${ARRAY_DIRECTORY_INFO[5]}"
else
    GROUP_ID=""
fi

# Old settings for TIME_* variables. These match commented-out 
# STAT_TIME_ARGS above. To use, comment out the Time section below and
# uncomment these. 
#TIME_ACCESS="${ARRAY_DIRECTORY_INFO[6]} ${ARRAY_DIRECTORY_INFO[7]} ${ARRAY_DIRECTORY_INFO[8]} ${ARRAY_DIRECTORY_INFO[9]} ${ARRAY_DIRECTORY_INFO[10]}"
#TIME_MODIFIED="${ARRAY_DIRECTORY_INFO[11]} ${ARRAY_DIRECTORY_INFO[12]} ${ARRAY_DIRECTORY_INFO[13]} ${ARRAY_DIRECTORY_INFO[14]} ${ARRAY_DIRECTORY_INFO[15]}"
#TIME_CHANGE="${ARRAY_DIRECTORY_INFO[16]} ${ARRAY_DIRECTORY_INFO[17]} ${ARRAY_DIRECTORY_INFO[18]} ${ARRAY_DIRECTORY_INFO[19]} ${ARRAY_DIRECTORY_INFO[20]}"
#TIME_BIRTH="${ARRAY_DIRECTORY_INFO[21]} ${ARRAY_DIRECTORY_INFO[22]} ${ARRAY_DIRECTORY_INFO[23]} ${ARRAY_DIRECTORY_INFO[24]} ${ARRAY_DIRECTORY_INFO[25]}"

# Display timestamps in a similar fashion to ls -- If they're in the current
# year, show the hours, minutes and seconds -- If not, show the year. 
# Time - Access:
if [ $TIME_ACCESS_FLAG -eq 0 ]; then
    if [ ${ARRAY_DIRECTORY_INFO[8]} = $CURRENT_YEAR ]; then
        TIME_ACCESS="${ARRAY_DIRECTORY_INFO[6]} ${ARRAY_DIRECTORY_INFO[7]} ${ARRAY_DIRECTORY_INFO[9]}"
    else
        TIME_ACCESS="${ARRAY_DIRECTORY_INFO[6]} ${ARRAY_DIRECTORY_INFO[7]} ${ARRAY_DIRECTORY_INFO[8]}"
    fi
else
    TIME_ACCESS=""
    ICON_TIME_ACCESS=""
fi
# Time - Modified:
if [ $TIME_MODIFIED_FLAG -eq 0 ]; then
    if [ ${ARRAY_DIRECTORY_INFO[12]} = $CURRENT_YEAR ]; then
        TIME_MODIFIED="${ARRAY_DIRECTORY_INFO[10]} ${ARRAY_DIRECTORY_INFO[11]} ${ARRAY_DIRECTORY_INFO[13]}"
    else
        TIME_MODIFIED="${ARRAY_DIRECTORY_INFO[10]} ${ARRAY_DIRECTORY_INFO[11]} ${ARRAY_DIRECTORY_INFO[12]}"
    fi 
else
    TIME_MODIFIED=""
    ICON_TIME_MODIFIED=""
fi
# Time - Change:
if [ $TIME_CHANGE_FLAG -eq 0 ]; then
    if [ ${ARRAY_DIRECTORY_INFO[16]} = $CURRENT_YEAR ]; then
        TIME_CHANGE="${ARRAY_DIRECTORY_INFO[14]} ${ARRAY_DIRECTORY_INFO[15]} ${ARRAY_DIRECTORY_INFO[17]}"
    else
        TIME_CHANGE="${ARRAY_DIRECTORY_INFO[14]} ${ARRAY_DIRECTORY_INFO[15]} ${ARRAY_DIRECTORY_INFO[16]}"
    fi
else
    TIME_CHANGE=""
    ICON_TIME_CHANGE=""
fi
# Time - Birth:
if [ $TIME_BIRTH_FLAG -eq 0 ]; then
    if [ ${ARRAY_DIRECTORY_INFO[20]} = $CURRENT_YEAR ]; then
        TIME_BIRTH="${ARRAY_DIRECTORY_INFO[18]} ${ARRAY_DIRECTORY_INFO[19]} ${ARRAY_DIRECTORY_INFO[21]}"
    else
        TIME_BIRTH="${ARRAY_DIRECTORY_INFO[18]} ${ARRAY_DIRECTORY_INFO[19]} ${ARRAY_DIRECTORY_INFO[20]}"
    fi
else
    TIME_BIRTH=""
    ICON_TIME_BIRTH=""
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
    $PRINTF "DEBUG - ICON_PERMISSIONS is: $ICON_PERMISSIONS\n"
    $PRINTF "DEBUG - ICON_USER is: $ICON_USER\n"
    $PRINTF "DEBUG - ICON_GROUP is: $ICON_GROUP\n"
    $PRINTF "DEBUG - ICON_DIRECTORY is: $ICON_DIRECTORY\n"
    $PRINTF "DEBUG - ICON_FILE is: $ICON_FILE\n"
    $PRINTF "DEBUG - ICON_TIME_ACCESS is: $ICON_TIME_ACCESS\n"
    $PRINTF "DEBUG - ICON_TIME_MODIFIED is: $ICON_TIME_MODIFIED\n"
    $PRINTF "DEBUG - ICON_TIME_CHANGE is: $ICON_TIME_CHANGE\n"
    $PRINTF "DEBUG - ICON_TIME_BIRTH is: $ICON_TIME_BIRTH\n"
fi

# Standardize the output:
# Permissions:
if [[ $PERMISSIONS_NUMBER_FLAG -eq 0 && $PERMISSIONS_LONG_FLAG -eq 0 ]]; then
    PERMISSIONS_OUTPUT="$ICON_PERMISSIONS$PERMISSIONS_LONG($PERMISSIONS_NUMBER)"
else
    PERMISSIONS_OUTPUT="$ICON_PERMISSIONS$PERMISSIONS_LONG$PERMISSIONS_NUMBER"
fi
# User:
if [[ $USER_NAME_FLAG -eq 0 && $USER_ID_FLAG -eq 0 ]]; then
    USER_OUTPUT="$ICON_USER$USER_NAME($USER_ID)"
else
   USER_OUTPUT="$ICON_USER$USER_NAME$USER_ID" 
fi
# Group: 
if [[ $GROUP_NAME_FLAG -eq 0 && $GROUP_ID_FLAG -eq 00 ]]; then
    GROUP_OUTPUT="$ICON_GROUP$GROUP_NAME($GROUP_ID)"
else
    GROUP_OUTPUT="$ICON_GROUP$GROUP_NAME$GROUP_ID"
fi
# Files and Directories:
if [[ $PERMISSIONS_LONG_FLAG -eq 0 || $PERMISSIONS_NUMBER_FLAG -eq 0 || $USER_NAME_FLAG -eq 0 || $USER_ID_FLAG -eq 0 || $GROUP_NAME_FLAG -eq 0 || $GROUP_ID_FLAG -eq 0 ]]; then
    SPACER=" "
fi
FILE_SIZE_OUTPUT="$SPACER$ICON_DIRECTORY$NUMBER_OF_DIRECTORIES$SPACER$ICON_FILE$NUMBER_OF_FILES, $FILE_SIZES_TOTAL_HUMAN"

# Time: 
TIME_OUTPUT="$ICON_TIME_ACCESS$TIME_ACCESS$ICON_TIME_MODIFIED$TIME_MODIFIED$ICON_TIME_CHANGE$TIME_CHANGE$ICON_TIME_BIRTH$TIME_BIRTH"

# And finally, print the output:
$PRINTF "$PERMISSIONS_OUTPUT$USER_OUTPUT$GROUP_OUTPUT$FILE_SIZE_OUTPUT$SPACER$TIME_OUTPUT\n"

exit 0
# EOF
