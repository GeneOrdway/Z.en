#!/bin/sh
# 
# Shell script to calculate the number of files in a directory and the
# directory's size. 

###       ###
### TO DO ###
###       ###

# 1) -

###           ###
### VARIABLES ###
###           ###
FILE_SIZES_TOTAL_BYTES=0
FILE_SIZES_TOTAL_HUMAN=0

# Set input to a variable. 
DIRECTORY=$1

###          ###
### PROGRAMS ###
###          ###
FIND="/usr/bin/find"
XARGS="/usr/bin/xargs"
STAT="/usr/bin/stat"
PRINTF="/usr/bin/printf"
#LS="/bin/ls"
#AWK="/usr/bin/awk"
B2H="$HOME/b2h.sh"

###        ###
### ARRAYS ###
###        ###
ARRAY_DIRECTORY_FILE_SIZES=()

###           ###
### FUNCTIONS ###
###           ###

###      ###
### MAIN ###
###      ###

# Error Checking:
if [ ! -d $DIRECTORY ]; then
# Is the supplied directory actually a directory?
    $PRINTF "$DIRECTORY is not a directory.\n"
    exit 1
elif [ ! -r $DIRECTORY ]; then
# Is the supplied directory readable?
    $PRINTF "Directory $DIRECTORY is not readable.\n"
    exit 1
fi

# External scripts:
if [ ! -e $B2H ]; then
# Does the script b2h exist?
    $PRINTF "Cannot find $B2h.\n"
    exit 1
elif [ ! -x $B2h ]; then
# Is the script b2h executable?
    $PRINTF "$B2H is not writeable.\n"
    exit 1
fi

# Populate the arrays.

# Determine the Operating System:
# OS X
if [[ "$OSTYPE" == "darwin"* ]]; then  
#    FILE_SIZES_TOTAL_HUMAN=`$LS -Alp $1 | $AWK '!/\//{FILE_SIZES_TOTAL_BYTES+=$5} END {print FILE_SIZES_TOTAL_BYTES}'`
#    FILE_SIZES_TOTAL_HUMAN=`$LS -Alp $1 | $AWK '{gsub(!/\//,FILE_SIZES_TOTAL_BYTES+=$5),print FILE_SIZES_TOTAL_BYTES}'`
#    FILE_SIZES_TOTAL_HUMAN=`$LS -Alp $1 | $AWK 'function human(x) {
#         s=" B   KiB MiB GiB TiB EiB PiB YiB ZiB"
#         while (x>=1024 && length(s)>1) 
#               {x/=1024; s=substr(s,5)}
#         s=substr(s,1,4)
#         xf=(s==" B  ")?"%5d   ":"%8.2f"
#         return sprintf( xf"%s\n", x, s)
#      }
#      {gsub(!/\//, human($5)); print}'`     
    ARRAY_DIRECTORY_FILE_SIZES=(`$FIND $DIRECTORY/* -maxdepth 1 -prune -type f -print0 | $XARGS -0 $STAT -f '%z'`)
    echo "ARRAY_DIRECTORY_FILE_SIZES is: ${ARRAY_DIRECTORY_FILE_SIZES[*]}"
#FreeBSD
elif [[ "$OSTYPE" == "freebsd"* ]]; then 
    ARRAY_DIRECTORY_FILE_SIZES=`$LS -Al | $AWK '!/\// {print $5}'`
# Linux
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    ARRAY_DIRECTORY_FILE_SIZES=""
else 
    $PRINTF "Could not determine Operating System. Exiting.\n"
    exit 1
fi

# 
NUMBER_OF_FILES=${#ARRAY_DIRECTORY_FILE_SIZES[@]}
$PRINTF "Number of files in $DIRECTORY: $NUMBER_OF_FILES\n"

# Count up the bytes:
for ((i=0; i<${#ARRAY_DIRECTORY_FILE_SIZES[@]}; i++)) do
    FILE_SIZES_TOTAL_BYTES=$((FILE_SIZES_TOTAL_BYTES+ARRAY_DIRECTORY_FILE_SIZES[$i]))
done

echo "FILE_SIZES_TOTAL_BYTES is: $FILE_SIZES_TOTAL_BYTES"

# Convert bytes to human-readable:
$B2H $FILE_SIZES_TOTAL_BYTES


#$PRINTF "$FILE_SIZES_TOTAL_HUMAN\n"
#
#for ((i=0; i<${#ARRAY_DIRECTORY_FILE_SIZES}; i++;)); do 
#    DIRECTORY_SIZE="DIRECTORY_SIZE+ARRAY_DIRECTORY_FILE_SIZES[i]"
#done

###          ###
### EXAMPLES ###
###          ###

#awk 'function human(FILE_SIZE) {
#         SIZE_STRING=" B   KiB MiB GiB TiB EiB PiB YiB ZiB"
#         while (FILE_SIZE>=1024 && length(SIZE_STRING)>1) 
#               {FILE_SIZE/=1024; SIZE_STRING=substr(SIZE_STRING,5)}
#         SIZE_STRING=substr(SIZE_STRING,1,4)
#         xf=(SIZE_STRING==" B  ")?"%5d   ":"%8.2f"
#         return sprintf( xf"%SIZE_STRING\n", FILE_SIZE, SIZE_STRING)
#      }
#      {gsub(/^[0-9]+/, human($1)); print}'


#{ if (match($0,/your regexp/,m)) print m[0] }

# EOF
