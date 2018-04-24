#~/bin/bash
#Check the system for the required packages
#How to use this script:
#1. Download asterisk, libpri, and dahdi to /usr/src/
#2. Extract them to asterisk/, libpri/, and dahdi/, respectively.
#3. Run this script, and enjoy.
#4. PS. If you want to install LAMP as well, include the --lamp parameter
#If you want to install asterisk as a non-root user, use the --update parameter. (Reference: http://asteriskdocs.org/en/2nd_Edition/asterisk-book-html-chunk/asterisk-CHP-13-SECT-4.html)

echo -ne Checking for asterisk source...
if [ -d /usr/src/asterisk ]
	then echo OK.
	else 
		echo NOT FOUND
		echo Asterisk package not found. Please download from asterisk.org, and extract to /usr/src/asterisk.
		exit;
fi
echo -ne Checking for dahdi...
if [ -d /usr/src/dahdi ]
	then echo OK.
	else 
		echo NOT FOUND
		echo Dahdi package not found. Please download from asterisk.org, and extract to /usr/src/dahdi. \(Dahdi-complete package is recommended\).
		exit;
fi
echo -ne Checking for dahdi kernel headers...
if [ -d /usr/src/dahdi/linux ]
	then echo OK.
	else 
		echo NOT FOUND
		echo Dahdi kernel package not found. Please download from asterisk.org, and extract to /usr/src/dahdi/linux.
		exit;
fi
echo -ne Checking for dahdi tools...
if [ -d /usr/src/dahdi/tools ]
	then echo OK.
	else 
		echo NOT FOUND
		echo Dahdi tools package not found. Please download from asterisk.org, and extract to /usr/src/dahdi/tools.
		exit;
fi
echo -ne Checking for libpri...
if [ -d /usr/src/libpri ]
	then echo OK.
	else 
		echo NOT FOUND
		echo Libpri package not found. Please download from asterisk.org, and extract to /usr/src/libpri.
		exit;
fi

function build_reqs() 
{
	#Setup the system
	
	apt-get install make
	apt-get install linux-source kernel-package
	apt-get install linux-kernel-headers
	apt-get install linux-headers
	apt-get install linux-headers-`uname -r`
	
	#Install other needed stuff
	
	aptitude install libconfig-tiny-perl libcupsimage2 libcups2 libmime-lite-perl libemail-date-format-perl libfile-sync-perl libfreetype6 libspandsp1 libtiff-tools libtiff4 libjpeg62 libmime-types-perl libpaper-utils psutils libpaper1 ncurses ncurses-dev libncurses-dev libncurses-gst ncurses-term libnewt libnewt-dev libnewt-pic libxml2 libxml2-dev libspandsp-dev libspandsp1 pwgen
	
	apt --assume-yes build-dep asterisk 
}

function build_lamp_stack()
{
	echo Installing LAMP...
	apt-get install apache2 apachetop mysql-server mysql-client php5 php5-cli php5-gd php5-imagick php5-imap php5-mcrypt php5-mhash php5-mysql php5-pgsql libmysqlclient-dev libcurl3-openssl-dev
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

setupUser() {
     PASS=`pwgen -cns 32 1`
     echo "Setting up user: $1"
     useradd -m $1
     usermod -s /bin/bash $1
 
     echo "Setting password to: $PASS"
     echo "$1:$PASS" | chpasswd
 
     echo "Saving information to setup.log"
     echo $1 : $PASS >> setup.log
 }

 case $1 in
    'setup')
        build_reqs
        ;;
    'dahdi')
    	compile_dahdi_all
    	;;
    'libpri')
    	compile_libpri
    	;;
    'asterisk')
    	compile_asterisk
    	;;
    'new')
    	compile_dahdi_all
    	compile_libpri
    	compile_asterisk
    * )
        usage
        ;;
esac