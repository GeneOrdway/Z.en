#~/bin/sh
#
# Shell script to display all user accounts on a system

###       ###
### TO DO ###
###       ###

# 1) - 

###          ###
### PROGRAMS ###
###          ###
PRINTF="/usr/bin/printf"
AWK="/usr/bin/awk"

###           ###
### VARIABLES ###
###           ###

###           ###
### FUNCTIONS ###
###           ###

# Show the Help menu:
fn_SHOW_HELP() {
    $PRINTF "$SCRIPTNAME Help:\r
    \rUsage: $SCRIPTNAME [-dhqsv]\r
            \r
\rOr with POSIX-style arguments:\r
\rUsage: $SCRIPTNAME [--debug --help --quiet --silent --verbose] directory\r
\r
\rExample: $SCRIPTNAME -v /usr/local/bin \r
\rOR
\rExample: $SCRIPTNAME --verbose /usr/local/sbin \r
\r
\rGNU-STYLE:    | POSIX-STYLE:            | EXPLANATION:\r
\r______________|_________________________|_______________________________________\r
\r -d           | --debug                 | Debug output - Useful for scripting.\r
\r -h           | --help                  | Print this help menu.\r
\r -q           | --quiet                 | Quiet output - Errors messages only.\r
\r -s           | --silent                | Silent output - No messages.\r
\r -v           | --verbose               | Verbose output - See all messages. \n"
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
    echo "1"

#FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    echo "2"

# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "3"

else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi


exit 0
# EOF
