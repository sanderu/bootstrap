#!/bin/bash

setupUserDefaultDirs() {
    # Create user's bin, git and Documents directories
    cd ${MYUSERDIR}
    mkdir -p git > /dev/null
    chown ${MYUSER}:${MYUSER} git
    mkdir -p bin > /dev/null
    chown ${MYUSER}:${MYUSER} bin
    mkdir -p Documents > /dev/null
    chown ${MYUSER}:${MYUSER} Documents
}

setHostname() {
    # Set hostname
    echo "Current hostname is ${HOSTNAME}"
    read -r -p 'Enter NEW hostname (or <Enter> to continue unchanged): ' NEWHOSTNAME
    if [ ! -z ${NEWHOSTNAME} ] ; then
        hostnamectl set-hostname --static "${NEWHOSTNAME}"
        echo "New hostname is ${NEWHOSTNAME}"
    fi
}

pressAnyKeyToContinue() {
    read -n 1 -s -r -p 'Press any key to continue...'
}

restartSystem() {
    echo 'Rebooting now...'
    reboot now
}

# Logging is default - use -n for disabling log
logOutput() {
    touch ${LOGFILE}
    chown ${MYUSER}:${MYUSER} ${LOGFILE}
    exec >  >(tee -a "${LOGFILE}" 2>&1)

    # Insert Header in Logfile
    echo '################################################################'
    echo ''
    echo "Script: ${SCRIPTNAME}"
    echo "Command line parameters: $@"
    echo "Logfile: ${LOGFILE}"
    echo "Timestamp: $(date)"
    echo ''
}

getOSrelease() {
    if [ -f /etc/os-release ]; then
        OS=$( grep '^NAME="' /etc/os-release | awk -F '="' '{print $2}' | awk '{print $1}' | sed 's/"//g' )
        OSRELEASEVERSION=$( grep 'VERSION_ID=' /etc-osrelease | awk -F '=' '{print $2}' | cut -f 2 -d '"')
        if [ x${OS} == x'Debian' ]; then
            OSRELEASENAME=$( grep 'VERSION_CODENAME=' /etc-osrelease | awk -F '=' '{print $2}' )
        elif [ x${OS} == x'CentOS' ]; then
            OSRELEASENAME=$( awk -F 'VERSION_ID="' '{print $2}' /etc/os-release | cut -f 1 -d '"' )
        elif [ x${OS} == x'Fedora' ]; then
            OSRELEASENAME=$( awk -F 'VERSION_ID="' '{print $2}' /etc/os-release | cut -f 1 -d '"' )
        fi
    else
        OSRELEASE='N/A'
    fi
}

readPresetFile() {
    PRESETFILE=$1
    PRESETFILECONTENT=( $(awk '{print $1}' ${PRESETFILE} | grep -v '^#' | awk 'NF') )
    ACTIONS=("${ACTIONS[@]}" "${PRESETFILECONTENT[@]}")
}

executeFunctions() {
    # execute all valid functions
    echo "Performing: ${ACTIONS[@]}"
    for action in "${!ACTIONS[@]}"; do
        ENTRYTYPE=$( type -t ${ACTIONS[action]} )
        if [ x${ENTRYTYPE} == x'function' ]; then
            echo "::: ${ACTIONS[$action]} :::"
            (${ACTIONS[$action]})
        else
            echo "${action} is NOT a function - will not be executed"
            continue
        fi
        echo ''
    done
}

listLibraryFunctions() {
    RIDEFUNC_FILE=$1
    if [ -f ${RIDEFUNC_FILE} ]; then
        echo 'Following functions are available:'
        echo '----------------------------------'
        grep -E '\(\) \{|\(\)\{' ${RIDEFUNC_FILE} | cut -f1 -d '('
    else
        echo "File: ${RIDEFUNC_FILE} does not exist!"
        showUsage
    fi
}

compareFunctionsPreset() {
    RIDEFUNC_FILE=$1
    PRESETFILE=$2
    RIDEFUNCTIONS=$( grep -E '\(\) \{|\(\)\{' ${RIDEFUNC_FILE} | cut -f1 -d '(' )
    PRESETFILECONTENT=$( grep -v -e '^##' ${PRESETFILE} | sed 's/#/\n/g' | awk 'NF' )
    # Do the Compare:
    echo "Preset functions from ${PRESETFILE} functions missing in ride-function file ${RIDEFUNC_FILE}"
    for PRESET in ${PRESETFILECONTENT}; do
        case "${RIDEFUNCTIONS[@]}" in
            *"${PRESET}"*)
                #echo -e "$PRESET - \033[1;32mOK\033[0m"
                ;;
            *)
                echo -e "${PRESET} - \033[1;31mMissing\033[0m"
                ;;
        esac
    done

    echo ''
    echo "Functions from ride-function file ${RIDEFUNC_FILE} found missing in the Preset file ${PRESETFILE}:"
    for RIDEFUNC in ${RIDEFUNCTIONS}; do
        case "${PRESETFILECONTENT[@]}" in
            *"${RIDEFUNC}"*)
                #echo -e "${RIDEFUNC} - \033[1;32mOK\033[0m"
                ;;
            *)
                echo -e "${RIDEFUNC} - \033[1;31mMissing\033[0m"
                ;;
        esac
    done
}

showUsage() {
    echo "Usage: sudo ${SCRIPTNAME} [-f <ride-functions filename>] [-p <preset filename>] [-l <ride-functions filename>] [-c] [-n]"
    echo '-f    <ride-functions filename> - the ride-function file contains all the functions for installing/removing tools'
    echo '-p    <preset filename>         - the preset file contains what functions in the ride-function file to use'
    echo '-l    <ride-functions filename> - list the Install/Remove functions available in the ride-functions file'
    echo '-c    use for comparing functions in functions file and preset file'
    echo '-n    use for no logging'
    exit 1
}

