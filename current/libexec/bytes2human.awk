#!/usr/bin/awk -f
# 
# Awk script to convert bytes to a more human-readable form.
# Eg. KB, MB, GB, TB, PB, YB, EB, etc.

###                     ###
### SCRIPT EXPECTATIONS ###
###                     ###

# Input Expected:
# bytes2human.awk (numeric integer value(s) separated by spaces) 
# Eg. ./bytes2human.awk 1024 2048 4096

# Output Expected:
# (numeric floating point value) + file size label 
# Eg. % 1.00 KB, 2.00 KB, 4.00 KB 

###       ###
### TO DO ###
###       ###

# 1) - Finish help menu output 
# 2) - Add debug info back into script. See bytes2human.awk in 'old' directory
# 3) - Add additional error-checking for a few mistakes below and for values
#       input larger than known labels.
# 4) - Add ability to convert bits
# 5) - 

###           ###
### FUNCTIONS ###
###           ###
function show_help() {
print "Help Menu:"
#    print "$SCRIPTNAME Help:\r
#    \rUsage: $SCRIPTNAME [-dhqsv] [-a directory] [-b directory] [-f file]\r
#            \r
#\rOr with POSIX-style arguments:\r
#\rUsage: $SCRIPTNAME [--debug --help --quiet --silent --verbose]\r
#\r                    [--post-append directory] [--pre-append directory]\r 
#\r                    [--file configuration]
#\r
#\rExample: $SCRIPTNAME -v -a /usr/local/bin /usr/local/sbin -b /bin \r
#\rOR
#\rExample: $SCRIPTNAME --verbose --pre-append /usr/local/sbin --post-append /bin \r
#\r
#\rGNU-STYLE:    | POSIX-STYLE:            | EXPLANATION:\r
#\r______________|_________________________|_______________________________________\r
#\r -a directory | --post-append directory | post-append directory to path.\r 
#\r -b directory | --pre-append directory  | pre-append directory to path.\r
#\r -d           | --debug                 | Debug output - Useful for scripting.\r
#\r -f file      | --file                  | Specify configuration file.\r
#\r -h           | --help                  | Print this help menu.\r
#\r -q           | --quiet                 | Quiet output - Errors messages only.\r
#\r -s           | --silent                | Silent output - No messages.\r
#\r -v           | --verbose               | Verbose output - See all messages. \n"
}

BEGIN {
###           ###
### VARIABLES ###
###           ###
FILE_SIZES_LENGTH=0
WALKER=1
CURRENT_STEP=1
NEXT_STEP=2
NOISE_LEVEL=3

###        ###
### ARRAYS ###
###        ###
ARRAY_FILE_SIZE_LABELS[1]="B"
ARRAY_FILE_SIZE_LABELS[2]="KB"
ARRAY_FILE_SIZE_LABELS[3]="MB"
ARRAY_FILE_SIZE_LABELS[4]="GB"
ARRAY_FILE_SIZE_LABELS[5]="TB"
ARRAY_FILE_SIZE_LABELS[6]="PB"
ARRAY_FILE_SIZE_LABELS[7]="EB"
ARRAY_FILE_SIZE_LABELS[8]="ZB"
ARRAY_FILE_SIZE_LABELS[10]="YB"

###      ###
### MAIN ###
###      ###
for (i = 1; i < ARGC; i++) {
    if (ARGV[i]=="-d" || ARGV[i]=="--debug") {
        # Debug:
        NOISE_LEVEL=5
    }
    else if (ARGV[i]=="-v" || ARGV[i]=="--verbose")  {
        # Verbose:
        NOISE_LEVEL=4
    }
    else if (ARGV[i]=="-q" || ARGV[i]=="--quiet") {
        # Quiet:
        NOISE_LEVEL=2
    }
    else if (ARGV[i]=="-s" || ARGV[i]=="--silent") {
        # Silent: 
        NOISE_LEVEL=1
    }
    else if (ARGV[i]=="-h" || ARGV[i]=="--help") {
        # Help
        show_help() 
        exit 0
    }
    else if (ARGV[i] ~ /^-./ || ARGV[i] ~ /^--./) {
        # Need a better regular expression for POSIX arguments.
        # This works, but it's ugly. Error message only outputs a single
        # dash after the error, not the whole word.
        ERROR = sprintf("%s: Unrecognized option -- %c",
                ARGV[0], substr(ARGV[i], 2, 1))
        print ERROR > "/dev/stderr"
        exit 1
    }
    else if (ARGV[i] ~ /^[0-9]*$/) {
        # Store arguments into a multidimensional array 
        ARRAY_FILE_SIZES[i,1] = ARGV[i]
        # Increment the array's length counter
        FILE_SIZES_LENGTH++
    }
    else {
        # Check that this outputs the whole error message.
        ERROR = sprintf("%s: Invalid argument passed to script. Exiting.",
                ARGV[0], substr(ARGV[i], 2, 1))
        print ERROR > "/dev/stderr"
        exit 1
    }
}

# Divide the current value by 1024 bytes to produce the next measurement.# 
for (i = 1; i <= FILE_SIZES_LENGTH; i++) {
    while (ARRAY_FILE_SIZES[WALKER,CURRENT_STEP]>=1024) {
        ARRAY_FILE_SIZES[WALKER,NEXT_STEP]=(ARRAY_FILE_SIZES[WALKER,CURRENT_STEP] / 1024)
        CURRENT_STEP++
        NEXT_STEP=(CURRENT_STEP+1)
    }

    # Store sizes to an array, ARRAY_LARGEST_FILE_SIZES, for easier output later.
    ARRAY_LARGEST_FILE_SIZES[WALKER]=sprintf("%.2f %s", ARRAY_FILE_SIZES[WALKER,CURRENT_STEP], ARRAY_FILE_SIZE_LABELS[CURRENT_STEP])

    # Iterate WALKER and reset CURRENT_STEP and NEXT_STEP for the next iteration.
    WALKER++
    CURRENT_STEP=1   
    NEXT_STEP=2
}

# Print output in single line, with comma-separated values if more than one argument.
for (i = 1; i <= length(ARRAY_LARGEST_FILE_SIZES); i++) { 
    if (1 == length(ARRAY_LARGEST_FILE_SIZES)) { 
        printf "%s\n", ARRAY_LARGEST_FILE_SIZES[i]
    }
    else if (i == length(ARRAY_LARGEST_FILE_SIZES)) { 
        printf "%s\n", ARRAY_LARGEST_FILE_SIZES[i]
    }
    else {
        printf "%s, ", ARRAY_LARGEST_FILE_SIZES[i]
    }
}

exit 0 }
#EOF
