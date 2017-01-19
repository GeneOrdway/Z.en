#!/bin/sh
#
# This script prints a colorized output of your system's load averages.

###       ###
### TO DO ###
###       ###

# 1) - Allow for uptime, not just sysctl
# 2) - Fix sysctl output.
# 3) - Add support for additional colors, based upon
# 4) - Finish support for other platforms.
# 5) - 

###          ###
### PROGRAMS ###
###          ###
PRINTF="/usr/bin/printf"
AWK="/usr/bin/awk"
SYSCTL="/usr/sbin/sysctl"
UPTIME="/usr/bin/uptime"

###           ###
### VARIABLES ###
###           ###


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

# Determine the Operating System:
# OS X
if [[ "$OSTYPE" == "darwin"* ]]; then     
    LOADAVG="$SYSCTL -n vm.loadavg"
    SHELLAWKARGS="{gsub(/[^0-9. ]/,"")}"
#FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    LOADAVG=""
    SHELLAWKARGS=""
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    LOADAVG=" uptime | awk '{gsub(/[0-9]+(\.[0-9]{1,2})/,"")} {print}'" 
    SHELLAWKARGS=""
else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi

# Check support for colors here.
###

# Get the load averages:
OUTPUT=$($LOADAVG | $AWK -v AWKARGS=$SHELLAWKARGS '{
# One Minute Average: 
if ($2 >= 5)
    # Red
    ONE="\033[31m"$2;
else if ($2 >= 1)
    # Yellow
    ONE="\033[33m"$2;
else 
    # Green
    ONE="\033[32m"$2;

# Five Minute Average:
if ($3 >= 5)
    # Red
    FIVE="\033[31m"$3;
else if ($3 >= 1)
    # Yellow
    FIVE="\033[33m"$3;
else 
    # Green
    FIVE="\033[32m"$3;

# Fifteen Minute Average:
if ($4 >= 5)
    # Red 
    FIFTEEN="\033[31m"$4;
else if ($4 >= 1)
    # Yellow
    FIFTEEN="\033[33m"$4;
else 
    # Green
    FIFTEEN="\033[32m"$4;

# One line with all three outputs
print ONE, FIVE, FIFTEEN;
}')

# Print output.
$PRINTF "$OUTPUT\n"

exit 0
#EOF
