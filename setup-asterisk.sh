#!/bin/bash
#
# Installs asterisk by compiling and installing requirements and dependencies.
#
# What this script does
# 0. Installs required packages via apt.
# 1. Download asterisk, libpri, and dahdi to /usr/src/
# 2. Extract them to asterisk/, libpri/, and dahdi/, respectively.
# 3. Run this script, and enjoy.
# 4. PS. If you want to install LAMP as well, include the --lamp parameter
# If you want to install asterisk as a non-root user, use the --update parameter. (Reference: http://asteriskdocs.org/en/2nd_Edition/asterisk-book-html-chunk/asterisk-CHP-13-SECT-4.html)

function check_requirements() {

    echo -ne Checking for $1...
    if [ ! -d $1 ]; then
        echo "NOT FOUND!"
        echo $2
        echo ""
        exit 1
    fi

    echo "OK"

}

function install_dependencies() {

    apt -y install git make linux-source kernel-package linux-kernel-headers linux-headers-`uname -r`
    apt -y install libconfig-tiny-perl libcupsimage2 libcups2 libmime-lite-perl libemail-date-format-perl libfile-sync-perl libfreetype6 libspandsp2 libtiff-tools libtiff5 libjpeg62-turbo libmime-types-perl libpaper-utils psutils libpaper1 ncurses-bin ncurses-dev libncurses5-dev libncurses-gst ncurses-term libnewt0.52 libnewt-dev libnewt-pic libxml2 libxml2-dev libspandsp-dev pwgen

}


function compile_libpri ()
{
	#Change to the proper directory

	# Compile libpri

	cd /usr/src/libpri
	echo "Compiling libpri."
	read -p "Press [ENTER] to continue..."
	make
}

function compile_dahdi_all() {
	cd /usr/src/dahdi/
	make all
	make install

}

function compile_dahdhi_kernel ()
{
	# Compile the DAHDI kernel

	cd /usr/src/dahdi/linux
	echo "Compiling dahdi kernel."
	read -p "Press [ENTER] to continue..."

	make
	make install
}

function compile_dahdi_tools()
{
	# Compile the tools

	cd /usr/src/dahdi/tools
	echo "Compiling dahdi tools."
	read -p "Press [ENTER] to continue..."

	./configure
	make
	make install
	make config

}

function compile_asterisk() {
	# Compile asterisk

	cd /usr/src/asterisk
	echo "Compiling asterisk."
	read -p "Press [ENTER] to continue..."

	./configure
	make
	make install

	make config
	make samples
}

function update_asterisk() {

	cd /usr/src/asterisk
	make clean
	compile_asterisk

}

function setupUser() {
     PASS=`pwgen -cns 32 1`
     echo "Setting up user: $1"
     useradd -m $1
     usermod -s /bin/bash $1

     echo "Setting password to: $PASS"
     echo "$1:$PASS" | chpasswd

     echo "Saving information to setup.log"
     echo $1 : $PASS >> setup.log
 }

function show_help() {
    cat <<-'EOF'

SUMMARY
    This script will compile and install asterisk.
    For support, file an issue at https://github.com/mjmunger/setup-asterisk/issues

USAGE:

setup-aseterisk.sh [command]

Command list:

  help          Show this help menu.
  prep          Prep the system to compile and install asterisk.
  libpri        Compile and install libpri ONLY.
  dahdi-kernel  Compile and install the dahdi kernel files ONLY.
  dahdi-tools   Compiles and install the dahdi tools ONLY.
  dahdi-all     Compiles and installs dahdi kernel and and tools in the correct order.
  asterisk      Compiles and installs asterisk ONLY.
  update-asterisk  Cleans the current version of asterisk, and re-installs asterisk to update it.
  complete      Compiles and installs all of the above in the correct order to setup Asterisk.

EOF

}

declare -A REQMAP
BACK=$IFS
IFS='|'
REQMAP['/usr/src/asterisk']='Asterisk package not found. Please download from asterisk.org, and extract to /usr/src/asterisk.'
REQMAP['/usr/src/dahdi']='Dahdi package not found. Please download from asterisk.org, and extract to /usr/src/dahdi. (Dahdi-complete package is recommended).'
REQMAP['/usr/src/dahdi/linux']='Dahdi kernel package not found. Please download from asterisk.org, and extract to /usr/src/dahdi/linux.'
REQMAP['/usr/src/dahdi/tools']='Dahdi tools package not found. Please download from asterisk.org, and extract to /usr/src/dahdi/tools.'
REQMAP['/usr/src/libpri']='Libpri package not found. Please download from asterisk.org, and extract to /usr/src/libpri.'


for REQ in ${!REQMAP[@]}
do
    echo ${REQMAP[@]}
    check_requirements ${REQ} ${REQMAP[@]}
done

IFS=${BACK}

if [ `whoami` != 'root' ]; then
    echo "This must be run as root! Quitting."
    exit 1
fi

case "$1" in
    help)
        show_help
        ;;
    prep)
        install_dependencies
        ;;
    libpri)
        compile_libpri
        ;;
    dahdi-kernel)
        compile_dahdhi_kernel
        ;;
    dahdi-tools)
        compile_dahdi_tools
        ;;
    dahdi-all)
        compile_dahdi_all
        ;;
    asterisk)
        compile_asterisk
        ;;
    update-asterisk)
        update_asterisk
        ;;
    complete)
        install_dependencies
        compile_dahdi_all
        compile_libpri
        compile_asterisk
        ;;
    *)
        show_help
        ;;
esac