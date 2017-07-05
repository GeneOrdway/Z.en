#!/bin/sh 
#
# Script to check for gmail notifications

###       ###
### TO DO ###
###       ###

# 1 - If we do intend to keep this script, we cannot check more frequently
#       than once every 10 minutes.
# 2 - 

###          ###
### PROGRAMS ###
###          ###
CURL="/usr/bin/curl"
XMLLINT="/usr/bin/xmllint"
PRINTF="/usr/bin/printf"

###           ###
### VARIABLES ###
###           ###

CONFIGURATION_FILE="$HOME/.etc/gmailnotifications.conf"

# Initialize:
USERNAME=""
PASSWORD=""

###                ###
### ERROR CHECKING ###
###                ###

# Make sure our programs exist at specified locations.
if [ ! -e $PRINTF ]; then
    # Cannot display error message with no program to print it.
    exit 1
fi

# Does CURL exist?
if [ ! -e $CURL ]; then
    $PRINTF "Cannot find curl at location: $CURL. Exiting.\n"
    exit 1
fi

# Does XMLLINT exist?
if [ ! -e $XMLLINT ]; then 
    $PRINTF "Cannot find xmllint at location: $XMLLINT. Exiting.\n"
    exit 1
fi

# Read in source:
if [[ ! -e "$CONFIGURATION_FILE" ]]; then
    $PRINTF "Configuration file not found at location: $CONFIGURATION_FILE\n"
    exit 1
else
    # Probably better not to source this, but instead, read these values in.
    source $CONFIGURATION_FILE 
fi

# Blank username or password? Get outta' here!
#if [[ ! -e "$USERNAME" || ! -e "$PASSWORD" ]]; then
#    $PRINTF "USERNAME and PASSWORD fields cannot be left blank. Exiting.\n"
#    exit 1
#fi

# Can we support emojis?

###      ###
### MAIN ###
###      ###
EMAIL_CHECK=`$CURL -u $USERNAME:$PASSWORD --silent "https://mail.google.com/mail/feed/atom" | $XMLLINT --xpath "string(//*[name() = 'feed']/*[name() = 'fullcount'])" - `

if [ "$EMAIL_CHECK" -ge 1 ]; then 
    $PRINTF "📬  $EMAIL_CHECK\n"
else
    $PRINTF "📭 \n"
fi

exit 0
#EOF
