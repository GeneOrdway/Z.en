#!/bin/sh
#
# This script prints a colorized output of your system's load averages.

###       ###
### TO DO ###
###       ###

# 1) - Check for program support before executing for cleaner error checking.
# 2) - Add support for additional colors, based upon terminal output.
# 3) - Add number of physical cores available to get a better display of the
#       numbers.
# 4) - Get rid of the pipe between OUTPUT and AWK. Change that to pass awk a
#       shell variable for loadavg instead and adjust script accordingly.
# 5) - 

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

# Check support for colors here.
COLORS=`$TPUT colors`
#$PRINTF "Colors is: $COLORS\n"
# Leave this in for error checking?
#if [ $COLORS -eq 256 ]; then
    # X-Term-Color - Full 256 color support.
#    $PRINTF "256 colors.\n"
#elif [ $COLORS -eq 88 ]; then
    # URXVT - Only supports 88 colors.
#    $PRINTF "88 colors.\n"
#elif [ $COLORS -eq 8 ]; then
    # X-Term - Default for most terminals.
#    $PRINTF "8 colors.\n"
if [ $COLORS -eq 0 ]; then
    # Monochrome - What kind of ancient-ass hardware are you running?
    fn_ERROR_MESSAGE "There is no point in continuing, this script is designed to display color output, but your terminal does not support colors."
    exit 1
#else
#    fn_ERROR_MESSAGE "Could not determine if your terminal supports colors. Exiting"
#    exit 1
fi

# Check the number of cores:
if [ $CORES -eq 0 ]; then
    fn_ERROR_MESSAGE "Could not determine the number of physical cpu cores available. Script will now set value to 1. User should check script settings."
    CORES=1
fi

# Get the load averages:
OUTPUT=`$LOADAVG | $AWK -v AWK_COLORS=$COLORS -v AWK_CORES=$CORES 'match($0,/[0-9]\.([0-9]{2})/){
LOADAVG=(substr($0, RSTART,RLENGTH+10));
# Matches the regular expression pattern for #.## and copies the 10 spaces
# from the first pattern match to the last entry. Then stores that to
# variable LOADAVG.

# Split the string into the three necessary pieces
split(LOADAVG, ARRAY_LOADAVG," ");

# Determine cores and re-evaluate the load averages:
ONE_LOADAVG = ARRAY_LOADAVG[1] / AWK_CORES
FIVE_LOADAVG = ARRAY_LOADAVG[2] / AWK_CORES
FIFTEEN_LOADAVG = ARRAY_LOADAVG[3] / AWK_CORES

# Set Color and Load Average values into independent arrays:
if (AWK_COLORS = 256) {
    ESCAPE_SEQUENCE="38;05;"
    # Set Color Values:
    ARRAY_COLORS[1] = 21
    ARRAY_COLORS[2] = 27
    ARRAY_COLORS[3] = 33
    ARRAY_COLORS[4] = 39
    ARRAY_COLORS[5] = 45
    ARRAY_COLORS[6] = 51
    ARRAY_COLORS[7] = 50
    ARRAY_COLORS[8] = 49
    ARRAY_COLORS[9] = 48
    ARRAY_COLORS[10] = 47
    ARRAY_COLORS[11] = 46
    ARRAY_COLORS[12] = 82 
    ARRAY_COLORS[13] = 118 
    ARRAY_COLORS[14] = 154 
    ARRAY_COLORS[15] = 190 
    ARRAY_COLORS[16] = 226 
    ARRAY_COLORS[17] = 220 
    ARRAY_COLORS[18] = 214 
    ARRAY_COLORS[19] = 208 
    ARRAY_COLORS[20] = 202 
    ARRAY_COLORS[21] = 196
    # Set Load Average Values:
    ARRAY_LOADAVG_VALUES[1] = 0.00 
    ARRAY_LOADAVG_VALUES[2] = 0.25 
    ARRAY_LOADAVG_VALUES[3] = 0.50 
    ARRAY_LOADAVG_VALUES[4] = 0.75 
    ARRAY_LOADAVG_VALUES[5] = 1.00 
    ARRAY_LOADAVG_VALUES[6] = 1.25 
    ARRAY_LOADAVG_VALUES[7] = 1.50
    ARRAY_LOADAVG_VALUES[8] = 1.75 
    ARRAY_LOADAVG_VALUES[9] = 2.00 
    ARRAY_LOADAVG_VALUES[10] = 2.25 
    ARRAY_LOADAVG_VALUES[11] = 2.50 
    ARRAY_LOADAVG_VALUES[12] = 2.75 
    ARRAY_LOADAVG_VALUES[13] = 3.00 
    ARRAY_LOADAVG_VALUES[14] = 3.25 
    ARRAY_LOADAVG_VALUES[15] = 3.59 
    ARRAY_LOADAVG_VALUES[16] = 3.75 
    ARRAY_LOADAVG_VALUES[17] = 4.00 
    ARRAY_LOADAVG_VALUES[18] = 4.25 
    ARRAY_LOADAVG_VALUES[19] = 4.50 
    ARRAY_LOADAVG_VALUES[20] = 4.75 
    ARRAY_LOADAVG_VALUES[21] = 5.00 
    }
else if (AWK_COLORS = 88) {
    ESCAPE_SEQUENCE="38;05;"
    # Set Color Values:
    ARRAY_COLORS[1] = 21
    ARRAY_COLORS[2] = 27
    ARRAY_COLORS[3] = 33
    ARRAY_COLORS[4] = 39
    ARRAY_COLORS[5] = 45
    ARRAY_COLORS[6] = 51
    ARRAY_COLORS[7] = 50
    ARRAY_COLORS[8] = 49
    ARRAY_COLORS[9] = 48
    ARRAY_COLORS[10] = 47
    ARRAY_COLORS[11] = 46
    ARRAY_COLORS[12] = 82 
    ARRAY_COLORS[13] = 118 
    ARRAY_COLORS[14] = 154 
    ARRAY_COLORS[15] = 190 
    ARRAY_COLORS[16] = 226 
    ARRAY_COLORS[17] = 220 
    ARRAY_COLORS[18] = 214 
    ARRAY_COLORS[19] = 208 
    ARRAY_COLORS[20] = 202 
    ARRAY_COLORS[21] = 196
    # Set Load Average Values:
    ARRAY_LOADAVG_VALUES[1] = 0.00 
    ARRAY_LOADAVG_VALUES[2] = 0.25 
    ARRAY_LOADAVG_VALUES[3] = 0.50 
    ARRAY_LOADAVG_VALUES[4] = 0.75 
    ARRAY_LOADAVG_VALUES[5] = 1.00 
    ARRAY_LOADAVG_VALUES[6] = 1.25 
    ARRAY_LOADAVG_VALUES[7] = 1.50
    ARRAY_LOADAVG_VALUES[8] = 1.75 
    ARRAY_LOADAVG_VALUES[9] = 2.00 
    ARRAY_LOADAVG_VALUES[10] = 2.25 
    ARRAY_LOADAVG_VALUES[11] = 2.50 
    ARRAY_LOADAVG_VALUES[12] = 2.75 
    ARRAY_LOADAVG_VALUES[13] = 3.00 
    ARRAY_LOADAVG_VALUES[14] = 3.25 
    ARRAY_LOADAVG_VALUES[15] = 3.59 
    ARRAY_LOADAVG_VALUES[16] = 3.75 
    ARRAY_LOADAVG_VALUES[17] = 4.00 
    ARRAY_LOADAVG_VALUES[18] = 4.25 
    ARRAY_LOADAVG_VALUES[19] = 4.50 
    ARRAY_LOADAVG_VALUES[20] = 4.75 
    ARRAY_LOADAVG_VALUES[21] = 5.00 
    }
else if (AWK_COLORS = 16) {
    ESCAPE_SEQUENCE=""
    # Set Color Values:
    ARRAY_COLORS[1] = 34  
    ARRAY_COLORS[2] = 36 
    ARRAY_COLORS[3] = 32 
    ARRAY_COLORS[4] = 33
    ARRAY_COLORS[5] = 31 
    # Set Load Average Values:
    ARRAY_LOADAVG_VALUES[1] = 0.00 
    ARRAY_LOADAVG_VALUES[2] = 1.00 
    ARRAY_LOADAVG_VALUES[3] = 2.00 
    ARRAY_LOADAVG_VALUES[4] = 3.00 
    ARRAY_LOADAVG_VALUES[5] = 5.00 
    }
else {
    print "ERROR: Terminal colors not passed to AWK. Exiting."
    exit 1
    }

# Apply colors:
for (i = 1; i < length(ARRAY_LOADAVG_VALUES); i++)
    # One Minute:
    if (ONE_LOADAVG >= ARRAY_LOADAVG_VALUES[i])  
        ONE="\033["ESCAPE_SEQUENCE""ARRAY_COLORS[i]"m"ARRAY_LOADAVG[1]"\033[0m"; 
        print "inside ONE if"
        print "ARRAY_LOADAVG_VALUES[i] is: "ARRAY_LOADAVG_VALUES[i]
        print "ARRAY_COLORS[i] is: "ARRAY_COLORS[i]
    
    # Five Minute:
    if (FIVE_LOADAVG >= ARRAY_LOADAVG_VALUES[i])  
        FIVE="\033["ESCAPE_SEQUENCE""ARRAY_COLORS[i]"m"ARRAY_LOADAVG[2]"\033[0m"; 
        print "inside FIVE if"
        print "ARRAY_LOADAVG_VALUES[i] is: "ARRAY_LOADAVG_VALUES[i]
        print "ARRAY_COLORS[i] is: "ARRAY_COLORS[i] 
    
    # Fifteen Minute:
    if (FIFTEEN_LOADAVG >= ARRAY_LOADAVG_VALUES[i])  
        FIFTEEN="\033["ESCAPE_SEQUENCE""ARRAY_COLORS[i]"m"ARRAY_LOADAVG[3]"\033[0m"; 
        print "inside FIFTEEN if"
        print "ARRAY_LOADAVG_VALUES[i] is: "ARRAY_LOADAVG_VALUES[i]
        print "ARRAY_COLORS[i] is: "ARRAY_COLORS[i] 
    
##### CODE BELOW WORKS. ###
# 256-color terminals
#    # One Minute Average: 
#    if (ONE_LOADAVG >= 5.00)
#        # Red
#        ONE="\033[38;05;196m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 4.75)
#        # 
#        ONE="\033[38;05;202m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 4.50)
#        # 
#        ONE="\033[38;05;208m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 4.25)
#        # 
#        ONE="\033[38;05;214m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 4.00)
#        # 
#        ONE="\033[38;05;220m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 3.75)
#        # Yellow 
#        ONE="\033[38;05;226m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 3.50)
#        # 
#        ONE="\033[38;05;190m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 3.25)
#        # 
#        ONE="\033[38;05;154m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 3.00)
#        # Red
#        ONE="\033[38;05;118m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 2.75)
#        # 
#        ONE="\033[38;05;82m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 2.50)
#        # Green
#        ONE="\033[38;05;46m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 2.25)
#        # 
#        ONE="\033[38;05;47m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 2.00)
#        # 
#        ONE="\033[38;05;48m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 1.75)
#        # 
#        ONE="\033[38;05;49m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 1.50)
#        # Cyan 
#        ONE="\033[38;05;50m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 1.25)
#        # 
#        ONE="\033[38;05;51m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 1.00)
#        # 
#        ONE="\033[38;05;45m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 0.75)
#        # 
#        ONE="\033[38;05;39m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 0.50)
#        # 
#        ONE="\033[38;05;33m"ARRAY_LOADAVG[1]"\033[0m";        
#    else if (ONE_LOADAVG >= 0.25)
#        #  
#        ONE="\033[38;05;27m"ARRAY_LOADAVG[1]"\033[0m";
#    else 
#        # Blue 
#        ONE="\033[38;05;21m"ARRAY_LOADAVG[1]"\033[0m";
#
#    # Five Minute Average:
#    if (FIVE_LOADAVG >= 5.00)
#        # Red
#        FIVE="\033[38;05;196m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 4.75)
#        # 
#        FIVE="\033[38;05;202m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 4.50)
#        # 
#        FIVE="\033[38;05;208m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 4.25)
#        # 
#        FIVE="\033[38;05;214m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 4.00)
#        # 
#        FIVE="\033[38;05;220m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 3.75)
#        # Yellow 
#        FIVE="\033[38;05;226m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 3.50)
#        # 
#        FIVE="\033[38;05;190m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 3.25)
#        # 
#        FIVE="\033[38;05;154m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 3.00)
#        # Red
#        FIVE="\033[38;05;118m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 2.75)
#        # 
#        FIVE="\033[38;05;82m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 2.50)
#        # Green
#        FIVE="\033[38;05;46m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 2.25)
#        # 
#        FIVE="\033[38;05;47m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 2.00)
#        # 
#        FIVE="\033[38;05;48m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 1.75)
#        # 
#        FIVE="\033[38;05;49m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 1.50)
#        # Cyan 
#        FIVE="\033[38;05;50m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 1.25)
#        # 
#        FIVE="\033[38;05;51m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 1.00)
#        # 
#        FIVE="\033[38;05;45m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 0.75)
#        # 
#        FIVE="\033[38;05;39m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 0.50)
#        # 
#        FIVE="\033[38;05;33m"ARRAY_LOADAVG[2]"\033[0m";        
#    else if (FIVE_LOADAVG >= 0.25)
#        #  
#        FIVE="\033[38;05;27m"ARRAY_LOADAVG[2]"\033[0m";
#    else 
#        # Blue 
#        FIVE="\033[38;05;21m"ARRAY_LOADAVG[2]"\033[0m";
#
#    # Fifteen Minute Average:
#    if (FIFTEEN_LOADAVG >= 5.00)
#        # Red
#        FIFTEEN="\033[38;05;196m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 4.75)
#        # 
#        FIFTEEN="\033[38;05;202m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 4.50)
#        # 
#        FIFTEEN="\033[38;05;208m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 4.25)
#        # 
#        FIFTEEN="\033[38;05;214m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 4.00)
#        # 
#        FIFTEEN="\033[38;05;220m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 3.75)
#        # Yellow 
#        FIFTEEN="\033[38;05;226m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 3.50)
#        # 
#        FIFTEEN="\033[38;05;190m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 3.25)
#        # 
#        FIFTEEN="\033[38;05;154m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 3.00)
#        # Red
#        FIFTEEN="\033[38;05;118m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 2.75)
#        # 
#        FIFTEEN="\033[38;05;82m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 2.50)
#        # Green
#        FIFTEEN="\033[38;05;46m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 2.25)
#        # 
#        FIFTEEN="\033[38;05;47m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 2.00)
#        # 
#        FIFTEEN="\033[38;05;48m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 1.75)
#        # 
#        FIFTEEN="\033[38;05;49m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 1.50)
#        # Cyan 
#        FIFTEEN="\033[38;05;50m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 1.25)
#        # 
#        FIFTEEN="\033[38;05;51m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 1.00)
#        # 
#        FIFTEEN="\033[38;05;45m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 0.75)
#        # 
#        FIFTEEN="\033[38;05;39m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 0.50)
#        # 
#        FIFTEEN="\033[38;05;33m"ARRAY_LOADAVG[3]"\033[0m";        
#    else if (FIFTEEN_LOADAVG >= 0.25)
#        #  
#        FIFTEEN="\033[38;05;27m"ARRAY_LOADAVG[3]"\033[0m";
#    else 
#        # Blue 
#        FIFTEEN="\033[38;05;21m"ARRAY_LOADAVG[3]"\033[0m"; 
### 
#    # One Minute Average: 
#    if (ONE_LOADAVG >= 5)
#        # Red
#        ONE="\033[31m"ARRAY_LOADAVG[1]"\033[0m";
#    else if (ONE_LOADAVG >= 1)
#        # Yellow
#        ONE="\033[33m"ARRAY_LOADAVG[1]"\033[0m";
#    else 
#        # Green
#        ONE="\033[32m"ARRAY_LOADAVG[1]"\033[0m";
#
#    # Five Minute Average:
#    if (FIVE_LOADAVG >= 5)
#        # Red
#        FIVE="\033[31m"ARRAY_LOADAVG[2]"\033[0m";
#    else if (FIVE_LOADAVG >= 1)
#        # Yellow
#        FIVE="\033[33m"ARRAY_LOADAVG[2]"\033[0m";
#    else 
#        # Green
#        FIVE="\033[32m"ARRAY_LOADAVG[2]"\033[0m";
#
#    # Fifteen Minute Average:
#    if (FIFTEEN_LOADAVG >= 5)
#        # Red 
#        FIFTEEN="\033[31m"ARRAY_LOADAVG[3]"\033[0m";
#    else if (FIFTEEN_LOADAVG >= 1)
#        # Yellow
#        FIFTEEN="\033[33m"ARRAY_LOADAVG[3]"\033[0m";
#    else 
#        # Green
#        FIFTEEN="\033[32m"ARRAY_LOADAVG[3]"\033[0m";


# One line with all three outputs
print ONE, FIVE, FIFTEEN;
print AWK_COLORS, AWK_CORES;
}'`

# Print output.
$PRINTF "$OUTPUT\n"

exit 0
#EOF
