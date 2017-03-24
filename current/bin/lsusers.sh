#!/bin/sh
#
# Script to list all users on a machine.

###       ###
### TO DO ###
###       ###

# 1 - 

# Abort if any command exits with a non-zero value.
set -e

###          ###
### PROGRAMS ###
###          ###
BASENAME="/usr/bin/basename"
PRINTF="/usr/bin/printf"
AWK="/usr/bin/awk"
DSCL="/usr/bin/dscl"

###           ###
### VARIABLES ###
###           ###
declare -i NOISE_LEVEL=3  # NOISE_LEVEL Levels:
                          # 1 - Silent 
                          # 2 - Error (aka quiet) 
                          # 3 - Info (default)
                          # 4 - Verbose 
                          # 5 - DebugFILE_SIZES_TOTAL_BYTES=0

HOST="."

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

###      ###
### MAIN ###
###      ###

# Error Checking:
# Make sure our programs exist at specified locations.
if [ ! -e $PRINTF ]; then
    # Cannot display error message with no program to print it.
    exit 1
fi

# Check to make sure NOISE_LEVEL isn't too high.
if [ $NOISE_LEVEL -gt 5 ]; then 
    if [ $NOISE_LEVEL -ge 2 ]; then
        fn_ERROR_MESSAGE "Variable 'NOISE_LEVEL' is out of range."
    fi
    exit 1
fi

# Determine the Operating System:
# OS X
if [[ "$OSTYPE" == "darwin"* ]]; then     
    $AWK -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd
    $DSCL $HOST -list /Users
    #$DSCL $HOST -readall /Users Password UniquieID PrimaryGroupID RealName NFSHomeDirectory UserShell
    #$DSCL $HOST -readall /Users Password UniquieID PrimaryGroupID RealName NFSHomeDirectory UserShell | $AWK '/RealName/ {REAL_NAME = $2} {print REAL_NAME}'

    #FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    $AWK -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    $AWK -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd
else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi

exit 0
# EOF
