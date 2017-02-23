#!/bin/sh
#
# Path
# 
# Script to check and set additional user-defined paths
#

###       ###
### TO DO ###
###       ###

# 1 - Replace ARRAY_REQUESTED_PATH with info read from a file.
# 2 - Clean up case statement to allow for multiple selections: -vf

# Abort if any command exits with a non-zero value.
set -e

###          ###
### PROGRAMS ###
###          ###
PRINTF="/usr/bin/printf"
BASENAME="/usr/bin/basename"

###           ###
### VARIABLES ###
###           ###

### Users can set these ###
TESTPATH="/bin:/sbin:/usr/bin:/usr/sbin"
CONFIG_FILE_LOCATION="/Users/sysop/Dotfiles"
CONFIG_FILE_NAME="pathcheck.conf"

# Option Flags
FLAG_PRE_APPEND="1"        # False
FLAG_POST_APPEND="1"       # False

# Triggers
PRE_APPEND_TRIGGERED="1"   # False
POST_APPEND_TRIGGERED="1"  # False
OUTPUT_TYPE_TRIGGERED="1"  # False
CONFIG_FILE_TRIGGERED="1"  # False

# Requested Paths listed below. Add yours here.
declare -a ARRAY_REQUESTED_PATH=()
#    /usr/local/bin
#    /usr/local/sbin
#    /opt/local/bin
#    /opt/local/sbin
#    /Developer/Tools
#    /hx/bin
#    /hx/sbin
#    ~/.bin
#    /Projects/Programming/Shell
#    /Projects/Programming/Shell/Mac
#)

### Users should leave these alone ###
declare -i OUTPUT_TYPE="5"  # OUTPUT_TYPE Levels:
                            # 1 - Silent 
                            # 2 - Error (aka quiet) 
                            # 3 - Info (default)
                            # 4 - Verbose 
                            # 5 - Debug

# Make sure our programs exist at specified locations.
if [[ ! -e $PRINTF ]]; then
    # Cannot display error message with no program to print it.
    exit 1
fi

# Basename:
if [[ $OUTPUT_TYPE -eq 5 ]]; then 
    $PRINTF "Locating basename.\n"
fi
if [[ -e $BASENAME ]]; then
    if [[ $OUTPUT_TYPE -eq 5 ]]; then
        $PRINTF "Basename located.\n"
    fi
    SCRIPTNAME=`$BASENAME $0`
else
    if [[ $OUTPUT_TYPE -ge 2 ]]; then
        $PRINTF "Basename not found. Exiting.\n"
    fi
    exit 1
fi

###           ###
### FUNCTIONS ###
###           ###

# Displays the help menu.
fnHELP() {
    $PRINTF "$SCRIPTNAME Help:\r
    \rUsage: $SCRIPTNAME [-dhqsv] [-a directory] [-b directory] [-f file]\r
            \r
\rOr with POSIX-style arguments:\r
\rUsage: $SCRIPTNAME [--debug --help --quiet --silent --verbose]\r
\r                    [--post-append directory] [--pre-append directory]\r 
\r                    [--file configuration]
\r
\rExample: $SCRIPTNAME -v -a /usr/local/bin /usr/local/sbin -b /bin \r
\rOR
\rExample: $SCRIPTNAME --verbose --pre-append /usr/local/sbin --post-append /bin \r
\r
\rGNU-STYLE:    | POSIX-STYLE:            | EXPLANATION:\r
\r______________|_________________________|_______________________________________\r
\r -a directory | --post-append directory | post-append directory to path.\r 
\r -b directory | --pre-append directory  | pre-append directory to path.\r
\r -d           | --debug                 | Debug output - Useful for scripting.\r
\r -f file      | --file                  | Specify configuration file.\r
\r -h           | --help                  | Print this help menu.\r
\r -q           | --quiet                 | Quiet output - Errors messages only.\r
\r -s           | --silent                | Silent output - No messages.\r
\r -v           | --verbose               | Verbose output - See all messages. \n"
}

# Read external configuration file 
fnREAD_CONFIG() {
    local j=0
    # read each line of the configuration file and ignore # comments
    while read line; do 
        # This uses regular expression to ignore anything after #
        # Start by ignoring any lines beginning with #
        if [[ "$line" =~ ^[^#] ]]; then  
            # Next, only pay attention to lines beginning with /
            if [[ "$line" =~ ^[/] ]]; then  
                # Now make sure there are no in-line comments.
                if [[ "$line" =~ .*# ]]; then  
                    # If there are, strip them out.
                    ARRAY_REQUESTED_PATH[$j]=${line%%\#*}
                    if [[ $OUTPUT_TYPE -eq 5 ]]; then 
                        $PRINTF "DEBUG - line is: $line\n"
                    fi
                else 
                    ARRAY_REQUESTED_PATH[$j]=${line}
                    if [[ $OUTPUT_TYPE -eq 5 ]]; then 
                        $PRINTF "DEBUG - line is: $line\n"
                    fi
                fi
            fi
        fi
        ((j++))
           # ARRAY_REQUESTED_PATH[j]=${line} 
    done < $CONFIG_FILE_NAME
}

# Check for directory next.
# Needs a better name.
fnSOMETHING() { 
    # I'll need to set ARRAY_REQUESTED_PATH[$i] properly.
    # $i from ARRAY_ARGUMENTS doesn't correspond.
    if [[ $OUTPUT_TYPE -eq 5 ]]; then 
        $PRINTF "DEBUG - ARRAY_ARGUMENTS is: ${ARRAY_ARGUMENTS[$i]}\n"
    fi
    
    LAST_ELEMENT=${#ARRAY_REQUESTED_PATH}
    ARRAY_REQUESTED_PATH[$LAST_ELEMENT]=${ARRAY_ARGUMENTS[$i]}; 
    
    if [[ $OUTPUT_TYPE -eq 5 ]]; then
        $PRINTF "DEBUG - ARRAY_REQUESTED_PATH is: ${ARRAY_REQUESTED_PATH[$LAST_ELEMENT]}\n";
    fi

    ((LAST_ELEMENT++));
    
    if [[ $OUTPUT_TYPE -eq 5 ]]; then
        $PRINTF "DEBUG - LAST_ELEMENT is: $LAST_ELEMENT\n"
    fi
}

# Check to make sure OUTPUT_TYPE_TRIGGERED hasn't already been triggered. 
fnOUTPUT_TYPE_TRIGGERED_CHECK() {
    if [[ OUTPUT_TYPE_TRIGGERED -eq 0 ]]; then
        if [[ $OUTPUT_TYPE -ge 2 ]]; then
            $PRINTF "Program cannot have multiple levels of noise selected.\n"
        fi
        exit 1
    fi
}

###      ###
### MAIN ###
###      ###

# Check to make sure OUTPUT_TYPE isn't too high.
if [[ $OUTPUT_TYPE -gt 5 ]]; then 
    if [[ $OUTPUT_TYPE -ge 2 ]]; then
        $PRINTF "Variable 'OUTPUT_TYPE' is out of range.\n"
    fi
    exit 1
fi

# Read in arguments supplied by user.
declare -a ARRAY_ARGUMENTS=($*)
for ((i=0; i < ${#ARRAY_ARGUMENTS[*]}; i++)) do
    if [[ $OUTPUT_TYPE -eq 5 ]]; then
        $PRINTF "DEBUG - ARRAY_ARGUMENTS[$i] is: ${ARRAY_ARGUMENTS[$i]}\n"
    fi
    
    # Check ARRAY_ARGUMENTS for a directory.
    if [[ "${ARRAY_ARGUMENTS[$i]}" =~ ^[/] ]]; then
        # Execute directory code here.
        fnSOMETHING;
    fi
        # Check for ~ as home directory list, and make it valid.
    
    # Check for - here, then proceed with case statement.
    if [[ "${ARRAY_ARGUMENTS[$i]}" =~ ^[-]{-abdfhqsv} ]]; then 
        case ${ARRAY_ARGUMENTS[$i]} in
            *a* | --post-append) FLAG_POST_APPEND="0"; POST_APPEND_TRIGGERED="0"
            ;;
            *b* | --pre-append) FLAG_PRE_APPEND="0"; PRE_APPEND_TRIGGERED="0"
            ;;
            *d* | --debug) fnOUTPUT_TYPE_TRIGGERED_CHECK; OUTPUT_TYPE="5"; OUTPUT_TYPE_TRIGGERED="0"
            ;;
            *f* | --file) FLAG_CONFIG_FILE="0"; CONFIG_FILE_TRIGGERED="0" 
            ;;
            *h* | --help) fnHELP; exit 0
            ;;
            *q* | --quiet) fnOUTPUT_TYPE_TRIGGERED_CHECK; OUTPUT_TYPE="2"; OUTPUT_TYPE_TRIGGERED="0"
            ;;
            *s* | --silent) fnOUTPUT_TYPE_TRIGGERED_CHECK; OUTPUT_TYPE="1"; OUTPUT_TYPE_TRIGGERED="0"
            ;;
            *v* | --verbose) fnOUTPUT_TYPE_TRIGGERED_CHECK; OUTPUT_TYPE="4"; OUTPUT_TYPE_TRIGGERED="0"
            ;;
            *) exit 1
            ;;
        esac
    fi
done

# If no parameters are entered, display the help message and exit.
if [[ $1 == "" ]]; then
    fnHELP
    exit 0
fi

# Debug information
if [[ $OUTPUT_TYPE -eq 5 ]]; then
    $PRINTF "DEBUG - Actual PATH is: ${ARRAY_ACTUAL_PATH[*]}\n"
    $PRINTF "DEBUG - Original TESTPATH is: $TESTPATH\n"
    $PRINTF "DEBUG - Array is: ${ARRAY_REQUESTED_PATH[*]}\n"
fi

# Read the path configuration file now.
# Make sure it exists and is a regular file first.



if [[ $OUTPUT_TYPE -eq 5 ]]; then
    $PRINTF "DEBUG - CONFIG_FILE_LOCATION is: $CONFIG_FILE_LOCATION\n"
    $PRINTF "DEBUG - CONFIG_FILE_NAME is: $CONFIG_FILE_NAME\n"
    $PRINTF "DEBUG - CONFIG_FILE_NAME/CONFIG_FILE_NAME are: $CONFIG_FILE_LOCATION/$CONFIG_FILE_NAME\n"
fi

if [[ -e $CONFIG_FILE_LOCATION/$CONFIG_FILE_NAME && -f $CONFIG_FILE_LOCATION/$CONFIG_FILE_NAME ]]; then
    if [[ $OUTPUT_TYPE -eq 5 ]]; then
        $PRINTF "DEBUG - Reading in configuration file now.\n"
    fi
    fnREAD_CONFIG
else
    # Print an error message but continue on using built-in values.
    if [[ $OUTPUT_TYPE -eq 3 ]]; then
        $PRINTF "Configuration file $CONFIG_FILE_NAME not found at location: $CONFIG_FILE_LOCATION\n"
    fi
fi
# Check if requested path exists, make sure it's not already in $PATH
for ((i=0; i < ${#ARRAY_REQUESTED_PATH[*]}; i++)) do
    if [[ $OUTPUT_TYPE -eq 5 ]]; then
        $PRINTF "DEBUG - Inside FOR loop - ${ARRAY_REQUESTED_PATH[$i]}\n"
    fi

    # Check to make sure directory exists first 
    if [[ -d ${ARRAY_REQUESTED_PATH[$i]} ]]; then
        if [[ $OUTPUT_TYPE -ge 4 ]]; then
            $PRINTF "Found directory: ${ARRAY_REQUESTED_PATH[$i]}\n"
        fi

        # See if the requested path is already in the existing path.
        if [[ ":$TESTPATH:" != *":${ARRAY_REQUESTED_PATH[$i]}:"* ]]; then
            # Now see pre-append or post-append the path
            if [[ $FLAG_PRE_APPEND -eq 0 ]]; then 
                # This will pre-append to existing path.
                TESTPATH=${ARRAY_REQUESTED_PATH[$i]}:$TESTPATH
                if [[ $OUTPUT_TYPE -ge 4 ]]; then
                    $PRINTF "Directory ${ARRAY_REQUESTED_PATH[$i]} added to Path.\n"
                fi
            elif [[ $FLAG_POST_APPEND -eq 0 ]]; then
                # This will post-append to existing Path.
                TESTPATH=$TESTPATH:${ARRAY_REQUESTED_PATH[$i]}
                if [[ $OUTPUT_TYPE -ge 4 ]]; then
                    $PRINTF "Directory ${ARRAY_REQUESTED_PATH[$i]} added to Path.\n"
                fi  
            else
                # By default, if no operator is specified, we post-append
                # This will post-append to existing Path.
                TESTPATH=$TESTPATH:${ARRAY_REQUESTED_PATH[$i]}
                if [[ $OUTPUT_TYPE -ge 4 ]]; then
                    $PRINTF "Directory ${ARRAY_REQUESTED_PATH[$i]} added to Path.\n"
                fi  
            fi
        else
            if [[ $OUTPUT_TYPE -ge 4 ]]; then
                $PRINTF "Directory ${ARRAY_REQUESTED_PATH[$i]} already in Path.\n"     
            fi
        fi
    else
        if [[ $OUTPUT_TYPE -ge 3 ]]; then
            $PRINTF "Cannot find directory: ${ARRAY_REQUESTED_PATH[$i]} -- Skipping.\n"
        fi
    fi
done

    # Finally, export the new path.
    #export PATH;
    if [[ $OUTPUT_TYPE -ge 2 ]]; then
        $PRINTF "New TESTPATH is: $TESTPATH\n"
    fi
exit 0
# EOF
