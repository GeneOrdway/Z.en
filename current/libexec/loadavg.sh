#!/bin/sh
#
# This script prints a colorized output of your system's load averages.

###       ###
### TO DO ###
###       ###

# 1) - Check for program support before executing for cleaner error checking.
# 2) - Add support for additional colors, based upon terminal output.
# 3) - 

###          ###
### PROGRAMS ###
###          ###
PRINTF="/usr/bin/printf"
AWK="/usr/bin/awk"
SYSCTL="/usr/sbin/sysctl"
UPTIME="/usr/bin/uptime"
TPUT="/usr/bin/tput"

###           ###
### FUNCTIONS ###
###           ###

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
#FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    LOADAVG="$UPTIME"
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    LOADAVG="$UPTIME" 
else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi

# Check support for colors here.
COLORS=`$TPUT colors`
if [ $COLORS -eq 256 ]; then
    # X-Term-Color - Full 256 color support.
    $PRINTF "256 colors.\n"
elif [ $COLORS -eq 88 ]; then
    # URXVT - Only supports 88 colors.
    $PRINTF "88 colors.\n"
elif [ $COLORS -eq 8 ]; then
    # X-Term - Default for most terminals.
    $PRINTF "8 colors.\n"
elif [ $COLORS -eq 0 ]; then
    # Monochrome - What kind of ancient-ass hardware are you running?
    $PRINTF "0 colors.\n"
else
    $PRINTF "Probably an error.\n"
fi

# Get the load averages:
OUTPUT=`$LOADAVG | $AWK 'match($0,/[0-9]\.([0-9]{2})/){
LOADAVG=(substr($0, RSTART,RLENGTH+10));
# Matches the regular expression pattern for #.## and copies the 10 spaces
# from the first pattern match to the last entry. Then stores that to
# variable LOADAVG.

# Split the string into the three necessary pieces
split(LOADAVG, ARRAY_LOADAVG," ");

# Apply colors:

# One Minute Average: 
if (ARRAY_LOADAVG[1] >= 5)
    # Red
    ONE="\033[31m"ARRAY_LOADAVG[1];
else if (ARRAY_LOADAVG[1] >= 1)
    # Yellow
    ONE="\033[33m"ARRAY_LOADAVG[1];
else 
    # Green
    ONE="\033[32m"ARRAY_LOADAVG[1];

# Five Minute Average:
if (ARRAY_LOADAVG[2] >= 5)
    # Red
    FIVE="\033[31m"ARRAY_LOADAVG[2];
else if (ARRAY_LOADAVG[2] >= 1)
    # Yellow
    FIVE="\033[33m"ARRAY_LOADAVG[2];
else 
    # Green
    FIVE="\033[32m"ARRAY_LOADAVG[2];

# Fifteen Minute Average:
if (ARRAY_LOADAVG[3] >= 5)
    # Red 
    FIFTEEN="\033[31m"ARRAY_LOADAVG[3];
else if (ARRAY_LOADAVG[3] >= 1)
    # Yellow
    FIFTEEN="\033[33m"ARRAY_LOADAVG[3];
else 
    # Green
    FIFTEEN="\033[32m"ARRAY_LOADAVG[3];

# One line with all three outputs
print ONE, FIVE, FIFTEEN;
}'`

# Print output.
$PRINTF "$OUTPUT\n"

exit 0
#EOF
