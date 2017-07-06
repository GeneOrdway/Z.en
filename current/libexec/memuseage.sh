#!/bin/sh
#
# This script prints a colorized output of your system's memory usage.

###       ###
### TO DO ###
###       ###

# 1) - Check for program support before executing for cleaner error checking.
# 2) - Verify that all the proper error checking has been completed. 
# 3) - Import color values to ARRAY_FG_COLORS and ARRAY_BG_COLORS through
#       external configuration file.
# 4) - 

###          ###
### PROGRAMS ###
###          ###
PRINTF="/usr/bin/printf"
AWK="/usr/bin/awk"
TPUT="/usr/bin/tput"
PS="/bin/ps"

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

###           ###
### VARIABLES ###
###           ###

# Initialize:
PS_ARGUMENTS=""
TMUX_ACTIVE=1
TERM_COLORS=""
OUTPUT=""

# Set main escape sequences
# Hex: \x1b
# Octal: \033
# Decimal: \e
ESCAPE_SEQUENCE="\033"

###      ###
### MAIN ###
###      ###

# Determine the Operating System:
# OS X
if [[ "$OSTYPE" == "darwin"* ]]; then     
    PS_ARGUMENTS="-A -o %mem"
# FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    PS_ARGUMENTS="-a -o %mem"
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    PS_ARGUMENTS="ps -A -o %mem" 
else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi

# See if tmux is running:
if [[ "$TERM" == "screen"* ]] && [ -n "$TMUX" ]; then
    TMUX_ACTIVE=0
else
    TMUX_ACTIVE=1
fi

# Check support for colors here.
TERM_COLORS=$($TPUT colors)
# Leave this in for error checking?
if [ $TERM_COLORS -eq 0 ]; then
    # Monochrome - What kind of ancient-ass hardware are you running?
    fn_ERROR_MESSAGE "There is no point in continuing, this script is designed to display color output, but your terminal does not support colors."
    exit 1
# Find an alternative to this.
#else
#    fn_ERROR_MESSAGE "Could not determine if your terminal supports colors. Exiting"
#    exit 1
fi

# Get the load averages:
OUTPUT=$($PS $PS_ARGUMENTS | $AWK -v AWK_COLORS=$TERM_COLORS -v AWK_ESCAPE_SEQUENCE=$ESCAPE_SEQUENCE -v AWK_TMUX_ACTIVE=$TMUX_ACTIVE '
BEGIN {
###           ###
### VARIABLES ###
###           ###

# Initialize AWK Variables:
MEM_UTILIZATION=0;
TOTAL_MEM_UTILIZATION=0;
FG_ESCAPE_SEQUENCE=""
BG_ESCAPE_SEQUENCE=""
STYLIZED_MEM_UTILIZATION=""
}

###      ###
### MAIN ###
###      ###
{
# Ignore the first row and any rows that are not above zero:
if (NR!=1 && $1>0) {
    # Add all process memory utilization together.
    MEM_UTILIZATION+=$1;
}
# Limit output to two decimal places.
TOTAL_MEM_UTILIZATION = sprintf("%.2f", MEM_UTILIZATION);

# Set Color and Load Average values into independent arrays:
if (AWK_COLORS == "256") {  
    FG_ESCAPE_SEQUENCE="38;05;"
    BG_ESCAPE_SEQUENCE="48;05;"
    # Set Foreground Color Values:
    ARRAY_FG_COLORS[1]="21"
    ARRAY_FG_COLORS[2]="27"
    ARRAY_FG_COLORS[3]="33"
    ARRAY_FG_COLORS[4]="39"
    ARRAY_FG_COLORS[5]="45"
    ARRAY_FG_COLORS[6]="51"
    ARRAY_FG_COLORS[7]="50"
    ARRAY_FG_COLORS[8]="49"
    ARRAY_FG_COLORS[9]="48"
    ARRAY_FG_COLORS[10]="47"
    ARRAY_FG_COLORS[11]="46"
    ARRAY_FG_COLORS[12]="82" 
    ARRAY_FG_COLORS[13]="118" 
    ARRAY_FG_COLORS[14]="154" 
    ARRAY_FG_COLORS[15]="190" 
    ARRAY_FG_COLORS[16]="226" 
    ARRAY_FG_COLORS[17]="220" 
    ARRAY_FG_COLORS[18]="214" 
    ARRAY_FG_COLORS[19]="208" 
    ARRAY_FG_COLORS[20]="202" 
    ARRAY_FG_COLORS[21]="196"
    ARRAY_FG_COLORS[22]="124"
    ARRAY_FG_COLORS[23]="88"
    ARRAY_FG_COLORS[24]="52"
    # Set Background Color Values:
    ARRAY_BG_COLORS[1]="16"
    ARRAY_BG_COLORS[2]="16"
    ARRAY_BG_COLORS[3]="16"
    ARRAY_BG_COLORS[4]="16"
    ARRAY_BG_COLORS[5]="16"
    ARRAY_BG_COLORS[6]="16"
    ARRAY_BG_COLORS[7]="16"
    ARRAY_BG_COLORS[8]="16"
    ARRAY_BG_COLORS[9]="16"
    ARRAY_BG_COLORS[10]="16"
    ARRAY_BG_COLORS[11]="16"
    ARRAY_BG_COLORS[12]="16"
    ARRAY_BG_COLORS[13]="16"
    ARRAY_BG_COLORS[14]="16"
    ARRAY_BG_COLORS[15]="16"
    ARRAY_BG_COLORS[16]="16"
    ARRAY_BG_COLORS[17]="16"
    ARRAY_BG_COLORS[18]="16"
    ARRAY_BG_COLORS[19]="16"
    ARRAY_BG_COLORS[20]="16"
    ARRAY_BG_COLORS[21]="16"
    ARRAY_BG_COLORS[22]="16"
    ARRAY_BG_COLORS[23]="16"
    ARRAY_BG_COLORS[24]="16"
    # Set MEM Utilization Scale: (4%)
    ARRAY_SCALE[1]="4" 
    ARRAY_SCALE[2]="8" 
    ARRAY_SCALE[3]="12" 
    ARRAY_SCALE[4]="16" 
    ARRAY_SCALE[5]="20" 
    ARRAY_SCALE[6]="24" 
    ARRAY_SCALE[7]="28"
    ARRAY_SCALE[8]="32" 
    ARRAY_SCALE[9]="36" 
    ARRAY_SCALE[10]="40" 
    ARRAY_SCALE[11]="44" 
    ARRAY_SCALE[12]="48" 
    ARRAY_SCALE[13]="52" 
    ARRAY_SCALE[14]="56" 
    ARRAY_SCALE[15]="60" 
    ARRAY_SCALE[16]="64" 
    ARRAY_SCALE[17]="68" 
    ARRAY_SCALE[18]="72" 
    ARRAY_SCALE[19]="76" 
    ARRAY_SCALE[20]="80" 
    ARRAY_SCALE[21]="84"
    ARRAY_SCALE[22]="88"
    ARRAY_SCALE[23]="92"
    ARRAY_SCALE[24]="96"
}
else if (AWK_COLORS == 88) {
    FG_ESCAPE_SEQUENCE="38;05;"
    BG_ESCAPE_SEQUENCE="48;05;"
    # Set Foreground Color Values:
    ARRAY_FG_COLORS[1]="21"
    ARRAY_FG_COLORS[2]="27"
    ARRAY_FG_COLORS[3]="33"
    ARRAY_FG_COLORS[4]="39"
    ARRAY_FG_COLORS[5]="45"
    ARRAY_FG_COLORS[6]="51"
    ARRAY_FG_COLORS[7]="50"
    ARRAY_FG_COLORS[8]="49"
    ARRAY_FG_COLORS[9]="48"
    ARRAY_FG_COLORS[10]="47"
    ARRAY_FG_COLORS[11]="46"
    ARRAY_FG_COLORS[12]="82"
    ARRAY_FG_COLORS[13]="118" 
    ARRAY_FG_COLORS[14]="154"
    ARRAY_FG_COLORS[15]="190"
    ARRAY_FG_COLORS[16]="226"
    ARRAY_FG_COLORS[17]="220"
    ARRAY_FG_COLORS[18]="214"
    ARRAY_FG_COLORS[19]="208"
    ARRAY_FG_COLORS[20]="202"
    ARRAY_FG_COLORS[21]="196"
    # Set Background Color Values:
    ARRAY_BG_COLORS[1]="16"
    ARRAY_BG_COLORS[2]="16"
    ARRAY_BG_COLORS[3]="16"
    ARRAY_BG_COLORS[4]="16"
    ARRAY_BG_COLORS[5]="16"
    ARRAY_BG_COLORS[6]="16"
    ARRAY_BG_COLORS[7]="16"
    ARRAY_BG_COLORS[8]="16"
    ARRAY_BG_COLORS[9]="16"
    ARRAY_BG_COLORS[10]="16"
    ARRAY_BG_COLORS[11]="16"
    ARRAY_BG_COLORS[12]="16"
    ARRAY_BG_COLORS[13]="16"
    ARRAY_BG_COLORS[14]="16"
    ARRAY_BG_COLORS[15]="16"
    ARRAY_BG_COLORS[16]="16"
    ARRAY_BG_COLORS[17]="16"
    ARRAY_BG_COLORS[18]="16"
    ARRAY_BG_COLORS[19]="16"
    ARRAY_BG_COLORS[20]="16"
    ARRAY_BG_COLORS[21]="16"
    # Set MEM Utilization Scale: (4%)
    ARRAY_SCALE[1]="4" 
    ARRAY_SCALE[2]="8" 
    ARRAY_SCALE[3]="12" 
    ARRAY_SCALE[4]="16" 
    ARRAY_SCALE[5]="20" 
    ARRAY_SCALE[6]="24" 
    ARRAY_SCALE[7]="28"
    ARRAY_SCALE[8]="32" 
    ARRAY_SCALE[9]="36" 
    ARRAY_SCALE[10]="40" 
    ARRAY_SCALE[11]="44" 
    ARRAY_SCALE[12]="48" 
    ARRAY_SCALE[13]="52" 
    ARRAY_SCALE[14]="56" 
    ARRAY_SCALE[15]="60" 
    ARRAY_SCALE[16]="64" 
    ARRAY_SCALE[17]="68" 
    ARRAY_SCALE[18]="72" 
    ARRAY_SCALE[19]="76" 
    ARRAY_SCALE[20]="80" 
    ARRAY_SCALE[21]="84"
    ARRAY_SCALE[22]="88"
    ARRAY_SCALE[23]="92"
    ARRAY_SCALE[24]="96"
}
else if (AWK_COLORS == "8") {
    FG_ESCAPE_SEQUENCE=""
    BG_ESCAPE_SEQUENCE=""
    # Set Foreground Color Values:
    ARRAY_FG_COLORS[1]="34"  
    ARRAY_FG_COLORS[2]="36" 
    ARRAY_FG_COLORS[3]="32"
    ARRAY_FG_COLORS[4]="33"
    ARRAY_FG_COLORS[5]="31" 
    # Set Background Color Values:
    ARRAY_BG_COLORS[1]="40"
    ARRAY_BG_COLORS[2]="40"
    ARRAY_BG_COLORS[3]="40"
    ARRAY_BG_COLORS[4]="40"
    ARRAY_BG_COLORS[5]="40"    
    # Set Load Average Values:
    ARRAY_SCALE[1]="15"
    ARRAY_SCALE[2]="30"
    ARRAY_SCALE[3]="45" 
    ARRAY_SCALE[4]="60" 
    ARRAY_SCALE[5]="90" 
}
else {
    print "ERROR: Terminal colors not passed to AWK. Exiting."
    exit 1
}

# Apply colors:
for (i = 1; i <= length(ARRAY_SCALE); i++) { 
    if (TOTAL_MEM_UTILIZATION >= ARRAY_SCALE[i] && AWK_TMUX_ACTIVE == 0) {
        STYLIZED_MEM_UTILIZATION="#[fg=colour"ARRAY_FG_COLORS[i]"]#[bg=colour"ARRAY_BG_COLORS[i]"]"TOTAL_MEM_UTILIZATION"#[default]";
    }
    else if (TOTAL_MEM_UTILIZATION >= ARRAY_SCALE[i] && AWK_TMUX_ACTIVE = 1) {
        STYLIZED_MEM_UTILIZATION=AWK_ESCAPE_SEQUENCE"["FG_ESCAPE_SEQUENCE""ARRAY_FG_COLORS[i]"m"AWK_ESCAPE_SEQUENCE"["BG_ESCAPE_SEQUENCE""ARRAY_BG_COLORS[i]"m"TOTAL_MEM_UTILIZATION""AWK_ESCAPE_SEQUENCE"[0m";
    }
}

} END {
print STYLIZED_MEM_UTILIZATION;
}')

# Print output.
$PRINTF "$OUTPUT\n"

exit 0
#EOF
