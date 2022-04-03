#!/bin/sh

################################################################
### RIDE-functions
### Remove
### Install
### Disable
### Enable
### contains all the different functions for bootstrapping a new
### system
################################################################

################################################################
### Generic Debian ###
################################################################

UpdateDebian() {
    apt update
    apt upgrade -y
}

InstallRequired() {
    apt install -y bash-completion coreutils git gnupg python3 tar wget apt-transport-https net-tools
}

InstallShellTools() {
    apt install -y pv lsof strace
}

RemoveShellTools() {
    apt remove -y pv lsof strace
}

InstallKernelTools() {
    apt install -y linux-headers-amd64
}

RemoveKernelTools() {
    apt remove -y linux-headers-amd64
}

InstallXserver() {
    apt install -y xserver-xorg-video-intel xfonts-100dpi xfonts-75dpi xfonts-base xfonts-encodings xfonts-terminus xfonts-traditional xfonts-utils xdm xinit
}

RemoveXserver() {
    apt remove -y xserver-xorg-video-intel xfonts-100dpi xfonts-75dpi xfonts-base xfonts-encodings xfonts-terminus xfonts-traditional xfonts-utils xdm xinit
}

InstallXscreensaver() {
    apt install -y xscreensaver xscreensaver-data xscreensaver-data-extra
}

RemoveXscreensaver() {
    apt remove -y xscreensaver xscreensaver-data xscreensaver-data-extra
}

InstallAwesome() {
    apt install -y awesome awesome-extra
}
RemoveAwesome() {
    apt remove -y awesome awesome-extra
}

InstallI3() {
    apt install -y i3-wm i3lock i3status
}

RemoveI3() {
    apt remove -y i3-wm i3lock i3status
}

############################
### Database ###
############################

InstallPostgreSQLServer() {
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${OSRELEASE}-pgdg main" > /etc/apt/sources.list.d/pgdg.list
    PGDG_KEY=$( wget --quiet -O - https://www.postgresql.org/download/linux/debian/ | grep 'media/keys' | awk '{print $5}' )
    wget --quiet -O - ${PGDG_KEY} | apt-key add -
    apt update
    apt install -y postgresql-13
}

RemovePostgreSQLServer() {
    PGDG='/etc/apt/sources.list.d/pgdg.list'
    apt-key del ACCC4CF8
    apt remove -y postgresql-13
    if [ -f ${PGDG} ]; then
       rm ${PGDG}
    fi
}

InstallPostgreSQLClient() {
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${OSRELEASE}-pgdg main" > /etc/apt/sources.list.d/pgdg.list
    PGDG_KEY=$( wget --quiet -O - https://www.postgresql.org/download/linux/debian/ | grep 'media/keys' | awk '{print $5}' )
    wget --quiet -O - ${PGDG_KEY} | apt-key add -
    apt update
    apt install -y postgresql-client-13
}

RemovePostgreSQLClient() {
    PGDG='/etc/apt/sources.list.d/pgdg.list'
    apt-key del ACCC4CF8
    apt remove -y postgresql-client-13
    if [ -f ${PGDG} ]; then
        rm ${PGDG}
    fi
}


############################
### Forensic tools ###
############################

InstallForensicImageTools() {
    apt install -y ewf-tools sleuthkit python3-tsk
}

RemoveForensicImageTools() {
    apt remove -y ewf-tools sleuthkit python3-tsk
}

InstallFTKImager() {
    FTKURL='https://ad-zip.s3.amazonaws.com/ftkimager.3.1.1_ubuntu64.tar.gz'
    FTKPKG=$( basename ${FTKURL} )
    cd ${DOWNLOADDIR}
    wget -q --show-progress ${FTKURL}
    CHKSUM=$( md5sum ${FTKPKG} | awk '{print $1}' )
    if [ x"${CHKSUM}" == x'a1eb0a4f1d09233a809b531519c8735f' ]; then
        tar -xzvf ${FTKPKG} -C /usr/bin/
        chmod +x /usr/bin/ftkimager
    else
        echo "FTKImager checksum does not match vendorprovided checksum."
    fi
    wget -q https://ad-pdf.s3.amazonaws.com/Imager%20Command%20Line%20Help.pdf -O ${MYUSERDIR}/Documents/
}

RemoveFTKImager() {
    FTKIMAGER='/usr/bin/ftkimager'
    if [ -f ${FTKIMAGER} ]; then
        rm ${FTKIMAGER}
    fi
}

InstallImagingTools() {
    apt install -y dc3dd dcfldd
}

RemoveImagingTools() {
    apt remove -y dc3dd dcfldd
}

InstallExifTool() {
    apt install -y exif exifprobe
}

RemoveExifTool() {
    apt remove -y exif exifprobe
}

InstallRecoverTools() {
    apt install -y testdisk foremost
}

RemoveRecoverTools() {
    apt remove -y testdisk foremost
}

InstallYara() {
    apt install -y yara
}

RemoveYara() {
    apt remove -y yara
}

InstallPlaso() {
    apt install -y plaso
}

RemovePlaso() {
    apt remove -y plaso
}

InstallAutopsy() {
    # Remove libtsk13 as it is incompatible with newest version of Autopsy
    apt remove -y libtsk13
    # Prerequisite for Autopsy
    apt install -y testdisk libpq5 libvhdi1 libvmdk1 libewf-dev libafflib-dev libsqlite3-dev libc3p0-java libpostgresql-jdbc-java libvmdk-dev libvhdi-dev libbfio1 libbfio-dev unzip

    # Install BellSoft Java 8
    wget -q -O - https://download.bell-sw.com/pki/GPG-KEY-bellsoft | apt-key add -
    echo 'deb [arch=amd64] https://apt.bell-sw.com/ stable main' | tee /etc/apt/sources.list.d/bellsoft.list
    apt update
    apt install -y bellsoft-java8-full

    # Set JAVA_HOME
    #NOTE: You may need to log out and back in again after setting JAVA_HOME before the Autopsy
    #      unix_setup.sh script can see the value.
    export JAVA_HOME=/usr/lib/jvm/bellsoft-java8-full-amd64
    echo 'JAVA_HOME=/usr/lib/jvm/bellsoft-java8-full-amd64' >> ${MYUSERDIR}/.bashrc

    # Get github pages for parsing:
    TMP_GITHUB_SLEUTH="${DOWNLOADDIR}/github_sleuth.html"
    wget -O ${TMP_GITHUB_SLEUTH} https://github.com/sleuthkit/sleuthkit/releases/
    TMP_GITHUB_AUTOPSY="${DOWNLOADDIR}/github_autopsy.html"
    wget -O ${TMP_GITHUB_AUTOPSY} https://github.com/sleuthkit/autopsy/releases/

    LATEST_SLEUTH_JAVA="https://github.com"$( cat ${TMP_GITHUB_SLEUTH} | grep -o -E 'href="([^"#]+)"' | grep '.deb"' | cut -f2 -d '"' | sort -r -V | awk NR==1 )
    LATEST_AUTOPSY="https://github.com"$( cat ${TMP_GITHUB_AUTOPSY} | grep -o -E 'href="([^"#]+)"' | grep '.zip"' | grep download | cut -d'"' -f2 | sort -r -V | awk NR==1 )

    # We cannot import Brian Carriers GPG key - so unable to do signature verification
    #$ gpg --search 0x0917A7EE58A9308B13D3963338AD602EC7454C8B
    #gpg: data source: https://keys.openpgp.org:443
    #(1)      1024 bit DSA key 38AD602EC7454C8B, created: 2004-03-04
    #Keys 1-1 of 1 for "0x0917A7EE58A9308B13D3963338AD602EC7454C8B".  Enter number(s), N)ext, or Q)uit > n
    #LATESTAUTOPSYSIGNATURE="${LATESTAUTOPSY}.asc"
    #LATESTVERIFIEDSIGNATURE=$(grep "GPG key" ${TMP_GITHUB_AUTOPSY} |sort -r -V | awk 'NR==1' | awk -F '>' '{print $3}' | cut -f1 -d'<')

    # Install Sleuthkit Java:
    cd ${DOWNLOADDIR}
    SLEUTH_JAVA=$( basename ${LATEST_SLEUTH_JAVA} )
    wget --quiet --show-progress ${LATEST_SLEUTH_JAVA} -O ${DOWNLOADDIR}/${SLEUTH_JAVA}
    dpkg -i ${DOWNLOADDIR}/${SLEUTH_JAVA}

    # Install Autopsy:
    AUTOPSYINSTALLER="$( basename ${LATEST_AUTOPSY} )"
    wget --quiet --show-progress ${LATEST_AUTOPSY} -O ${DOWNLOADDIR}/${AUTOPSYINSTALLER}
    #wget --quiet ${LATESTAUTOPSYSIGNATURE}

    cd ${MYUSERDIR}
    AUTOPSYSUBDIR=$( unzip -l ${DOWNLOADDIR}/${AUTOPSYINSTALLER} | awk 'NR==5' | awk '{print $4}' | cut -f 1 -d '/' )
    unzip ${DOWNLOADDIR}/${AUTOPSYINSTALLER}
    chown -R ${MYUSER}:${MYUSER} ${AUTOPSYSUBDIR}/
    chmod +x ${AUTOPSYSUBDIR}/unix_setup.sh
    if [ -d /usr/lib/jvm/bellsoft-java8-full-amd64 ]; then
        sed -i "/^TSK_VERSION=.*$/a JAVA_HOME=/usr/lib/jvm/bellsoft-java8-full-amd64" ${AUTOPSYSUBDIR}/unix_setup.sh
        su - ${MYUSER} sh -c "cd ${AUTOPSYSUBDIR} && ./unix_setup.sh"
    else
        echo 'Something has gone wrong - the bellsoft-java8-full package has not been installed correctly.'
    fi
}

RemoveAutopsy() {
    AUTOPSYBINDIR=$( find ${MYUSERDIR}/ -type f -name autopsy | xargs dirname )
    AUTOPSYINSTALLDIR=$( echo ${AUTOPSYBINDIR} | sed -e "s/\/home\/${MYUSER}\///g" | xargs dirname )
    rm -rf ${MYUSERDIR}/${AUTOPSYINSTALLDIR}
}

InstallWindowsForensicTools() {
    apt install -y dislocker fatcat galleta grokevt libevtx-utils missidentify pasco reglookup rifiuti2 scrounge-ntfs vinetto winregfs
}

RemoveWindowsForensicTools() {
    apt remove -y dislocker fatcat galleta grokevt libevtx-utils missidentify pasco reglookup rifiuti2 scrounge-ntfs vinetto winregfs
}

InstallBMCTools() {
    cd ${DOWNLOADDIR}
    git clone https://github.com/ANSSI-FR/bmc-tools.git
    cp bmc-tools/bmc-tools.py /usr/local/bin/
    chmod +x /usr/local/bin/bmc-tools.py
}

RemoveBMCTools() {
    if [ -f /usr/local/bin/bmc-tools.py ]; then
        rm /usr/local/bin/bmc-tools.py
    fi
}

InstallVolatility() {
    # Volatility requires python2.6+ (but not python3)
    apt install -y python python-crypto python-distorm3
    if [ ! -d volatility ]; then
        cd ${MYUSERDIR}
        git clone https://github.com/volatilityfoundation/volatility.git
        cd volatility
        python setup.py build
        python setup.py install
        python setup.py sdist
    else
        rm -rf ${MYUSERDIR}/volatility
        InstallVolatility
    fi
}

RemoveVolatility() {
    if [ -d ${MYUSERDIR}/volatility ]; then
        rm -rf ${MYUSERDIR}/volatility
    fi
    if [ -d /usr/local/lib/python2.7/volatility ]; then
        rm -rf /usr/local/lib/python2.7/volatility
    fi
    if [ -f /usr/local/lib/python2.7/volatility-2.6.1.egg-info]; then
        rm /usr/local/lib/python2.7/volatility-2.6.1.egg-info
    fi
    if [ -f /usr/local/bin/vol.py ]; then
        rm /usr/local/bin/vol.py
    fi
}

InstallVolatility3() {
    # Volatility3 requires python3.6+
    apt install -y python3-pefile python3-yara python3-capstone python3-pycryptodome python3-jsonschema python3-snappy

    # Get Volatility3 tarball from Github
    wget -O ${DOWNLOADDIR}/latest_volatility_vers.html https://github.com/volatilityfoundation/volatility3/releases/latest
    LATEST_VERSION=$( grep tar.gz ${DOWNLOADDIR}/latest_volatility_vers.html | head -n1 | awk -F 'href="view-source:' '{print $2}' | awk -F '">' '{print $1}' )
    wget -O ${DOWNLOADDIR}/volatility3.tar.gz ${LATEST_VERSION}
    VOLATILITY_VERSION=$( tar -tzvf ${DOWNLOADDIR}/volatility3.tar.gz | head -n1 | awk '{print $6}' | cut -f1 -d '/' )

    cd ${MYUSERDIR}
    if [ ! -d volatility3 ]; then
        tar -xzvf ${DOWNLOADDIR}/volatility3.tar.gz
        mv ${VOLATILITY_VERSION} volatility3
        ln -s ${MYUSERDIR}/volatility3/vol.py /usr/local/bin/vol.py
    else
        rm -rf ${MYUSERDIR}/volatility3
        InstallVolatility3
    fi
}

RemoveVolatility3() {
    apt remove -y python3-pefile python3-yara python3-capstone python3-pycryptodome python3-jsonschema python3-snappy
    if [ -d ${MYUSERDIR}/volatility3 ]; then
        rm -rf ${MYUSERDIR}/volatility3
    fi
    if [ -f /usr/local/bin/vol.py ]; then
        rm /usr/local/bin/vol.py
    fi
}

InstallGhidra() {
    if [ ! -d ${MYUSERDIR}/ghidra ]; then
        apt install -y curl openjdk-11-jdk unzip wget
        LATEST=$( curl -S https://github.com/NationalSecurityAgency/ghidra/releases/latest | awk -F '<a href="' '{print $2}' | awk -F '">' '{print $1}' )
        LATEST_VERS=$( wget ${LATEST} -O - | grep ghidra_ | awk -F '"px-1 text-bold">' '{print $2}' | awk -F '<' '{print $1}' )
        ZIP_FILE=$( echo ${LATEST}/$( echo ${LATEST_VERS} ) | sed -e 's/tag/download/g' )
        wget ${ZIP_FILE} -O ${DOWNLOADDIR}/ghidra.zip
        cd ${MYUSERDIR}
        unzip ${DOWNLOADDIR}/ghidra.zip
        mv ghidra_* ghidra
    else
        rm -rf ${MYUSERDIR}/ghidra
        InstallGhidra
    fi
}

RemoveGhidra() {
    apt remove -y openjdk-11-jdk unzip
    if [ -d ${MYUSERDIR} ]; then
        rm ${MYUSERDIR}/ghidra
    fi
}


###############################
### Basic Tools and support ###
###############################

InstallExfatSupport() {
    apt install -y exfat-fuse exfat-utils
}

RemoveExfatSupport() {
    apt remove -y exfat-fuse exfat-utils
}

InstallPackagingTools() {
    apt install -y p7zip-full unrar
}

RemovePackagingTools() {
    apt remove -y p7zip-full unrar
}

InstallBasicEditor() {
    apt install -y vim
    update-alternatives --set editor '/usr/bin/vim.basic'
    sed -i 's/"syntax on/syntax on/' /etc/vim/vimrc
    sed -i 's/"set background=dark/set background=dark/' /etc/vim/vimrc
}

RemoveBasicEditor() {
    apt remove -y vim
}

InstallPythonTools() {
    apt install -y python3-pip python3-virtualenv
}

RemovePythonTools() {
    apt remove -y python3-pip python3-virtualenv
}

InstallTerminator() {
    apt install -y terminator
}

RemoveTerminator() {
    apt remove -y terminator
}

InstallLess() {
    apt install -y less
}

RemoveLess() {
    apt remove -y less
}

InstallHexEditor() {
    apt install -y dhex hexer wxhexeditor
}

RemoveHexEditor() {
    apt remove -y dhex hexer wxhexeditor
}

################################################################
### Accessories ###
################################################################

InstallKeepassXC() {
    apt install -y keepassxc
}

RemoveKeepassXC() {
    apt remove -y keepassxc
}


################################################################
### Programming Tools ###
################################################################

InstallAtomEditor() {
    echo 'deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main' > /etc/apt/sources.list.d/atom.list
    wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | apt-key add -
    apt update
    apt install -y atom

    if [ ! -d ${MYUSERDIR}/.atom ] ; then # atom user library does ot exist
        mkdir ${MYUSERDIR}/.atom
        chown ${MYUSER}:${MYUSER} ${MYUSERDIR}/.atom
    fi

    if [ ! -f ${MYUSERDIR}/.atom/config.cson ] ; then # coffee file is not created yet
        touch ${MYUSERDIR}/.atom/config.cson
        chown ${MYUSER}:${MYUSER} ${MYUSERDIR}/.atom/config.cson
    fi

    # Disable both metrics package and disallow sending telemetry data
    cat << EOF > ${MYUSERDIR}/.atom/config.cson
"*":
  core:
    disabledPackages: [
      "metrics"
    ]
    telemetryConsent: "no"
  "exception-reporting":
    userId: "00000000-0000-0000-0000-000000000000"
EOF

}

RemoveAtomEditor() {
    rm /etc/apt/sources.list.d/atom.list
    APTKEY=$( apt-key list --fingerprint packagecloud.io | grep -A1 pub | tail -n1 | awk '{print $(NF-1)$(NF)}' )
    apt-key del ${APTKEY}
    apt remove -y atom

    if [ -d ${MYUSERDIR}/.atom ] ; then # atom user library does ot exist
        rm -rf ${MYUSERDIR}/.atom
    fi
}

InstallAtomPlugins() {
    if ( command -v atom > /dev/null 2>&1 ) ; then
        su - ${MYUSER} sh -c 'apm install minimap'
        su - ${MYUSER} sh -c 'apm install line-ending-converter'
        su - ${MYUSER} sh -c 'apm install git-plus'
        su - ${MYUSER} sh -c 'apm install atom-beautify'
        su - ${MYUSER} sh -c 'apm install autoclose-html'
        su - ${MYUSER} sh -c 'apm install ask-stack'
        su - ${MYUSER} sh -c 'apm install open-recent'
        su - ${MYUSER} sh -c 'apm install compare-files'
        su - ${MYUSER} sh -c 'apm install language-powershell'
        su - ${MYUSER} sh -c 'apm install language-python'
        su - ${MYUSER} sh -c 'apm install markdown-preview-enhanced'
    fi
}

RemoveAtomPlugins() {
    if ( command -v atom > /dev/null 2>&1 ) ; then
        su - ${MYUSER} sh -c 'apm uninstall minimap'
        su - ${MYUSER} sh -c 'apm uninstall line-ending-converter'
        su - ${MYUSER} sh -c 'apm uninstall git-plus'
        su - ${MYUSER} sh -c 'apm uninstall atom-beautify'
        su - ${MYUSER} sh -c 'apm uninstall autoclose-html'
        su - ${MYUSER} sh -c 'apm uninstall ask-stack'
        su - ${MYUSER} sh -c 'apm uninstall open-recent'
        su - ${MYUSER} sh -c 'apm uninstall compare-files'
        su - ${MYUSER} sh -c 'apm uninstall language-powershell'
        su - ${MYUSER} sh -c 'apm uninstall language-python'
        su - ${MYUSER} sh -c 'apm uninstall markdown-preview-enhanced'
    fi
}

DisableAtomTelemetry(){
    if [ ! -d ${MYUSERDIR}/.atom ] ; then # atom user library does ot exist
        mkdir ${MYUSERDIR}/.atom
        chown ${MYUSER}:${MYUSER} ${MYUSERDIR}/.atom
    fi

    if [ ! -f ${MYUSERDIR}/.atom/init.coffee ] ; then # coffee file is not created yet
        touch ${MYUSERDIR}/.atom/init.coffee
    fi

    # This should be rewritten to use sed
    if [ -z $( grep "'core.telemetryConsent', 'no'" ${MYUSERDIR}/.atom/init.coffee ) ] ; then # the telemetry line is not present
        echo "atom.config.set 'core.telemetryConsent', 'no'" >> ${MYUSERDIR}/.atom/init.coffee
    fi
}

EnableAtomTelemetry(){
    if [ ! -d ${MYUSERDIR}/.atom ] ; then # atom user library does ot exist
        mkdir ${MYUSERDIR}/.atom
        chown ${MYUSER}:${MYUSER} ${MYUSERDIR}/.atom
    fi

    if [ ! -f ${MYUSERDIR}/.atom/init.coffee ] ; then # coffee file is not created yet
        touch ${MYUSERDIR}/.atom/init.coffee
    fi

    # This should be rewritten to use sed
    if [ -z $( grep "telemetryConsent', 'no'" ${MYUSERDIR}/.atom/init.coffee ) ] ; then # the telemetry line is not present
        echo "atom.config.set 'core.telemetryConsent', 'limited'" >> ${MYUSERDIR}/.atom/init.coffee
    fi

    su - ${MYUSER} sh -c atom &
    sleep 15
    pkill atom

    rm ${MYUSERDIR}/.atom/init.coffee
}

InstallVisualStudioCode() {
    if [ ! -f /etc/apt/trusted.gpg.d/microsoft.gpg ]; then
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
        chmod 644 /etc/apt/trusted.gpg.d/microsoft.gpg
    fi
    echo 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main' > /etc/apt/sources.list.d/vscode.list

    #Then update the package cache and install the package using:
    apt update
    apt install -y code # or code-insiders
}

RemoveVisualStudioCode() {
    apt remove -y code
    rm /etc/apt/sources.list.d/vscode.list
}

################################################################
### Communication ###
################################################################

InstallChatProgs() {
    apt install -y hexchat hexchat-otr finch pidgin pidgin-otr
}

RemoveChatProgs() {
    apt remove -y hexchat hexchat-otr finch pidgin pidgin-otr
}

InstallTeams() {
    if [ ! -f /etc/apt/trusted.gpg.d/microsoft.gpg ]; then
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
        chmod 644 /etc/apt/trusted.gpg.d/microsoft.gpg
    fi
    echo 'deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main' > /etc/apt/sources.list.d/teams.list

    apt update
    apt install -y teams
}

RemoveTeams() {
    apt remove -y teams
    rm /etc/apt/sources.list.d/teams.list
}

InstallEmailProgs() {
    apt install -y mutt ssmtp mairix
}

RemoveEmailProgs() {
    apt remove -y mutt ssmtp mairix
}

################################################################
### NetworkConfiguration ###
################################################################

EnableMulticastDNS() {
    # change /etc/nsswitch.conf file back to default to mulicast dns
    # Original #hosts line will be enabled and current hosts line will be disabled

    NSSWITCHFILE=/etc/nsswitch.conf

    OLDDNSLINE=$( cat ${NSSWITCHFILE} | grep -in '^#hosts' )

    if [ ! -z $OLDDNSLINE ] ; then # the old DNS line exists and can be reactivated
        DNSLINENO=$( cat ${NSSWITCHFILE} | grep -in ^hosts | cut -c1-2 )
        sed -i ${DNSLINENO}'d' ${NSSWITCHFILE}
        sed -i 's/^#hosts/hosts/g' ${NSSWITCHFILE}
    fi
}

DisableMulticastDNS() {
    # change /etc/nsswitch.conf file to disable mulicast dns and use dns first
    # Original line will be left in the file with a # in the beginning of the line
    # multicast dns has to be disabled to resolve .local dns names (like in Active Directory domains called eg. contoso.local)
    NSSWITCHFILE=/etc/nsswitch.conf
    DNSLINENO=$( cat ${NSSWITCHFILE} | grep -in ^hosts | cut -c1-2 )
    NEWLINENO=$((${DNSLINENO}))

    NOMULTIDNSLINE=$( cat ${NSSWITCHFILE} | grep -i ^hosts | sed 's/mdns4_minimal //g' | sed 's/dns //g' | sed 's/files/files dns/g' )

    sed -i 's/^hosts/#hosts/g' ${NSSWITCHFILE}
    sed -i "${NEWLINENO} a ${NOMULTIDNSLINE}" ${NSSWITCHFILE} # Discard Multicast DNS
}

InstallNetworkTools() {
    apt install -y tcpdump wireshark nmap macchanger flow-tools tcpreplay
}

RemoveNetworkTools() {
    apt remove -y tcpdump wireshark nmap macchanger flow-tools tcpreplay
}

InstallNetCommsTools() {
    apt install -y minicom socat
}

RemoveNetCommsTools() {
    apt remove -y minicom socat
}

InstallWindowsNetCommsTools() {
    apt install -y putty remmina
}

RemoveWindowsNetCommsTools() {
    apt remove -y putty remmina
}

InstallOpenconnectVPN() {
    apt install -y openconnect
}

RemoveOpenconnectVPN() {
    apt remove -y openconnect
}

InstallSSHserver() {
    apt install -y openssh-server
}

RemoveSSHserver() {
    apt remove -y openssh-server
}

InstallSSHclient() {
    apt install -y openssh-client
}

RemoveSSHclient() {
    apt remove -y openssh-client
}

InstallOpenVPN() {
    apt install -y openvpn3
}

RemoveOpenVPN() {
    apt remove -y openvpn3
}

InstallWireGuard() {
    apt install -y wireguard-dkms wireguard-tools
}

RemoveWireGuard() {
    apt remove -y wireguard-dkms wireguard-tools
}


################################################################
### Productivity Tools ###
################################################################

InstallDia() {
    apt install -y dia
}

RemoveDia() {
    apt remove -y dia
}

InstallWine() {
    apt install -y wine
}

RemoveWine() {
    apt remove -y wine
}

InstallLibreOffice() {
    apt install -y libreoffice
}

RemoveLibreOffice() {
    apt remove -y libreoffice
}

InstallJupyter() {
    apt install -y jupyter-notebook markdown
}

RemoveJupyter() {
    apt remove -y jupyter-notebook markdown
}

################################################################
### Supporting scripts ###
################################################################

InstallTecmintMonitorSh() {
    # A Shell Script to Monitor Network, Disk Usage, Uptime, Load Average and RAM Usage in Linux
    # https://www.tecmint.com/linux-server-health-monitoring-script/
    # Irrelevant if using i3-status
    TECMINTMONSCRIPT='http://tecmint.com/wp-content/scripts/tecmint_monitor.sh'
    wget -q --show-progress -O /usr/local/bin/tecmint_monitor.sh ${TECMINTMONSCRIPT}
    chmod 755 /usr/local/bin/tecmint_monitor.sh
}

RemoveTecmintMonitorSh() {
    # Remove script
    rm /usr/local/bin/tecmint_monitor.sh
}

InstallMozExtensionMgr() {
    # Script for searching and installing Firefox extensions
    # http://www.bernaerts-nicolas.fr/linux/74-ubuntu/271-ubuntu-firefox-thunderbird-addon-commandline
    if [ ! -d ${MYUSERDIR}/git/ubuntu-scripts ]; then
        su - ${MYUSER} sh -c "cd ${MYUSERDIR}/git ; git clone https://github.com/NicolasBernaerts/ubuntu-scripts"
    fi

    # Fix missing executable flag when fetched from repo
    chmod 755 "/home/${MYUSER}/git/ubuntu-scripts/mozilla/firefox-extension-manager"

    # create symlinks
    ln -fs "/home/${MYUSER}/git/ubuntu-scripts/mozilla/firefox-extension-manager" '/usr/local/bin/firefox-extension-manager'
    ln -fs "/home/${MYUSER}/git/ubuntu-scripts/mozilla/mozilla-extension-manager" '/usr/local/bin/mozilla-extension-manager'
}

RemoveMozExtensionMgr() {
    rm -rf ${MYUSERDIR}/git/ubuntu-scripts # remove github repo clone
    rm '/usr/local/bin/firefox-extension-manager'  &>/dev/null # remove symlink
    rm '/usr/local/bin/mozilla-extension-manager'  &>/dev/null # remove symlink
}


################################################################
###### Web Browsers ###
################################################################

InstallChromium() {
    # Install Chromium browser
    apt install -y chromium
}

RemoveChromium() {
    # Remove Chromium browser
    apt remove -y chromium
}

InstallFirefoxESR() {
    # Install Firefox-esr browser
    apt install -y firefox-esr
}

RemoveFirefoxESR() {
    # Remove Firefox-esr browser
    apt remove -y firefox-esr
}

SetFirefoxESRPreferences() {
    #Creates config files for firefox

    FIREFOXINSTALLDIR='/usr/lib/firefox-esr'
    FIREFOXPREFFILE=${FIREFOXINSTALLDIR}'/mozilla.cfg'

    echo '//
pref("network.dns.disablePrefetch", true);
pref("network.prefetch-next", false);
pref("network.cookie.cookieBehavior", 1);
pref("network.cookie.lifetimePolicy", 2);
pref("browser.rights.3.shown", true);
pref("browser.startup.homepage_override.mstone","ignore");
pref("browser.newtabpage.introShown", false);
pref("browser.usedOnWindows10", true);
pref("browser.startup.homepage", "about:blank");
pref("browser.newtabpage.pinned", "about:blank");
pref("datareporting.healthreport.service.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("startup.homepage_welcome_url.additional", "about:blank");
pref("toolkit.crashreporter.enabled", false);
pref("toolkit.telemetry.prompted", 2);
pref("toolkit.telemetry.rejected", true);
pref("toolkit.telemetry.reportingpolicy.firstRun", false);
pref("services.sync.enabled", false);
pref("media.navigator.enabled", false);
pref("media.peerconnection.enabled", false);
pref("privacy.resistFingerprinting", true);
pref("privacy.trackingprotection.fingerprinting.enabled", true);
pref("privacy.trackingprotection.cryptomining.enabled", true);
pref("privacy.firstparty.isolate", true);
pref("privacy.trackingprotection.enabled", true);
pref("geo.enabled", false);
pref("webgl.disabled", true);
pref("dom.event.clipboardevents.enabled", false);
pref("extensions.pocket.enabled", false);' > ${FIREFOXPREFFILE}

    # Create the autoconfig.js file (enables preferences)
    FIREFOXAUTOCONFIG=${FIREFOXINSTALLDIR}'/defaults/pref/autoconfig.js'
    echo 'pref("general.config.obscure_value", 0);
pref("general.config.filename", "mozilla.cfg");' > ${FIREFOXAUTOCONFIG}

    # Create the override.ini file (disables Migration Wizard)
    FIREFOXOVERRIDEFILE=${FIREFOXINSTALLDIR}'/browser/override.ini'
    echo '[XRE]
EnableProfileMigrator=false' > ${FIREFOXOVERRIDEFILE}

}

UnsetFirefoxESRPreferences() {
    #Creates config files for firefox

    FIREFOXINSTALLDIR=/usr/lib/firefox-esr/
    FIREFOXPREFFILE=${FIREFOXINSTALLDIR}'mozilla.cfg'
    FIREFOXAUTOCONFIG=${FIREFOXINSTALLDIR}'defaults/pref/autoconfig.js'
    FIREFOXOVERRIDEFILE=${FIREFOXINSTALLDIR}'browser/override.ini'
    if [ -f ${FIREFOXPREFFILE} ]; then
        rm ${FIREFOXPREFFILE}
    fi
    if [ -f ${FIREFOXAUTOCONFIG} ]; then
        rm ${FIREFOXAUTOCONFIG}
    fi
    if [ -f ${FIREFOXOVERRIDEFILE} ]; then
        rm ${FIREFOXOVERRIDEFILE}
    fi
}

# Firefox Quantum:
#pref("datareporting.policy.dataSubmissionPolicyAcceptedVersion", 2);
#pref("datareporting.policy.dataSubmissionPolicyNotifiedTime", "9000000000000");


InstallFirefoxLatest() {
    # Install latest Firefox browser
    wget -O ${DOWNLOADDIR}/ff_ver.html https://www.mozilla.org/en-US/firefox/notes/
    NEWEST_VER=$( grep '<title>' ${DOWNLOADDIR}/ff_ver.html | awk '{print $2}' | cut -f1 -d ',' )
    if [ -f ${MYUSERDIR}/firefox/application.ini ]; then
        CURRENT_VER=$( grep '^Version' ${MYUSERDIR}/firefox/application.ini | awk -F '=' '{print $2}' | cut -f 1 -d ',' )
    else
        CURRENT_VER='N/A'
    fi
    if [ x"${NEWEST_VER}" != x"${CURRENT_VER}" ]; then
        FF_URL='https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US'
        OUTPUTFILE='/tmp/FF-latest.tar.bz2'
        wget ${FF_URL} -O ${OUTPUTFILE}
        su - ${MYUSER} sh -c "tar -xjvf ${OUTPUTFILE}"
    fi
}

RemoveFirefoxLatest() {
    if [ -f ${MYUSERDIR}/firefox ]; then
        rm -rf ${MYUSERDIR}/firefox
    fi
}

InstallOpera() {
    echo 'deb https://deb.opera.com/opera-stable/ stable non-free' > /etc/apt/source.list.d/opera-stable.list
    wget -qO - https://deb.opera.com/archive.key | apt-key add -
    apt update
    apt install -y opera-stable
}

RemoveOpera() {
    apt remove -y opera-stable
    if [ -f /etc/apt/sources.list.d/opera-stable.list ]; then
        rm /etc/apt/sources.list.d/opera-stable.list
    fi
}

InstallVivaldi() {
    # Install prerequisites
    apt install -y libappindicator3-1 libdbusmenu-glib4 libdbusmenu-gtk3-4 libindicator3-7

    echo 'deb http://repo.vivaldi.com/stable/deb/ stable main' > /etc/apt/sources.list.d/vivaldi.list
    wget -qO - https://repo.vivaldi.com/stable/linux_signing_key.pub | apt-key add -
    apt update
    apt install -y vivaldi-stable
}

RemoveVivaldi() {
    apt remove -y vivaldi-stable
    if [ -f /etc/apt/sources.list.d/vivaldi.list ]; then
        rm /etc/apt/sources.list.d/vivaldi.list
    fi
}

################################################################
###### Multimedia ###
################################################################

InstallSpotifyClient() {
    # Install Spotify gpg-key
    wget https://www.spotify.com/us/download/linux/ -O /tmp/spotify_dl_site.html
    APTKEY=$( awk -F 'curl -sS ' '{print $2}' /tmp/spotify_dl_site.html | awk -F '|' '{print $1}' | grep -v ^$ )
    curl -sS ${APTKEY} | apt-key add -
    echo 'deb http://repository.spotify.com stable non-free' > /etc/apt/sources.list.d/spotify.list

    # Install Spotify client
    apt update
    apt install -y spotify-client
}

RemoveSpotifyClient() {
    # remove Spotify client
    SPOTIFYREPO=/etc/apt/sources.list.d/spotify.list
    if [ -f ${SPOTIFYREPO} ]; then
        rm ${SPOTIFYREPO}
    fi
    APTKEY=$( apt-key list --fingerprint spotify.com | grep -A1 pub | tail -n1 | awk '{print $(NF-1)$(NF)}' )
    if [ ! -z ${APTKEY} ]; then
        apt-key del ${APTKEY}
    fi
    apt remove -y spotify-client
}

InstallVLCPlayer() {
    # install VLC player
    apt install -y vlc
}

RemoveVLCPlayer() {
    # remove VLC player
    apt remove -y vlc
}

InstallAudaciousPlayer() {
    apt install -y audacious
}

RemoveAudaciousPlayer() {
    apt remove -y audacious
}

InstallClementinePlayer() {
    apt install -y clementine gstreamer-plugins-bad
}

RemoveClementinePlayer() {
    apt remove -y clementine gstreamer-plugins-bad
}

InstallPulseAudioEq() {
    apt install -y pulseaudio
}

RemovePulseAudioEq() {
    apt remove -y pulseaudio
}

InstallYouTubeDownloader() {
    # install Youtube Downloader
    apt install -y youtube-dl
}

RemoveYouTubeDownloader() {
    # remove Youtube Downloader
    apt remove -y youtube-dl
}

InstallGIMP() {
    apt install -y gimp
}

RemoveGIMP() {
    apt remove -y gimp
}

InstallHandBrake() {
    # install DVD ripper & videotranscoder: handbrake
    apt install -y handbrake-cli
}

RemoveHandBrake() {
    apt remove -y handbrake-cli
}

################################################################
### Miscellaneous tweaks and installs  ###
################################################################
InstallQemuKVM() {
    # Install KVM on host
    apt install -y qemu-kvm libvirt-clients libvirt-daemon-system
    adduser ${MYUSER} libvirt
}

RemoveQemuKVM() {
    apt remove -y qemu-kvm libvirt-clients libvirt-daemon-system
}

InstallVMtoolsOnVM() {
    # if a virtual machine, install open-vm-tools
    # for more virtualization vendors check here http://unix.stackexchange.com/questions/89714/easy-way-to-determine-virtualization-technology
    if [ $( dmidecode -s system-product-name | grep -i VMware | wc -l ) -ne 0 ] ; then
        apt install -y open-vm-tools
    fi
}

RemoveVMtoolsOnVM() {
    # if a virtual machine, and open-vm-tools are installed, remove them
    if [ $( dmidecode -s system-product-name | grep -i VMware | wc -l ) -ne 0 ] ; then
        dpkg -l | grep open-vm-tools && apt remove -y open-vm-tools
    fi
}


################################################################
### 3rd party applications ###
################################################################
InstallVMwareWorkstation() {
    # Starting with prerequisites
    apt install -y linux-headers-amd64 libaio1 libpcsclite1 gcc make

    # download and install vmware workstation
    # if serialnumberfile is sourced with script, it can autoadd serial number
    FAKE_USERAGENT='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0'
    VMWAREURL='https://www.vmware.com/go/getworkstation-linux'
    BINARYURL=$( curl -I ${VMWAREURL} --user-agent "${FAKE_USERAGENT}" | grep Location | cut -d ' ' -f2 ) # Full URL to binary installer"
    BINARYFILENAME="${BINARYURL##*/}" # Filename of binary installer
    NEWESTVMWAREVERSION=$( echo ${BINARYURL} | cut -d '-' -f4 ) # In the format XX.XX.XX
    MAJORVERSION=$( echo ${NEWESTVMWAREVERSION} | cut -d '.' -f1) # In the format XX
    SERIAL="VMWARESERIAL${MAJORVERISION}"
    CURRENTVERSION=''

    if [ $( which vmware ) ]; then
        CURRENTVERSION=$( vmware --version | awk '{print $3}' )
    fi

    if [ x${NEWESTVMWAREVERSION} != x${CURRENTVERSION} ]; then
        cd ${DOWNLOADDIR}
        wget --content-disposition -N -q --show-progress ${VMWAREURL} # Overwrite file, quiet
        chmod +x ${BINARYFILENAME}
        ./${BINARYFILENAME} --required --console --eulas-agreed #

        # Add serial number to VMWare Workstation Pro if you have it
        read -r -p "${1:-Do you have a serial number for VMWare Workstation Pro?  [y/n]} " -n 1  RESPONSE
        if [[ ${RESPONSE} =~ ^[Yy]$ ]] ; then # if NOT yes then exit
            read -r -p "${1:-Enter the serial number for VMware Workstation Pro now:} " -n 30  ASKSERIAL
            if [[ ${ASKSERIAL} =~ ^[0-9A-Z]{5}-[0-9A-Z]{5}-[0-9A-Z]{5}-[0-9A-Z]{5}-[0-9A-Z]{5}$ ]] ; then # if NOT yes then exit
                SERIAL=${ASKSERIAL}
            fi
        fi
        /usr/lib/vmware/bin/vmware-vmx --new-sn ${SERIAL}

        # Compile all kernel modules and install
        vmware-modconfig --console --install-all

        # enable 3D acceleration in VMware Workstation
        if [ ! -d ${MYUSERDIR}/.vmware ] ; then
            mkdir ${MYUSERDIR}/.vmware
            chown ${MYUSER}:${MYUSER} ${MYUSERDIR}/.vmware
        fi
        su - ${MYUSER} sh -c "touch ${MYUSERDIR}/.vmware/preferences"
        su - ${MYUSER} sh -c 'echo "mks.gl.allowBlacklistedDrivers = TRUE" >> '"${MYUSERDIR}/.vmware/preferences"
    else
        echo 'You already have the latest version installed.'
    fi
}

RemoveVMwareWorkstation() {
    vmware-installer --uninstall-product=vmware-workstation
}

InstallPowerShell() {
    if [ ! -f /etc/apt/trusted.gpg.d/microsoft.gpg ]; then
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
        chmod 644 /etc/apt/trusted.gpg.d/microsoft.gpg
    fi
    DEBVERSIONNAME=$( grep VERSION_CODENAME /etc/os-release | awk -F '=' '{print $2}' )
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-${DEBVERSIONNAME}-prod ${DEBVERSIONNAME} main" > /etc/apt/sources.list.d/powershell.list

    apt update
    apt install -y powershell
}

RemovePowerShell() {
    apt remove -y powershell
    rm /etc/apt/sources.list.d/powershell.list
}


################################################################
### Security related ###
################################################################
InstallAIDE() {
    apt install -y aide
}

RemoveAIDE() {
    apt remove -y aide
}

InstallClamAV() {
    apt install -y clamav
}

RemoveClamAV() {
    apt remove -y clamav
}

InstallLynis() {
    apt install -y lynis
}

RemoveLynis() {
    apt remove -y lynis
}

InstallAuditd() {
    apt install -y auditd
    wget -O /etc/audit/rules.d/audit.rules https://raw.githubusercontent.com/Neo23x0/auditd/master/audit.rules
    augenrules
}

RemoveAuditd() {
    apt remove -y auditd
}

InstallSELinux() {
    apt install -y selinux-basics selinux-policy-default selinux-policy-dev selinux-utils
    selinux-activate
}

RemoveSELinux() {
    apt remove -y selinux-basics selinux-policy-default selinux-policy-dev selinux-utils
    if [ -f /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=permissive' /etc/selinux/config
    fi
}


################################################################
### Encryption Functions ###
################################################################

AddExtraLUKSpasswords() {
    # Add extra password for LUKS partition

    LUKSDEVICES=$( blkid -o list | grep 'LUKS' | cut -d ' ' -f1 )

    for DEVICE in ${LUKSDEVICES}; do
        PARTITION=${DEVICE##*/}
        if ( cryptsetup isLuks ${DEVICE} ) ; then
            echo "Add password for ${PARTITION}..."
            cryptsetup luksAddKey ${DEVICE}
        fi
    done
}

EncryptUnpartitionedDisks() {
    # Reclaim and encrypt disks without partitions (that are not already encrypted using LUKS)
    # BE AWARE that using this function might lead to dataloss - especially if you are using third party encrypting tools.
    # Use this function carefully and understand what is it doing before ativating it.

    MOUNTBASE=/mnt

    DISKS=$( lsblk -l | grep disk | awk '{print $1}' ) #sda, sdb
    UNPARTEDDISKS=()

    # Check for upartitioned disks & put in array
    for DISK in ${DISKS} ; do
        DISKDEVICE="/dev/${DISK}"
        PARTITIONS=$( /sbin/sfdisk -d ${DISKDEVICE} 2>&1 | grep '^/' )
        #Check if DISKDEVICE has 0 partitions and is not a LUKS device itself
        if [[ -z ${PARTITIONS} ]] ; then
              cryptsetup isLuks ${DISKDEVICE} || UNPARTEDDISKS+=(${DISKDEVICE})
        fi
    done

    for DISKDEVICE in ${UNPARTEDDISKS} ; do

        read -r -p "${1:-You are about to remove ALL DATA on $DISKDEVICE. Do you want to proceed?  [y/n]} " -n 1  RESPONSE
        if [[ ! ${RESPONSE} =~ ^[Yy]$ ]] ; then # if NOT yes then exit
            [[ "$0" = "${BASH_SOURCE}" ]] && exit 1 || return 1 # exit from shell or function but not interactive shell
        fi

        echo "Removing partition table on ${DISKDEVICE} and creating new partition"


        # to create the partitions programatically (rather than manually)
        # we're going to simulate the manual input to fdisk
        # The sed script strips off all the comments so that we can
        # document what we're doing in-line with the actual commands
        # Note that a blank line (commented as "default" will send a empty
        # line terminated with a newline to take the fdisk default.
        sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${DISKDEVICE}
  g # Create a new GPT partition table
  n # new partition
  1 # partition number 1
    # default - start at beginning of disk
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
EOF

        NEWPARTITION=$( /sbin/sfdisk -d ${DISKDEVICE} 2>&1 | grep '^/' | awk '{print $1}' )
        echo "About to encrypted content of ${NEWPARTITION}"
        cryptsetup -y -v luksFormat ${NEWPARTITION}
        cryptsetup isLuks ${DISKDEVICE} && echo "Encryption of ${DISKDEVICE} was a success"
        HDDUUID=$( cryptsetup luksUUID ${NEWPARTITION} )
        LUKSNAME="luks-${HDDUUID}"
        DEVICENAME=${NEWPARTITION##*/}

        echo 'Opening encrypted device and creating ext4 filesystem'
        cryptsetup luksOpen ${NEWPARTITION} ${LUKSNAME}
        mkfs.ext4 /dev/mapper/${LUKSNAME}
        MOUNTPOINT=${MOUNTBASE}/${HDDUUID}
        mkdir -p ${MOUNTPOINT}
        mount /dev/mapper/${LUKSNAME} ${MOUNTPOINT}
        chmod 755 ${MOUNTPOINT}
        chown ${MYUSER}:${MYUSER} ${MOUNTPOINT}

        # rotate keyfile
        KEYFILE=/root/keyfile_${HDDUUID}
        if [ -f ${KEYFILE} ] ; then
            i=1
            NEWKEYFILE=${KEYFILE}.${i}
            while [ -f ${NEWKEYFILE} ]; do
                i=$(( ${i} + 1 ))
                NEWKEYFILE="${KEYFILE}.${i}"
            done
            mv ${KEYFILE} ${NEWKEYFILE}
        fi

        # Generate key file for LUKS encryption
        dd if=/dev/urandom of=${KEYFILE} bs=1024 count=4
        chmod 0400 ${KEYFILE}
        echo "Adding a keyfile for ${DEVICENAME} for automount configuration on ${MOUNTPOINT}"
        cryptsetup -v luksAddKey ${NEWPARTITION} ${KEYFILE}

        #Update /etc/crypttab
        echo 'Updating /etc/crypttab'
        echo "${LUKSNAME} UUID=${HDDUUID} /root/keyfile_${HDDUUID}" >> /etc/crypttab

        #Update /etc/fstab
        echo 'Updating /etc/fstab'
        echo "/dev/mapper/${LUKSNAME}   ${MOUNTPOINT}   ext4   defaults  0  2" >> /etc/fstab

    done

}

ReclaimEncryptDWUnmntPrt() {
    # Reclaim and encrypt disks with unmounted partitions
    # This function will reclaim disks with unmounted partitions - encrypted or not
    # BE AWARE! Using this function could make you loose data permanently

    MOUNTBASE=/mnt

    DISKS=$( lsblk -l | grep disk | awk '{print $1}' )
    NOTMOUNTED=$( blkid -o list | grep 'not mounted' | cut -d ' ' -f1 | sed '/^$/d' )

    if [ ! -z ${#NOTMOUNTED} ] ; then # some partitions are unmounted
        # Check for encrypted partitions & put in array

        for DISK in ${DISKS} ; do
            DISKDEVICE="/dev/${DISK}"
            NUMBEROFDEVICES=$( ls ${DISKDEVICE}? 2>/dev/null )
            NUMBEROFUNMOUNTED=$( blkid -o list | grep 'not mounted' | cut -d ' ' -f1 | sed '/^$/d' | grep ${DISKDEVICE} )
            #PARTITIONS=$( /sbin/sfdisk -d ${DISKDEVICE} 2>&1 | grep '^/' )

            #Check if DISKDEVICE has 0 partitions and is not a LUKS device itself
            if [ ${#NUMBEROFDEVICES} == ${#NUMBEROFUNMOUNTED} ] ; then
                echo "No mounted partitions found on ${DISKDEVICE}"

                read -r -p "${1:-You are about to remove ALL DATA on ${DISKDEVICE}. Do you want to proceed?  [y/n]} " -n 1  RESPONSE
                if [[ ! ${RESPONSE} =~ ^[Yy]$ ]] ; then # if NOT yes then exit
                      [[ "$0" = "${BASH_SOURCE}" ]] && exit 1 || return 1 # exit from shell or function but not interactive shell
                fi

                echo 'Cleaning and encrypting disk'

                # to create the partitions programatically (rather than manually)
                # we're going to simulate the manual input to fdisk
                # The sed script strips off all the comments so that we can
                # document what we're doing in-line with the actual commands
                # Note that a blank line (commented as "default" will send a empty
                # line terminated with a newline to take the fdisk default.
                sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${DISKDEVICE}
  g # Create a new GPT partition table
  n # new partition
  1 # partition number 1
    # default - start at beginning of disk
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
EOF

                NEWPARTITION=$( /sbin/sfdisk -d ${DISKDEVICE} 2>&1 | grep '^/' | awk '{print $1}' )
                echo "About to encrypted content of ${NEWPARTITION}"
                cryptsetup -y -v luksFormat ${NEWPARTITION}
                cryptsetup isLuks ${DISKDEVICE} && echo "Encryption of ${DISKDEVICE} was a success"
                HDDUUID=$( cryptsetup luksUUID ${NEWPARTITION} )
                LUKSNAME="luks-${HDDUUID}"
                DEVICENAME=${NEWPARTITION##*/}

                echo 'Opening encrypted device and creating ext4 filesystem'
                cryptsetup luksOpen ${NEWPARTITION} ${LUKSNAME}
                mkfs.ext4 /dev/mapper/${LUKSNAME}
                MOUNTPOINT=${MOUNTBASE}/${HDDUUID}
                mkdir -p ${MOUNTPOINT}
                mount /dev/mapper/${LUKSNAME} ${MOUNTPOINT}
                chmod 755 ${MOUNTPOINT}
                chown ${MYUSER}:${MYUSER} ${MOUNTPOINT}

                # rotate keyfile
                KEYFILE=/root/keyfile_${HDDUUID}
                if [ -f ${KEYFILE} ] ; then
                    i=1
                    NEWKEYFILE=${KEYFILE}.${i}
                    while [ -f ${NEWKEYFILE} ]; do
                        i=$(( ${i} + 1 ))
                        NEWKEYFILE="${KEYFILE}.${i}"
                    done
                    mv ${KEYFILE} ${NEWKEYFILE}
                fi

                # Generate key file for LUKS encryption
                dd if=/dev/urandom of=${KEYFILE} bs=1024 count=4
                chmod 0400 ${KEYFILE}
                echo "Adding a keyfile for ${DEVICENAME} for atomount configuration on ${MOUNTPOINT}"
                cryptsetup luksAddKey ${NEWPARTITION} ${KEYFILE}

                #Update /etc/crypttab
                echo 'Updating /etc/crypttab'
                echo "${LUKSNAME} UUID=${HDDUUID} /root/keyfile_${HDDUUID}" >> /etc/crypttab

                #Update /etc/fstab
                echo 'Updating /etc/fstab'
                echo "/dev/mapper/${LUKSNAME}   ${MOUNTPOINT}   ext4   defaults  0  2" >> /etc/fstab
            fi
        done
    fi
}

RemoveKeyfileMounts() {
    # This function is made to *partially* revert the setup made by ReclaimEncryptDWUnmntPrt and EncryptUnpartitionedDisks
    # The function cleans up *all mounts* made with keyfiles (!!!)
    # No unmounts are being made, so you have to either reboot or manually unmount
    # Encrypted drives will still be encrypted after this function runs

    LUKSNAMES=$( grep 'root/keyfile' /etc/crypttab | cut -d ' ' -f1 |  uniq )

    while [[ $( grep -in 'root/keyfile' /etc/crypttab ) ]]; do
        FIRSTLINE2DEL=$( grep -in 'root/keyfile' /etc/crypttab | cut -c1-2 | cut -d ':' -f1 | awk NR==1 )
        sed -i ${FIRSTLINE2DEL}'d' /etc/crypttab  # Remove lines from crypttab
    done

    for LUKSDEVICE in ${LUKSNAMES} ; do
        while [[ $( grep -in ${LUKSDEVICE} /etc/fstab ) ]]; do
            FIRSTLINE2DEL=$( grep -in ${LUKSDEVICE} /etc/fstab | cut -c1-2 | cut -d ':' -f1 | awk NR==1 )
            sed -i ${FIRSTLINE2DEL}'d' /etc/fstab  # Remove lines from fstab
        done
    done
}
