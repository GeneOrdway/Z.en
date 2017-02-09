#!/usr/bin/awk -f
# 
# Awk script to convert bytes to a more human-readable form.
# Eg. KB, MB, GB, TB, PB, YB, EB, etc.

###                     ###
### SCRIPT EXPECTATIONS ###
###                     ###

# Input Expected:
# bytes2human.sh (numeric integer value)

# Output Expected:
# (numeric floating point value)

###       ###
### TO DO ###
###       ###

# 1) -

###           ###
### FUNCTIONS ###
###           ###
function show_help() {
    print "Help Menu:"
}

BEGIN {
###           ###
### VARIABLES ###
###           ###
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
ARRAY_FILE_SIZE_LABELS[7]="YB"
ARRAY_FILE_SIZE_LABELS[8]="EB"

###      ###
### MAIN ###
###      ###
for (i = 1; i < ARGC; i++) {
    print "Arguments are: "ARGV[i]
    }

for (i = 1; i < ARGC; i++) {
    if (ARGV[i]=="-d" || ARGV[i]=="--debug") {
        # Debug:
        NOISE_LEVEL=5
        print "debug"
        }
    else if (ARGV[i]=="-v" || ARGV[i]=="--verbose")  {
        # Verbose:
        NOISE_LEVEL=4
        print "verbose"
        }
    else if (ARGV[i]=="-q" || ARGV[i]=="--quiet") {
        # Quiet:
        NOISE_LEVEL=2
        print "quiet"
        }
    else if (ARGV[i]=="-s" || ARGV[i]=="--silent") {
        # Silent: 
        NOISE_LEVEL=1
        print "silent"
        }
    else if (ARGV[i]=="-h" || ARGV[i]=="--help") {
        # Help
        print "help"
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
        print "ARRAY_FILE_SIZES["i",1] is: "ARRAY_FILE_SIZES[i,1]
        }
    else {
        # Check that this outputs the whole error message.
        ERROR = sprintf("%s: Invalid argument passed to script. Exiting.",
                ARGV[0], substr(ARGV[i], 2, 1))
        print ERROR > "/dev/stderr"
        exit 1
        }
    }
print "Done"
print "NOISE_LEVEL is: "NOISE_LEVEL
print ""
#
CURRENT_STEP=1
NEXT_STEP=2
#
for (WAKLER = 1; WALKER <= length(ARRAY_FILE_SIZES[WALKER,1]); WALKER++) {
print "Inside for loop."
print "For Begin: ARRAY_FILE_SIZES["WALKER","CURRENT_STEP"](CURRENT_STEP) is: "ARRAY_FILE_SIZES[WALKER,CURRENT_STEP]
# Divide the current value by 1024 bytes to produce the next measurement.
while (ARRAY_FILE_SIZES[WALKER,CURRENT_STEP]>=1024) {
    print "\tInside while loop."
    print "\tCURRENT_STEP is: "CURRENT_STEP
    print "\tWhile Begin: ARRAY_FILE_SIZES["WALKER","CURRENT_STEP"](CURRENT_STEP) is: "ARRAY_FILE_SIZES[WALKER,CURRENT_STEP]
    ARRAY_FILE_SIZES[WALKER,NEXT_STEP]=(ARRAY_FILE_SIZES[WALKER,CURRENT_STEP] / 1024)
    CURRENT_STEP++
    NEXT_STEP=(CURRENT_STEP+1)
    print "\tCURRENT_STEP is: "CURRENT_STEP
    print "\tNEXT_STEP is: "NEXT_STEP
    print "\tWhile End: ARRAY_FILE_SIZES["WALKER","CURRENT_STEP"](CURRENT_STEP) is: "ARRAY_FILE_SIZES[WALKER,CURRENT_STEP]
    }
print "For End: ARRAY_FILE_SIZES["WALKER","CURRENT_STEP"](CURRENT_STEP) is: "ARRAY_FILE_SIZES[WALKER,CURRENT_STEP]
print "ARRAY_FILE_SIZE_LABELS["CURRENT_STEP"](CURRENT_STEP) is: "ARRAY_FILE_SIZE_LABELS[CURRENT_STEP]
# Store sizes to an array, ARRAY_LARGEST_FILE_SIZES, for easier output later.
ARRAY_LARGEST_FILE_SIZES[WALKER]=sprintf("%.2f %s", ARRAY_FILE_SIZES[WALKER,CURRENT_STEP], ARRAY_FILE_SIZE_LABELS[CURRENT_STEP])

# Reset CURRENT_STEP and NEXT_STEP for the next iteration.
CURRENT_STEP=1   
NEXT_STEP=2
}

# Print output
print "ARRAY_LARGEST_FILE_SIZES is: "ARRAY_LARGEST_FILE_SIZES[1]
for (i = 1; i < length(ARRAY_LARGEST_FILE_SIZES); i++) { 
    print "Inside LARGEST FILE SIZES for loop."
    print ARRAY_LARGEST_FILE_SIZES[i]
    }

exit 0
}
#EOF
