#!/bin/sh
#
# Name: Sanity_Check
# 
# Description: This script will check for core programs, required for basic
# use. It should return 0 for true and 1 for false if environment passes or
# fails sanity check.
#

###       ###
### TO DO ###
###       ###

# Define scope of this program.
# .

###          ###
### PROGRAMS ###
###          ###

# Essentials to run.
AWK="/usr/bin/awk"
BASENAME="/usr/bin/basename"
CAT="/bin/cat"
LS="/bin/ls"
PRINTF="/usr/bin/printf"
TEST="/bin/test"

# Only absolute core programs should be hard-coded here. The purpose of this
# script is to search for them and make sure everything exists.

# Programs should be initially defined. Hard-coding them provides a place for
# the program to begin it's checks to see if said program actually exists.

# These should be arrays; the first for the program name, the second for the
# hard-coded location, and a third for a program name to variable conversion.

# It might be worthwhile to store the list of programs in an external text file
# so it can be modified in the future, should programs not reside where they
# are hard-coded on a particular system.

#/bin - This should be populated from .program_list, but initially defined 
# in case .program_list cannot be found or is corrupt.
if [[ -e "$DIRECTORY/.program_list" ]]; do
    declare -a ARRAY_PROGRAM_DIRECTORY=(`$CAT $DIRECTORY/.program_list`)
else 
    declare -a ARRAY_PROGRAM_DIRECTORY=(
        /bin/bash
        /bin/cat
        /bin/chmod
        /bin/cp
        /bin/csh
        /bin/date
        /bin/dd
        /bin/df
        /bin/domainname
        /bin/echo
        /bin/ed
        /bin/expr
        /bin/hostname
        /bin/kill
        /bin/ksh
        /bin/launchctl
        /bin/link
        /bin/ln
        /bin/ls
        /bin/mkdir
        /bin/mv
        /bin/pax
        /bin/ps
        /bin/pwd
        /bin/rcp
        /bin/rm
        /bin/rmdir
        /bin/sh
        /bin/sleep
        /bin/stty
        /bin/sync
        /bin/tcsh
        /bin/test
        /bin/unlink
        /bin/wait4path
        /bin/zsh
        /usr/bin/a2p

        /usr/bin/awk
        /usr/bin/banner
        /usr/bin/basename
        /usr/bin/bashbug
        /usr/bin/batch
        /usr/bin/bc
        /usr/bin/bg
        /usr/bin/biff
        /usr/bin/binhex
        /usr/bin/curl
        /usr/bin/cksum
        /usr/bin/diff
        /usr/bin/find
        /usr/bin/grep
        /usr/bin/locate
        /usr/bin/printf
        /usr/bin/sed
        /usr/bin/uptime
    )
fi
#/sbin
#Will need to be a superuser to check for these.
    declare -a ARRAY_SUPERUSER_PROGRAM_DIRECTORY=(
        /sbin/autodiskmount
        /sbin/clri
        /sbin/dmesg
        /sbin/dump
        /sbin/dumpfs
        /sbin/dynamic_pager
        /sbin/fibreconfig
        /sbin/fsck
        /sbin/fsck_exfat
        /sbin/fsck_hfs
        /sbin/fsck_msdos
        /sbin/fsck_udf
        /sbin/fstyp
        /sbin/fstyp_hfs
        /sbin/fstyp_msdos
        /sbin/fstyp_ntfs
        /sbin/fstyp_udf
        /sbin/fstyp_ufs
        /sbin/halt
        /sbin/ifconfig
        /sbin/ip6fw
        /sbin/ipfw
        /sbin/kerberosautoconfig
        /sbin/kextload
        /sbin/kextunload
        /sbin/launchd
        /sbin/md5
        /sbin/md5
        /sbin/mount
        /sbin/mount_afp
        /sbin/mount_cd9660
        /sbin/mount_cddafs
        /sbin/mount_devfs
        /sbin/mount_exfat
        /sbin/mount_fdesc
        /sbin/mount_ftp
        /sbin/mount_hfs
        /sbin/mount_msdos
        /sbin/mount_nfs
        /sbin/mount_ntfs
        /sbin/mount_smbfs
        /sbin/mount_udf
        /sbin/mount_webdav
        /sbin/newfs_exfat
        /sbin/newfs_hfs
        /sbin/newfs_msdos
        /sbin/newfs_udf
        /sbin/nfsd
        /sbin/nfsiod
        /sbin/nologin
        /sbin/ping
        /sbin/ping6
        /sbin/quotacheck
        /sbin/rdump
        /sbin/reboot
        /sbin/restore
        /sbin/route
        /sbin/rrestore
        /sbin/rtsol
        /sbin/service
        /sbin/shutdown
        /sbin/SystemStarter
        /sbin/tunefs
        /sbin/umount
   )

declare -a ARRAY_PROGRAM_NAME=()
# Use AWK to cut characters from just after the last slash in 
# ARRAY_PROGRAM_DIRECTORY to populate this array.    
for ((i=0; i < ${#ARRAY_PROGRAM_DIRECTORY[*]}; i++)) do 
    set ARRAY_PROGRAM_NAME[$i]=(`$LS ${ARRAY_PROGRAM_DIRECTORY[$i]} | $AWK '{print $1}'`)
done

# Populate an array from the specified PATH.
# This assumes that the $PATH variable is set and is sane.
# Split $PATH into an array.
declare -a ARRAY_PATH=(`$PRINTF "$PATH" | $AWK -F: -v OFS="\n" '$1=$1'`)

#
#declare -a ARRAY_PATH=(
#    /bin
#    /sbin
#    /usr/bin
#    /usr/sbin
#    /usr/local/bin
#    /usr/local/sbin
#    /opt/bin
#    /opt/sbin
#    /sw/bin
#    /sw/sbin
#    ~/bin
#    ~/sbin
#    )



###           ###
### VARIABLES ###
###           ###

SCRIPTNAME=`$BASENAME $0`
DIRECTORY="~"

###           ###
### FUNCTIONS ###
###           ###

# Displays the help menu when program is invoked with no parameters.
fnHELP() {
    $PRINTF "$SCRIPTNAME Help:\r
            \rUsage: $SCRIPTNAME shortname [-DhkmQSvV] [-c comment] [-d home-dir]
            \r[-g initial_group] [-G group[,...]] [-i password_hint] [-l longname]
            \r[-m [-K skeleton_dir]] [-p passwd] [-P picture_location] [-s shell] [-u uid]\n"

}

# Used to generate the list of programs on a system.
fn_GENERATE_PROGRAM_LIST() {
    
    # Ask user where to create .program_list
    $PRINTF "Where should '.program_list' be generated?\rPlease enter a
    directory.\n"
    
    read DIRECTORY

    # Be sure the directory specified is actually a directory.
    if [[ ! -d "$DIRECTORY" ]]; then
        $PRINTF "Specified directory does not exist.\n"
        exit 1
    fi

    # Generate .program_list.
    for ((i=0; i < ${#ARRAY_PATH[*]}; i++; )) do
    
        # Check $ARRAY_PATH for last directory name.
        if [[ directoryname = ]]; then
            
            # Check for superuser privileges first.
            if [[ $EUID -eq 0 ]]; then
                $LS ${ARRAY_PATH[$i]} > $DIRECTORY/.program_list
            else
                $i++
            fi
        else
            # This will catch all directories NOT requiring superuser privileges.
            $LS ${ARRAY_PATH[$i]} > $DIRECTORY/.program_list
        fi
    done
}

###      ###
### MAIN ###
###      ###

# Populates an array with arguments given.
declare -a ARRAY_ARGUMENTS=($@)

# Parse ARRAY_ARGUMENTS for program names. If True, return directory, else
# return false.

# Check if program exists by using -e
# if yes, return true, if not, search. If still not, return false.

# Search:
# if locate
# is locate's db updated?
# check?
# if yes, do something, if not, prompt user? Automatically update? Should we
# bother checking?
#do something
#else if find
#else exit


# EOF
exit 0
