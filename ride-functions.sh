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
    apt install -y bash-completion coreutils git gnupg python3 tar wget apt-transport-https net-tools pciutils
}

InstallChipDependant() {
    CPUINFO=$( cat /proc/cpuinfo | grep 'model name' | sort | uniq )
    CHIPSET=$( echo ${CPUINFO} | awk '{print $4}' )
    if [ x"${CHIPSET}" == "xAMD" ]; then
        apt install -y amd-microcode firmware-amd
    else
        apt install -y intel-microcode
    fi
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
    CPUINFO=$( cat /proc/cpuinfo | grep 'model name' | sort | uniq )
    CHIPSET=$( echo ${CPUINFO} | awk '{print $4}' )
    if [ x"${CHIPSET}" == "xAMD" ]; then
        apt install -y firmware-amd-graphics
        XORGVIDEO='xserver-xorg-video-amdgpu'
    else
        XORGVIDEO='xserver-xorg-video-intel'
    fi

    apt install -y ${XORGVIDEO} xfonts-100dpi xfonts-75dpi xfonts-base xfonts-encodings xfonts-terminus xfonts-traditional xfonts-utils xdm xinit
}

RemoveXserver() {
    CPUINFO=$( cat /proc/cpuinfo | grep 'model name' | sort | uniq )
    CHIPSET=$( echo ${CPUINFO} | awk '{print $4}' )
    if [ x"${CHIPSET}" == "xAMD" ]; then
        apt remove -y firmware-amd-graphics
        XORGVIDEO='xserver-xorg-video-amdgpu'
    else
        XORGVIDEO='xserver-xorg-video-intel'
    fi
    apt remove -y ${XORGVIDEO} xfonts-100dpi xfonts-75dpi xfonts-base xfonts-encodings xfonts-terminus xfonts-traditional xfonts-utils xdm xinit
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


###############################
### Basic Tools and support ###
###############################

InstallExfatSupport() {
    apt install -y exfat-fuse exfatprogs
}

RemoveExfatSupport() {
    apt remove -y exfat-fuse exfatprogs
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


############################
### Database ###
############################

InstallPostgreSQLServer() {
    if [ ! -d /etc/apt/keyrings ]; then
        mkdir /etc/apt/keyrings
    fi

    PGDG_KEY=$( wget --quiet -O - https://www.postgresql.org/download/linux/debian/ | grep 'media/keys' | awk '{print $5}' )
    wget --quiet ${PGDG_KEY} -O /tmp/postgres.gpg
    cd /tmp
    gpg --no-default-keyring --keyring ./temp-keyring.gpg --import postgres.gpg
    gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output /etc/apt/keyrings/postgresql.gpg

    echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ ${OSRELEASE}-pgdg main" > /etc/apt/sources.list.d/pgdg.list

    apt update
    apt install -y postgresql-16
}

RemovePostgreSQLServer() {
    PGDG='/etc/apt/sources.list.d/pgdg.list'
    apt remove -y postgresql-16
    if [ -f /etc/apt/keyrings/postgresql.gpg ]; then
        rm /etc/apt/keyrings/postgresql.gpg
    fi
    if [ -f ${PGDG} ]; then
       rm ${PGDG}
    fi
}

InstallPostgreSQLClient() {
    if [ ! -d /etc/apt/keyrings ]; then
        mkdir /etc/apt/keyrings
    fi

    PGDG_KEY=$( wget --quiet -O - https://www.postgresql.org/download/linux/debian/ | grep 'media/keys' | awk '{print $5}' )
    wget --quiet ${PGDG_KEY} -O /tmp/postgres.gpg
    cd /tmp
    gpg --no-default-keyring --keyring ./temp-keyring.gpg --import postgres.gpg
    gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output /etc/apt/keyrings/postgresql.gpg

    echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ ${OSRELEASE}-pgdg main" > /etc/apt/sources.list.d/pgdg.list

    apt update
    apt install -y postgresql-client-16
}

RemovePostgreSQLClient() {
    PGDG='/etc/apt/sources.list.d/pgdg.list'
    apt remove -y postgresql-client-16
    if [ -f /etc/apt/keyrings/postgresql.gpg ]; then
        rm /etc/apt/keyrings/postgresql.gpg
    fi
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
    apt remove -y libtsk19
    # Prerequisite for Autopsy
    apt install -y openjdk-17-jre-headless testdisk libpq-dev libvhdi-dev libvmdk-dev libde265-dev libheif-dev libewf-dev libafflib-dev libsqlite3-dev libc3p0-java libpostgresql-jdbc-java libvmdk-dev libvhdi-dev libbfio-dev unzip

    # Get download page for links
    wget -q -O ${DOWNLOADDIR}/autopsy.html https://www.autopsy.com/download/

    LATEST_SLEUTH_JAVA=$( grep Linux ${DOWNLOADDIR}/autopsy.html | grep .deb | grep href | awk -F 'href="' '{print $2}' | awk -F '">' '{print $1}')
    LATEST_AUTOPSY=$( grep Download ${DOWNLOADDIR}/autopsy.html | grep .zip | grep href | awk -F 'href="' '{print $2}' | awk -F '">' '{print $1}' )
    LATESTAUTOPSYSIGNATURE="${LATEST_AUTOPSY}.asc"

    # Set JAVA_HOME
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    echo 'JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ${MYUSERDIR}/.bashrc

    # Install Sleuthkit Java:
    cd ${DOWNLOADDIR}
    SLEUTH_JAVA=$( basename ${LATEST_SLEUTH_JAVA} )
    wget --quiet --show-progress ${LATEST_SLEUTH_JAVA} -O ${DOWNLOADDIR}/${SLEUTH_JAVA}
    dpkg -i ${DOWNLOADDIR}/${SLEUTH_JAVA}

    # Install Autopsy:
    AUTOPSYINSTALLER="$( basename ${LATEST_AUTOPSY} )"
    wget --quiet --show-progress ${LATEST_AUTOPSY} -O ${DOWNLOADDIR}/${AUTOPSYINSTALLER}
    wget --quiet ${LATESTAUTOPSYSIGNATURE} -O ${DOWNLOADDIR}/autopsy_signature.asc

    # Ensure Autopsy package is correctly signed by Brian Carriers GPG key:
    #$ gpg --search 0x0917A7EE58A9308B13D3963338AD602EC7454C8B
    #gpg: data source: https://keys.openpgp.org:443
    #(1)      1024 bit DSA key 38AD602EC7454C8B, created: 2004-03-04
    #Keys 1-1 of 1 for "0x0917A7EE58A9308B13D3963338AD602EC7454C8B".
    gpg --verify ${DOWNLOADDIR}/autopsy_signature.asc ${DOWNLOADDIR}/${AUTOPSYINSTALLER} > /tmp/autopsy_sigcheck.txt 2>&1
    if [ $( grep -E '0917A7EE58A9308B13D3963338AD602EC7454C8B|carrier@sleuthkit.org' /tmp/autopsy_sigcheck.txt | wc -l ) -ne 2 ]; then
        echo 'Autopsy signature of package does not match known signature from Brian Carrier - pls investigate manually.'
        exit 1
    fi

    cd ${MYUSERDIR}
    AUTOPSYSUBDIR=$( unzip -l ${DOWNLOADDIR}/${AUTOPSYINSTALLER} | awk 'NR==5' | awk '{print $4}' | cut -f 1 -d '/' )
    unzip ${DOWNLOADDIR}/${AUTOPSYINSTALLER}
    chown -R ${MYUSER}:${MYUSER} ${AUTOPSYSUBDIR}/
    chmod +x ${AUTOPSYSUBDIR}/unix_setup.sh
    if [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
        sed -i "/^TSK_VERSION=.*$/a JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" ${AUTOPSYSUBDIR}/unix_setup.sh
        su - ${MYUSER} sh -c "cd ${AUTOPSYSUBDIR} && ./unix_setup.sh"
    else
        echo 'Something has gone wrong - the java-17-openjdk-amd64 package has not been installed correctly.'
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

InstallUAC() {
    wget https://github.com/tclahr/uac/releases/latest -O /tmp/uac_latest.html
    LATEST_VERS=$( awk -F '<title>Release ' '{print $2}' /tmp/uac_latest.html | awk -F ' · tclahr/uac' '{print $1}' | grep -v ^$ )
    VERSION=$( echo ${LATEST_VERS} | awk -F 'uac-' '{print $2}' )
    wget https://github.com/tclahr/uac/releases/download/v${VERSION}/${LATEST_VERS}.tar.gz -O ${DOWNLOADDIR}/uac.tar.gz
    wget https://github.com/tclahr/uac/releases/download/v${VERSION}/${LATEST_VERS}.tar.gz.sha256 -O ${DOWNLOADDIR}/uac.tar.gz.sha256
    CHECKSUM=$( awk '{print $1}' ${DOWNLOADDIR}/uac.tar.gz.sha256 )
    CHECK_TARBALL=$( sha256sum ${DOWNLOADDIR}/uac.tar.gz | awk '{print $1}' )
    if [ x${CHECKSUM} == x${CHECK_TARBALL} ]; then
        cd ${MYUSERDIR}
        tar -xzvf ${DOWNLOADDIR}/uac.tar.gz
        mv ${LATEST_VERS} uac
        chown -R ${MYUSER}:${MYUSER} ${MYUSERDIR}/uac
    else
        echo 'UAC tarball checksum does not match UAC project provided checksum.'
        exit 1
    fi
}

RemoveUAC() {
    if [ -d ${MYUSERDIR}/uac ]; then
        rm -rf ${MYUSERDIR}/uac
    fi
}

#################################
### Reverse Engineering tools ###
#################################

InstallGhidra() {
    if [ ! -d ${MYUSERDIR}/ghidra ]; then
        apt install -y curl openjdk-17-jdk unzip wget
        LATEST=$( wget https://github.com/NationalSecurityAgency/ghidra/releases/latest -O /tmp/ghidra_latest.txt )
        LATEST_VERS=$( grep '<title>' /tmp/ghidra_latest.txt | awk '{print $3}' )
        #get ${LATEST} -O - | grep ghidra_ | awk -F '"px-1 text-bold">' '{print $2}' | awk -F '<' '{print $1}' )
        LIST_OF_BUILDS=$( grep 'https://github.com/NationalSecurityAgency/ghidra/releases/expanded_assets' /tmp/ghidra_latest.txt | awk -F 'src="' '{print $2}' | awk -F '"' '{print $1}')
        wget ${LIST_OF_BUILDS} -O /tmp/ghidra_latest_builds.txt
        LATEST_GHIDRA_BUILD=$( grep "ghidra_${LATEST_VERS}" /tmp/ghidra_latest_builds.txt | grep href | awk -F 'href="' '{print $2}' | awk -F '"' '{print $1}' )
        wget https://github.com${LATEST_GHIDRA_BUILD} -O ${DOWNLOADDIR}/ghidra.zip
#        ZIP_FILE=$( echo ${LATEST}/$( echo ${LATEST_VERS} ) | sed -e 's/tag/download/g' )
#        wget ${ZIP_FILE} -O ${DOWNLOADDIR}/ghidra.zip
        cd ${MYUSERDIR}
        unzip ${DOWNLOADDIR}/ghidra.zip
        mv ghidra_* ghidra
    else
        rm -rf ${MYUSERDIR}/ghidra
        InstallGhidra
    fi
    chown -R ${MYUSER}:${MYUSER} ${MYUSERDIR}/ghidra
}

RemoveGhidra() {
    apt remove -y openjdk-17-jdk unzip
    if [ -d ${MYUSERDIR}/ghidra ]; then
        rm -rf ${MYUSERDIR}/ghidra
    fi
}

InstallCutter() {
    # Installing prerequisites
    apt install -y build-essential cmake meson pkg-config libzip-dev zlib1g-dev libqt5svg5-dev qttools5-dev qttools5-dev-tools libkf5syntaxhighlighting-dev libgraphviz-dev wget
    # when building with CUTTER_ENABLE_PYTHON_BINDINGS - this however, continuously failed for me so I'm excluding it
    # apt install -y libshiboken2-dev libpyside2-dev  qtdeclarative5-dev
    # for Python bindings: cmake -DCUTTER_ENABLE_PYTHON=TRUE -DCUTTER_ENABLE_PYTHON_BINDINGS=/usr/bin/python -DCUTTER_ENABLE_GRAPHVIZ=TRUE -DCUTTER_ENABLE_KSYNTAXHIGHLIGHTING=TRUE ..

    # Get latest cutter version
    wget https://github.com/rizinorg/cutter/releases/latest -O /tmp/cutter.html
    LATEST_VERS=$( grep Release /tmp/cutter.html | awk -F '<title>Release ' '{print $2}'  | awk -F ' · rizinorg/cutter' '{print $1}' | grep -v ^$ )
    wget https://github.com/rizinorg/cutter/releases/download/v${LATEST_VERS}/Cutter-v${LATEST_VERS}-src.tar.gz -O ${DOWNLOADDIR}/cutter.tar.gz

    cd ${DOWNLOADDIR}
    tar -xzvf cutter.tar.gz

    # Build from source
    cd ${DOWNLOADDIR}/Cutter-v${LATEST_VERS}
    mkdir build
    cd build/
    cmake -DCUTTER_ENABLE_GRAPHVIZ=TRUE -DCUTTER_ENABLE_KSYNTAXHIGHLIGHTING=TRUE ..
    cmake --build .
    cmake --install .
}

RemoveCutter() {
    if [ -f /usr/local/bin/cutter]; then
        rm /usr/local/bin/cutter
    fi
    if [ -d /usr/local/lib ]; then
        rm -f /usr/local/lib/librz_*
    fi
}

InstallMalcat() {
    # Installing prerequisites
    apt install -y wget unzip pip python3-tabulate python3-ruamel.yaml

    # Get latest malcat version
    wget https://malcat.fr/latest/malcat_bookworm_lite.zip -O ${DOWNLOADDIR}/malcat.zip

    if [ ! -d ${MYUSERDIR}/malcat ]; then
        mkdir ${MYUSERDIR}/malcat
    else
        rm -rf ${MYUSERDIR}/malcat
        mkdir ${MYUSERDIR}/malcat
    fi
    cd ${MYUSERDIR}/malcat
    unzip ${DOWNLOADDIR}/malcat.zip
    ln -s ${MYUSERDIR}/malcat/bin/malcat ${MYUSERDIR}/bin/malcat
    pip install -r requirements.txt
}

RemoveMalcat() {
    rm -rf ${MYUSERDIR}/malcat
}

InstallRadare2() {
    # Install radare2 - reverse engineering framework
    BASEURL='https://github.com/radareorg/radare2/releases'
    wget ${BASEURL}/latest -O r2latest.txt
    R2_VERSION=$( grep Release r2latest.txt | grep '<title>' | awk '{print $2}' )
    R2_DEB="radare2_${R2_VERSION}_amd64.deb"
    wget ${BASEURL}/download/${R2_VERSION}/${R2_DEB} -O /tmp/${R2_DEB}
    dpkg -i /tmp/${R2_DEB}
}

RemoveRadare2() {
    apt remove -y radare2
}

InstallIaito() {
    # Install Qt GUI frontend to radare2
    apt install -y libqt5svg5
    BASEURL='https://github.com/radareorg/iaito/releases'
    wget ${BASEURL}/latest -O iaitolatest.txt
    IAITO_VERSION=$( grep Release iaitolatest.txt | grep '<title>' | awk '{print $2}' )
    IAITO_DEB="iaito_${IAITO_VERSION}_amd64.deb"
    wget ${BASEURL}/download/${IAITO_VERSION}/${IAITO_DEB} -O /tmp/${IAITO_DEB}
    dpkg -i /tmp/${IAITO_DEB}

}

RemoveIaito() {
    apt remove -y iaito
}

InstallEDBDebugger() {
    # Install prerequisites
    apt install -y pkg-config cmake build-essential libboost-dev libdouble-conversion-dev libqt5xmlpatterns5-dev qtbase5-dev qttools5-dev libgraphviz-dev libqt5svg5-dev libcapstone-dev

    # EDB Debugger uses gdtoa-desktop for binary-decimal conversion
    # so need to make/install it first
    cd ${DOWNLOADDIR}
    git clone https://github.com/10110111/gdtoa-desktop.git
    mkdir gdtoa-desktop/build
    cd gdtoa-desktop/build
    cmake ..
    make
    make install

    # Build EDB Debugger
    cd ${DOWNLOADDIR}
    git clone --recursive https://github.com/eteran/edb-debugger.git
    mkdir edb-debugger/build
    cd edb-debugger/build
    cmake ..
    make
    make install
}

RemoveEDBDebugger() {
    for FILE in /usr/local/share/man/man1/edb.1 /usr/local/share/applications/edb.desktop /usr/local/share/pixmaps/edb.png /usr/local/bin/edb /usr/local/lib/edb/* /usr/local/lib/libgdtoa-desktop.so /usr/local/lib/pkgconfig/gdtoa-desktop.pc /usr/local/include/gdtoa-desktop/* ; do
        rm ${FILE}
    done
    rmdir /usr/local/include/gdtoa-desktop/
    rmdir /usr/local/lib/edb
}


###########################
### CTF / Pentest tools ###
###########################

InstallBurp() {
    if [ ! -d ${MYUSERDIR}/BurpSuiteCommunity ]; then
        LATEST=$( wget https://portswigger.net/burp/releases/community/latest -O /tmp/burp_latest.txt )
        VERSION=$( grep 'value="Download" version=' /tmp/burp_latest.txt | awk -F 'version="' '{print $2}' | cut -f1 -d '"' | sed -e '/^$/d' )
        wget "https://portswigger.net/burp/releases/startdownload?product=community&version=$VERSION&type=Linux" -O ${DOWNLOADDIR}/burp.sh
        su - ${MYUSER} sh -c "cd ${MYUSERDIR} && sh ${DOWNLOADDIR}/burp.sh"
    else
        rm -rf ${MYUSERDIR}/BurpSuiteCommunity
        InstallBurp
    fi
}

RemoveBurp() {
    if  [ -d ${MYUSERDIR}/BurpSuiteCommunity ]; then
        rm -rf ${MYUSERDIR}/BurpSuiteCommunity
    fi
}


################################################################
### Programming Tools ###
################################################################

InstallVisualStudioCode() {
    if [ ! -d /etc/apt/keyrings ]; then
        mkdir /etc/apt/keyrings
    fi

    if [ ! -f /etc/apt/keyrings/microsoft.gpg ]; then
        curl -sS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg
        chmod 644 /etc/apt/keyrings/microsoft.gpg
    fi
    echo 'deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/repos/vscode stable main' > /etc/apt/sources.list.d/vscode.list

    #Then update the package cache and install the package using:
    apt update
    apt install -y code # or code-insiders
}

RemoveVisualStudioCode() {
    apt remove -y code
    if [ -f /etc/apt/keyrings/microsoft.gpg ]; then
        rm /etc/apt/keyrings/microsoft.gpg
    fi
    if [ -f /etc/apt/sources.list.d/vscode.list ]; then
        rm /etc/apt/sources.list.d/vscode.list
    fi
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
    apt install -y tcpdump wireshark nmap macchanger tcpreplay
}

RemoveNetworkTools() {
    apt remove -y tcpdump wireshark nmap macchanger tcpreplay
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
    if [ ! -d /etc/apt/keyrings ]; then
        mkdir /etc/apt/keyrings
    fi

    wget --quiet https://deb.opera.com/archive.key -O /etc/apt/keyrings/opera.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/opera.gpg] https://deb.opera.com/opera-stable/ stable non-free' > /etc/apt/source.list.d/opera.list
    apt update
    apt install -y opera-stable
}

RemoveOpera() {
    apt remove -y opera-stable
    if [ -f /etc/apt/keyrings/opera.gpg ]; then
        rm /etc/apt/keyrings/opera.gpg
    fi
    if [ -f /etc/apt/sources.list.d/opera.list ]; then
        rm /etc/apt/sources.list.d/opera.list
    fi
}

InstallVivaldi() {
    # Install prerequisites
    apt install -y libappindicator3-1 libdbusmenu-glib4 libdbusmenu-gtk3-4 libindicator3-7

    if [ ! -d /etc/apt/keyrings ]; then
        mkdir /etc/apt/keyrings
    fi

    wget --quiet https://repo.vivaldi.com/stable/linux_signing_key.pub -O /etc/apt/keyrings/vivaldi.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/vivaldi.gpg] http://repo.vivaldi.com/stable/deb/ stable main' > /etc/apt/sources.list.d/vivaldi.list
    apt update
    apt install -y vivaldi-stable
}

RemoveVivaldi() {
    apt remove -y vivaldi-stable
    if [ -f /etc/apt/keyrings/vivaldi.gpg ]; then
        rm /etc/apt/keyrings/vivaldi.gpg
    fi
    if [ -f /etc/apt/sources.list.d/vivaldi.list ]; then
        rm /etc/apt/sources.list.d/vivaldi.list
    fi
}


################################################################
###### Multimedia ###
################################################################

InstallSpotifyClient() {
    if [ ! -d /etc/apt/keyrings ]; then
        mkdir /etc/apt/keyrings
    fi
    # Install Spotify gpg-key
    wget https://www.spotify.com/us/download/linux/ -O /tmp/spotify_dl_site.html
    APTKEY=$( awk -F 'curl -sS ' '{print $2}' /tmp/spotify_dl_site.html | awk -F '|' '{print $1}' | grep -v ^$ )
    cd /tmp/
    wget --quiet ${APTKEY} -O /tmp/spotify.key
    gpg --no-default-keyring --keyring /tmp/temp-keyring.gpg --import /tmp/spotify.key 
    gpg --no-default-keyring --keyring /tmp/temp-keyring.gpg --export --output /etc/apt/keyrings/spotify.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free' > /etc/apt/sources.list.d/spotify.list

    # Install Spotify client
    apt update
    apt install -y spotify-client
}

RemoveSpotifyClient() {
    # remove Spotify client
    apt remove -y spotify-client
    SPOTIFYREPO=/etc/apt/sources.list.d/spotify.list
    if [ -f /etc/apt/keyrings/spotify.gpg ]; then
        rm /etc/apt/keyrings/spotify.gpg
    fi
    if [ -f ${SPOTIFYREPO} ]; then
        rm ${SPOTIFYREPO}
    fi
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
    if [ ! -d /etc/apt/keyrings ]; then
        mkdir /etc/apt/keyrings
    fi
    if [ ! -f /etc/apt/keyrings/microsoft.gpg ]; then
        curl -sS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg
        chmod 644 /etc/apt/keyrings/microsoft.gpg
    fi
    DEBVERSIONNAME=$( grep VERSION_CODENAME /etc/os-release | awk -F '=' '{print $2}' )
    echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-${DEBVERSIONNAME}-prod ${DEBVERSIONNAME} main" > /etc/apt/sources.list.d/powershell.list
    # Known latest Debian release that actually has Powershell packages (just as a seatbelt for being able to install it)
    echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" >> /etc/apt/sources.list.d/powershell.list

    apt update
    apt install -y powershell
}

RemovePowerShell() {
    apt remove -y powershell
    if [ -f /etc/apt/keyrings/microsoft.gpg ]; then
        rm /etc/apt/keyrings/microsoft.gpg
    fi
    if [ -f /etc/apt/sources.list.d/powershell.list]; then
        rm /etc/apt/sources.list.d/powershell.list
    fi
}


################################################################
### Security related ###
################################################################

InstallKeepassXC() {
    apt install -y keepassxc
}

RemoveKeepassXC() {
    apt remove -y keepassxc
}

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

InstallRootkitCheckers() {
    apt install -y chkrootkit rkhunter unhide
}

RemoveRootkitCheckers() {
    apt remove -y chkrootkit rkhunter unhide
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
