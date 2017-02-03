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
### VARIABLES ###
###           ###
NOISE_LEVEL=3

###           ###
### FUNCTIONS ###
###           ###
function show_help() {
    print "Help Menu:"
}

###      ###
### MAIN ###
###      ###
BEGIN {
for (i = 1; i < ARGC; i++) {
    print "Arguments are: "ARGV[i]
    }

for (i = 1; i < ARGC; i++) {
    if (ARGV[i]=="-d") {
        # Debug:
        NOISE_LEVEL=5
        print "debug"
        }
    else if (ARGV[i]=="-v")  {
        # Verbose:
        NOISE_LEVEL=4
        print "verbose"
        }
    else if (ARGV[i]=="-q") {
        # Quiet:
        NOISE_LEVEL=2
        print "quiet"
        }
    else if (ARGV[i]=="-s") {
        # Silent: 
        NOISE_LEVEL=1
        print "silent"
        }
    else if (ARGV[i]=="-h") {
        # Help
        print "help"
        show_help() 
        }
    else if (ARGV[i] ~ /^-./) {
        ERROR = sprintf("%s: Unrecognized option -- %c",
                ARGV[0], substr(ARGV[i], 2, 1))
        print ERROR > "/dev/stderr"
        exit 1
        }
    else if (ARGV[i] ~ /^[0-9]*$/) {
        # Store arguments into a multidimensional array 
        ARRAY_FILE_SIZES[i] = ARGV[i]
        print "ARRAY_FILE_SIZES[i] is: "ARRAY_FILE_SIZES[i]
        }
    else {
        ERROR = sprintf("%s: Invalid argument passed to script. Exiting.",
                ARGV[0], substr(ARGV[i], 2, 1))
        print ERROR > "/dev/stderr"
        exit 1
        }
    }
print "Done"

#
#i=1
#while (ARRAY_FILE_SIZES[i][i] <= 1024) {
#    ARRAY_FILE_SIZES[i][i]=
#    }

} END {
exit 0
}
#EOF
