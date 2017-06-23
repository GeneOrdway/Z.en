#!/bin/sh
#
# This script prints a colorized output of your system's load averages.

###       ###
### TO DO ###
###       ###

# 1) - Check for program support before executing for cleaner error checking.
# 2) - Get rid of the pipe between OUTPUT and AWK. Change that to pass awk a
#       shell variable for loadavg instead and adjust script accordingly.
# 3) - Verify that all the proper error checking has been completed. 
# 4) - Import color values to ARRAY_FG_COLORS and ARRAY_BG_COLORS through
#       external configuration file.
# 5) - Change escape sequence to support decimal, hex, and octal notation.
# 6) - 

###          ###
### PROGRAMS ###
###          ###
PRINTF="/usr/bin/printf"
AWK="/usr/bin/awk"
TPUT="/usr/bin/tput"
SYSCTL="/usr/sbin/sysctl"
UPTIME="/usr/bin/uptime"

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
    CORES=`$SYSCTL -n hw.physicalcpu`
# FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    LOADAVG="$SYSCTL -a vm.loadavg"
    CORES=`$SYSCTL -a hw.ncpu`
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    LOADAVG="$UPTIME" 
    # There may be a better way to do this.
    CORES=`$AWK '/^processor/ {++n} END {print n+1}' /proc/cpuinfo`
else 
    fn_ERROR_MESSAGE "Could not determine Operating System. Exiting."
    exit 1
fi

# See if tmux is running:
if [[ "$TERM" = "screen*" ]] && [ -n "$TMUX" ]; then
    TMUX_ACTIVE=0
else
    TMUX_ACTIVE=1
fi

# Check support for colors here.
TERM_COLORS=`$TPUT colors`
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

# Check the number of cores:
if [ $CORES -eq 0 ]; then
    fn_ERROR_MESSAGE "Could not determine the number of physical cpu cores available. Script will now set value to 1. User should check script settings."
    CORES=1
fi

# Set main escape sequences
# Hex: \x1b
# Octal: \033
# Decimal: \e
ESCAPE_SEQUENCE="\033"

# Get the load averages:
OUTPUT=`$LOADAVG | $AWK -v AWK_COLORS=$TERM_COLORS -v AWK_CORES=$CORES -v AWK_ESCAPE_SEQUENCE=$ESCAPE_SEQUENCE -v AWK_TMUX_ACTIVE=$TMUX_ACTIVE '
match($0,/[0-9]{1,2}+\.([0-9]{2})/) {
LOADAVG=(substr($0, RSTART,RLENGTH+15));
# Matches the regular expression pattern for #.## and copies the 15 spaces
# from the first pattern match to the last entry. Then stores that to
# variable LOADAVG. Take note, the {2} fields behind the numbers in the
# match field are grabbing the first two numbers before and the first two
# numbers following the decimal point.

# Split the string into the three necessary pieces
split(LOADAVG, ARRAY_LOADAVG," ");

# Determine cores and re-evaluate the load averages:
ONE_LOADAVG = ARRAY_LOADAVG[1] / AWK_CORES;
FIVE_LOADAVG = ARRAY_LOADAVG[2] / AWK_CORES;
FIFTEEN_LOADAVG = ARRAY_LOADAVG[3] / AWK_CORES;

# Set Color and Load Average values into independent arrays:
if (AWK_COLORS == "256") {  
    FG_ESCAPE_SEQUENCE="38;05;"
    BG_ESCAPE_SEQUENCE="48;05;"
    # Set Foreground Color Values: (0-3.45)
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
    # Set Load Average Values: (0-3.45)
    ARRAY_LOADAVG_VALUES[1]="0.00" 
    ARRAY_LOADAVG_VALUES[2]="0.15" 
    ARRAY_LOADAVG_VALUES[3]="0.30" 
    ARRAY_LOADAVG_VALUES[4]="0.45" 
    ARRAY_LOADAVG_VALUES[5]="0.60" 
    ARRAY_LOADAVG_VALUES[6]="0.75" 
    ARRAY_LOADAVG_VALUES[7]="0.90"
    ARRAY_LOADAVG_VALUES[8]="1.05" 
    ARRAY_LOADAVG_VALUES[9]="1.20" 
    ARRAY_LOADAVG_VALUES[10]="1.35" 
    ARRAY_LOADAVG_VALUES[11]="1.50" 
    ARRAY_LOADAVG_VALUES[12]="1.65" 
    ARRAY_LOADAVG_VALUES[13]="1.80" 
    ARRAY_LOADAVG_VALUES[14]="1.95" 
    ARRAY_LOADAVG_VALUES[15]="2.10" 
    ARRAY_LOADAVG_VALUES[16]="2.25" 
    ARRAY_LOADAVG_VALUES[17]="2.40" 
    ARRAY_LOADAVG_VALUES[18]="2.55" 
    ARRAY_LOADAVG_VALUES[19]="2.70" 
    ARRAY_LOADAVG_VALUES[20]="2.85" 
    ARRAY_LOADAVG_VALUES[21]="3.00"
    ARRAY_LOADAVG_VALUES[22]="3.15"
    ARRAY_LOADAVG_VALUES[23]="3.30"
    ARRAY_LOADAVG_VALUES[24]="3.45"
    # (ORIGINAL SCALE) Set Load Average Values: (0-5.75)
    # ARRAY_LOADAVG_VALUES[1]="0.00" 
    # ARRAY_LOADAVG_VALUES[2]="0.25" 
    # ARRAY_LOADAVG_VALUES[3]="0.50" 
    # ARRAY_LOADAVG_VALUES[4]="0.75" 
    # ARRAY_LOADAVG_VALUES[5]="1.00" 
    # ARRAY_LOADAVG_VALUES[6]="1.25" 
    # ARRAY_LOADAVG_VALUES[7]="1.50"
    # ARRAY_LOADAVG_VALUES[8]="1.75" 
    # ARRAY_LOADAVG_VALUES[9]="2.00" 
    # ARRAY_LOADAVG_VALUES[10]="2.25" 
    # ARRAY_LOADAVG_VALUES[11]="2.50" 
    # ARRAY_LOADAVG_VALUES[12]="2.75" 
    # ARRAY_LOADAVG_VALUES[13]="3.00" 
    # ARRAY_LOADAVG_VALUES[14]="3.25" 
    # ARRAY_LOADAVG_VALUES[15]="3.50" 
    # ARRAY_LOADAVG_VALUES[16]="3.75" 
    # ARRAY_LOADAVG_VALUES[17]="4.00" 
    # ARRAY_LOADAVG_VALUES[18]="4.25" 
    # ARRAY_LOADAVG_VALUES[19]="4.50" 
    # ARRAY_LOADAVG_VALUES[20]="4.75" 
    # ARRAY_LOADAVG_VALUES[21]="5.00" 
    # ARRAY_LOADAVG_VALUES[22]="5.25"
    # ARRAY_LOADAVG_VALUES[23]="5.50"
    # ARRAY_LOADAVG_VALUES[24]="5.75"
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
    # Set Load Average Values: (0-3)
    ARRAY_LOADAVG_VALUES[1]="0.00" 
    ARRAY_LOADAVG_VALUES[2]="0.15" 
    ARRAY_LOADAVG_VALUES[3]="0.30" 
    ARRAY_LOADAVG_VALUES[4]="0.45" 
    ARRAY_LOADAVG_VALUES[5]="0.60" 
    ARRAY_LOADAVG_VALUES[6]="0.75" 
    ARRAY_LOADAVG_VALUES[7]="0.90"
    ARRAY_LOADAVG_VALUES[8]="1.05" 
    ARRAY_LOADAVG_VALUES[9]="1.20" 
    ARRAY_LOADAVG_VALUES[10]="1.35" 
    ARRAY_LOADAVG_VALUES[11]="1.50" 
    ARRAY_LOADAVG_VALUES[12]="1.65" 
    ARRAY_LOADAVG_VALUES[13]="1.80" 
    ARRAY_LOADAVG_VALUES[14]="1.95" 
    ARRAY_LOADAVG_VALUES[15]="2.10" 
    ARRAY_LOADAVG_VALUES[16]="2.25" 
    ARRAY_LOADAVG_VALUES[17]="2.40" 
    ARRAY_LOADAVG_VALUES[18]="2.55" 
    ARRAY_LOADAVG_VALUES[19]="2.70" 
    ARRAY_LOADAVG_VALUES[20]="2.85" 
    ARRAY_LOADAVG_VALUES[21]="3.00" 
    # (ORIGINAL SCALE) Set Load Average Values: (0-5)
    # ARRAY_LOADAVG_VALUES[1]="0.00"
    # ARRAY_LOADAVG_VALUES[2]="0.25"
    # ARRAY_LOADAVG_VALUES[3]="0.50"
    # ARRAY_LOADAVG_VALUES[4]="0.75"
    # ARRAY_LOADAVG_VALUES[5]="1.00" 
    # ARRAY_LOADAVG_VALUES[6]="1.25"
    # ARRAY_LOADAVG_VALUES[7]="1.50"
    # ARRAY_LOADAVG_VALUES[8]="1.75"
    # ARRAY_LOADAVG_VALUES[9]="2.00"
    # ARRAY_LOADAVG_VALUES[10]="2.25"
    # ARRAY_LOADAVG_VALUES[11]="2.50"
    # ARRAY_LOADAVG_VALUES[12]="2.75"
    # ARRAY_LOADAVG_VALUES[13]="3.00"
    # ARRAY_LOADAVG_VALUES[14]="3.25"
    # ARRAY_LOADAVG_VALUES[15]="3.50"
    # ARRAY_LOADAVG_VALUES[16]="3.75"
    # ARRAY_LOADAVG_VALUES[17]="4.00"
    # ARRAY_LOADAVG_VALUES[18]="4.25"
    # ARRAY_LOADAVG_VALUES[19]="4.50"
    # ARRAY_LOADAVG_VALUES[20]="4.75"
    # ARRAY_LOADAVG_VALUES[21]="5.00" 
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
    ARRAY_LOADAVG_VALUES[1]="0.00"
    ARRAY_LOADAVG_VALUES[2]="1.00"
    ARRAY_LOADAVG_VALUES[3]="2.00" 
    ARRAY_LOADAVG_VALUES[4]="3.00" 
    # The value "4.00" is purposely missing.
    ARRAY_LOADAVG_VALUES[5]="5.00" 
}
else {
    print "ERROR: Terminal colors not passed to AWK. Exiting."
    exit 1
}

# Apply colors:
# One Minute:
for (i = 1; i <= length(ARRAY_LOADAVG_VALUES); i++) {
    if (ONE_LOADAVG >= ARRAY_LOADAVG_VALUES[i] && AWK_TMUX_ACTIVE = 0) { 
        ONE=AWK_ESCAPE_SEQUENCE"["FG_ESCAPE_SEQUENCE""ARRAY_FG_COLORS[i]"m"AWK_ESCAPE_SEQUENCE"["BG_ESCAPE_SEQUENCE""ARRAY_BG_COLORS[i]"m"ARRAY_LOADAVG[1]""AWK_ESCAPE_SEQUENCE"[0m";
    }
    else if (ONE_LOADAVG >= ARRAY_LOADAVG_VALUES[i] && AWK_TMUX_ACTIVE = 1) {
        ONE=AWK_ESCAPE_SEQUENCE"["FG_ESCAPE_SEQUENCE""ARRAY_FG_COLORS[i]"m"AWK_ESCAPE_SEQUENCE"["BG_ESCAPE_SEQUENCE""ARRAY_BG_COLORS[i]"m"ARRAY_LOADAVG[1]""AWK_ESCAPE_SEQUENCE"[0m";
    }
}
# Five Minute:
for (i = 1; i <= length(ARRAY_LOADAVG_VALUES); i++) { 
    if (FIVE_LOADAVG >= ARRAY_LOADAVG_VALUES[i] && AWK_TMUX_ACTIVE = 0) { 
        FIVE=AWK_ESCAPE_SEQUENCE"["FG_ESCAPE_SEQUENCE""ARRAY_FG_COLORS[i]"m"AWK_ESCAPE_SEQUENCE"["BG_ESCAPE_SEQUENCE""ARRAY_BG_COLORS[i]"m"ARRAY_LOADAVG[2]""AWK_ESCAPE_SEQUENCE"[0m";
    }
    else if (FIVE_LOADAVG >= ARRAY_LOADAVG_VALUES[i] && AWK_TMUX_ACTIVE = 1) {
        FIVE=AWK_ESCAPE_SEQUENCE"["FG_ESCAPE_SEQUENCE""ARRAY_FG_COLORS[i]"m"AWK_ESCAPE_SEQUENCE"["BG_ESCAPE_SEQUENCE""ARRAY_BG_COLORS[i]"m"ARRAY_LOADAVG[2]""AWK_ESCAPE_SEQUENCE"[0m";
    }
}
# Fifteen Minute:
for (i = 1; i <= length(ARRAY_LOADAVG_VALUES); i++) { 
    if (FIFTEEN_LOADAVG >= ARRAY_LOADAVG_VALUES[i] && AWK_TMUX_ACTIVE = 0) {
        FIFTEEN=AWK_ESCAPE_SEQUENCE"["FG_ESCAPE_SEQUENCE""ARRAY_FG_COLORS[i]"m"AWK_ESCAPE_SEQUENCE"["BG_ESCAPE_SEQUENCE""ARRAY_BG_COLORS[i]"m"ARRAY_LOADAVG[3]""AWK_ESCAPE_SEQUENCE"[0m";
    }
    else if (FIFTEEN_LOADAVG >= ARRAY_LOADAVG_VALUES[i] && AWK_TMUX_ACTIVE = 1) {
        FIFTEEN=AWK_ESCAPE_SEQUENCE"["FG_ESCAPE_SEQUENCE""ARRAY_FG_COLORS[i]"m"AWK_ESCAPE_SEQUENCE"["BG_ESCAPE_SEQUENCE""ARRAY_BG_COLORS[i]"m"ARRAY_LOADAVG[3]""AWK_ESCAPE_SEQUENCE"[0m";
    }
}

} END {
# One line with all three outputs
print ONE, FIVE, FIFTEEN;
}'`

# Print output.
$PRINTF "$OUTPUT\n"

exit 0
#EOF
