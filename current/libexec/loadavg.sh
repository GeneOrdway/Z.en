#!/bin/sh
#
# This script prints a colorized output of your system's load averages.

###       ###
### TO Do ###
###       ###

# Allow for uptime, not just sysctl
# Fix sysctl output.

###          ###
### PROGRAMS ###
###          ###
BASENAME="/usr/bin/basename"
SYSCLT="/usr/sbin/sysctl"
UPTIME="/usr/bin/uptime"
AWK="/usr/bin/awk"
PRINTF="/usr/bin/printf"

###           ###
### VARIABLES ###
###           ###

###      ###
### MAIN ###
###      ###

LOADAVG=$(sysctl -n vm.loadavg | $AWK '{
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

$PRINTF "$LOADAVG\n"

