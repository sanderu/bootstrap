# bootstrap
Bootstrap Debian system - install packages after minimal install

Script requires you to run it with 'sudo'.


## bootstrap-functions.sh
This file contains all the functions called from 'bootstrap'.


## RIDE-functions file
(Remove, Install, Disable, Enable) functions.

This file contains the different actions to be performed according to wishes mentioned in preset file - lean back as it takes you for a ride.


## Preset file
Create different preset-files for different uses.

Basically file tells which options to perform when script is run.

Incomment what ever you want the script to install/remove in the preset file.

Outcomment what is not wanted.


## Usage
sudo bash bootstrap [-f <ride-functions filename>] [-p <preset filename>] [-l <ride-functions filename>] [-c] [-n]

    -f ride-functions filename  - file with functions available
    -p preset filename          - file with wishes for actions to be performed
    -l ride-functions filename  - list all functions available to put in to the preset file
    -c                          - compare functions in ride-functions file and preset file (requires both -f and -p to be set)
    -n                          - no logging

example: sudo bash bootstrap.sh -f ride-functions.sh -p default.preset

