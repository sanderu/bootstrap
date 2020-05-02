#!/bin/bash

# Ensure we fail if variables are not set/populated.
# Removes the danger for doing an "rm -rf" for: ${SOME_VARIABLE}/*
set -o errexit
set -o nounset
set -o pipefail

# Declare a couple of global variables
#declare -g -a PRESET
#declare -g -a ACTIONS

# Variables
SCRIPTNAME=$( basename $0 )
SCRIPTARGS=$@
SCRIPTSTARTCMD=$( ps aux | grep ${PPID} | grep -v grep | awk '{print $11}' )
MYUSER=$( logname )
MYUSERDIR="/home/${MYUSER}"
LOGFILE=${MYUSERDIR}/bootstrap-log.$(date +'%Y%m%d%H%M%S')
LOGGING=1
COMPARE=0
DOWNLOADDIR='/tmp'
HOSTNAME=$( hostname )
RIDEFUNCTION_FILE=''
PRESET_FILE=''

#### Main ####
# Load functions needed for the bootstrapping
source $(pwd)/bootstrap-functions.sh

# Using this script, you are not allowed to use browser etc. directly as root
# which you would be doing, if the preset file contains InstallFirefox as an
# example.
# Parent PID will show full commandline incl. sudo
# Just checking on 'id' will fail as it will show root - then MYUSER will also be root
# and MYUSERDIR would be /home/root/ - YOU DON'T WANT YOUR SYSTEM TO RUN AS ROOT!!!
if [ x${SCRIPTSTARTCMD} != x'sudo' ]; then
        echo 'You need to run the script with sudo.'
        exit 1
fi

# Get and parse arguments for bootstrapping
while getopts "f:p:l:nc" ARGUMENTS; do
    case "${ARGUMENTS}" in
        f)
            # Load the function library file
            if [ -f $(pwd)/${OPTARG} ]; then
                source $(pwd)/${OPTARG}
            else
                echo 'ride-function file does not exist.'
                showUsage
            fi
            RIDEFUNCTION_FILE=${OPTARG}
            ;;
        p)
            # Read the preset-file
            if [ -f $(pwd)/${OPTARG} ]; then
                readPresetFile $(pwd)/${OPTARG}
            else
                echo "Preset file does not exist."
                showUsage
            fi
            PRESET_FILE=${OPTARG}
            ;;
        l)
            # List all functions available for Preset-file
            listLibraryFunctions ${OPTARG}
            exit 0
            ;;
        n)
            # If used - logging will be disabled
            LOGGING=0
            ;;
        c)
            COMPARE=1
            ;;
        *)
            # If anything else is used, show usage
            showUsage
            ;;
    esac
done

# To do comparison or run the bootloading library function file and preset file need to be given
if [ -z ${RIDEFUNCTION_FILE} ] || [ -z ${PRESET_FILE} ]; then
    echo 'You need to provide both a ride-function file and a preset file to continue.'
    showUsage
fi

# Do compare between library function file and preset file
# Lists missing functions in either one
if [ ${COMPARE} -eq 1 ]; then
    compareFunctionsPreset ${RIDEFUNCTION_FILE} ${PRESET_FILE}
    exit 0
fi

# Do the bootstrapping according to preset file
if [ ${LOGGING} -eq 1 ]; then
    logOutput
    setupUserDefaultDirs
    executeFunctions
    setHostname
    echo '################################################################'
    pressAnyKeyToContinue
    restartSystem
else
    setupUserDefaultDirs
    executeFunctions
    setHostname
    pressAnyKeyToContinue
    restartSystem
fi

exit 0
