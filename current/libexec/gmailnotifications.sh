#!/bin/sh 
#
# Script to check for gmail notifications

###       ###
### TO DO ###
###       ###

# 1 - So after thinking about this script, this is a quick and dirty hack
#       to check for new emails on Google's gmail platform, but there
#       are better ways of achieving the same results; namely, by
#       connecting to email servers via IMAP instances and allowing
#       a new connection to poll for emails. This will also allow for
#       connections to a multitude of email platforms, not just gmail.
# 2 - If we do intend to keep this script, we cannot check more frequently
#       than once every 10 minutes.
# 3 - Finish adding error checking to this script.
# 4 - 

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

# Does PRINTF exist?

# Does CURL exist?

# Does XMLLINT exist?

# Read in source:
if [[ ! -e "$CONFIGURATION_FILE" ]]; then
    exit 1
else
    source $CONFIGURATION_FILE 
fi

# Blank username or password? Get outta' here!
if [[ ! -e "$USERNAME" || ! -e "$PASSWORD" ]]; then
    exit 1
fi

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
