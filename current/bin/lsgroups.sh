#!/bin/sh
#
# Script to list all users on a machine.

###       ###
### TO DO ###
###       ###

# 1 - 

###          ###
### PROGRAMS ###
###          ###
AWK="/usr/bin/awk"

###      ###
### MAIN ###
###      ###

$AWK -F: '{printf "%s:%s\n",$1,$3}' /etc/group

exit 0
# EOF
