#!/bin/sh
#
# Path
# 
# Script sets additional user-defined paths
#

###       ###
### TO DO ###
###       ###



###          ###
### PROGRAMS ###
###          ###
PRINTF="/usr/bin/printf"
BASENAME="/usr/bin/basename"
GREP="/usr/bin/grep"

###           ###
### VARIABLES ###
###           ###

### Users can set these ###
TESTPATH="/bin:/sbin:/usr/bin:/usr/sbin"

# Requested Paths listed below. Add yours here.
declare -a ARRAY_REQUESTED_PATH=(
    /usr/local/bin
    /usr/local/sbin
    /opt/local/bin
    /opt/local/sbin
    /Developer/Tools
    /hx/bin
    /hx/sbin
    ./bin
    /Projects/Programming/Shell
    /Projects/Programming/Shell/Mac
)

### Users should leave these alone ###
int OUTPUT_TYPE="3" # OUTPUT_TYPE Levels:
                    # 1 - Silent 
                    # 2 - Error 
                    # 3 - Info 
                    # 4 - Verbose 
                    # 5 - Debug

# Make sure our programs exist at specified locations.
if [[ ! -e $PRINTF ]]; then
    if [[ $OUTPUT_TYPE -ge 2 ]]; then
        $PRINTF "Printf not found. Exiting.\n"
    fi
    exit 1
fi

if [[ -e $BASENAME ]]; then
    SCRIPTNAME=`$BASENAME $0`
else
    if [[ $OUTPUT_TYPE -ge 2 ]]; then
        $PRINTF "Basename not found. Exiting.\n"
    fi
    exit 1
fi

if [[ ! -e $GREP ]]; then
    if [[ $OUTPUT_TYPE -ge 2 ]]; then
        $PRINTF "Grep not found. Exiting.\n"
    fi
    exit 1
fi

###           ###
### FUNCTIONS ###
###           ###

# Displays the help menu.
fnHELP() {
    $PRINTF "$SCRIPTNAME Help:\r
            \rUsage: $SCRIPTNAME shortname [-DhkmQSvV] [-c comment] [-d home-dir]
            \r[-g initial_group] [-G group[,...]] [-i password_hint] [-l longname]
            \r[-m [-K skeleton_dir]] [-p passwd] [-P picture_location] [-s shell] [-u uid]\n"
#\r
#-c -- Comment field.\r
#-D -- Default Mode.\r
#-g -- Initial group IP number\r
#-G -- Supplementary groups in a comma-separated list with no whitespace.\r
#-h -- Displays this help screen.\r
#-H -- Create a hidden user account.\r
#-i -- Password Hint.\r
#-k -- Copy default files to user's home directory. Must be used with -m\r
#-l -- Long name.\r
#-m -- Make user's home directory if it does not exist.\r
#-p -- Password.\r
#-P -- Picture.\r
#-Q -- Quiet output.\r
#-s -- Login shell.\r
#-u -- Numerical user ID.\r
#-v -- Change a hidden user into a visible one.\r
#-V -- Verbose output.\n"
    
#-e -- Account expiration date.                      # Not used by OS X
#-f -- Permanently disable account this many days.   # Not used by OS X
}

###      ###
### MAIN ###
###      ###

# Check to make sure OUTPUT_TYPE isn't too high.
if [[ $OUTPUT_TYPE -gt 5 ]]; then 
    if [[ $OUTPUT_TYPE -ge 2 ]]; then
        $PRINTF "Variable 'OUTPUT_TYPE' set too high.\n"
    fi
    exit 1
fi

# Debug information
if [[ $OUTPUT_TYPE -eq 5 ]]; then
    $PRINTF "DEBUG - Grep is: $GREP\n\n"
    $PRINTF "DEBUG - Original TESTPATH is: $TESTPATH\n\n"
    $PRINTF "DEBUG - Array is: ${ARRAY_REQUESTED_PATH[*]}\n\n"
fi

# Check if requeseted path exists, make sure it's not already in $PATH
for ((i=0; i < ${#ARRAY_REQUESTED_PATH[*]}; i++)) do
    if [[ $OUTPUT_TYPE -eq 5 ]]; then
        $PRINTF "DEBUG - Inside FOR loop - ${ARRAY_REQUESTED_PATH[$i]}\n"
    fi

    if [[ -d ${ARRAY_REQUESTED_PATH[$i]} ]]; then
        if [[ $OUTPUT_TYPE -ge 4 ]]; then
            $PRINTF "Found directory: ${ARRAY_REQUESTED_PATH[$i]}\n"
        fi

        echo $TESTPATH | $GREP -q -s "${ARRAY_REQESTED_PATH[$i]}"
            
        if [[ $OUTPUT_TYPE -eq 5 ]]; then
            $PRINTF "DEBUG - DollarSign? is: $?\n"
        fi

        if [[ $? -eq 0 ]]; then
            # This will post-append to existing Path.
            TESTPATH=$TESTPATH:${ARRAY_REQUESTED_PATH[$i]}
            if [[ $OUTPUT_TYPE -ge 4 ]]; then
                $PRINTF "Directory ${ARRAY_REQUESTED_PATH[$i]} added to Path.\n"
            fi            

            # This will pre-append to existing path.
#            TESTPATH=${ARRAY_REQUESTED_PATH[$i]}:$TESTPATH
#            if [[ $OUTPUT_TYPE -ge 4 ]]; then
#               $PRINTF "Directory ${ARRAY_REQUESTED_PATH[$i]} added to Path.\n"
#            fi
        else
            if [[ $OUTPUT_TYPE -ge 4 ]]; then
                $PRINTF "Directory ${ARRAY_REQUESTED_PATH[$i]} already in Path.\n"     
            fi
        fi
    else
        if [[ $OUTPUT_TYPE -ge 4 ]]; then
            $PRINTF "Cannot find directory ${ARRAY_REQUESTED_PATH[$i]} -- Skipping.\n"
        fi
    fi
done

#export PATH;
if [[ $OUTPUT_TYPE -ge 3 ]]; then
    $PRINTF "New TESTPATH is: $TESTPATH\n"
fi

# EOF
exit 0
