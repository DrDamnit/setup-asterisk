#~/bin/bash
#Check the system for the required packages
#How to use this script:
#1. Download asterisk, libpri, and dahdi to /usr/src/
#2. Extract them to asterisk/, libpri/, and dahdi/, respectively.
#3. Run this script, and enjoy.
#4. PS. If you want to install LAMP as well, include the --lamp parameter

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

#Setup the system

apt-get install subversion
apt-get install make
apt-get install linux-source kernel-package
apt-get install linux-kernel-headers
apt-get install linux-headers
#apt-get install linux-headers-2.6.31-14-generic-pae #<-- or whatever matches your version.
apt-get install linux-headers-`uname -r`

#Install other needed stuff

aptitude install libconfig-tiny-perl libcupsimage2 libcups2 libmime-lite-perl libemail-date-format-perl libfile-sync-perl libfreetype6 libspandsp1 libtiff-tools libtiff4 libjpeg62 libmime-types-perl libpaper-utils psutils libpaper1 ncurses ncurses-dev libncurses-dev libncurses-gst ncurses-term libnewt libnewt-dev libnewt-pic libxml2 libxml2-dev libspandsp-dev libspandsp1

#Install LAMP if asked to...
if [ "$1" = "--lamp" ];
	then
	echo Installing LAMP...
	apt-get install apache2 apachetop mysql-server mysql-client php5 php5-cli php5-gd php5-imagick php5-imap php5-mcrypt php5-mhash php5-mysql php5-pgsql libmysqlclient-dev libcurl3-openssl-dev
fi	

function compile_libpri ()
{
	#Change to the proper directory

	# Compile libpri

	cd /usr/src/libpri
	echo "Compiling libpri."
	read -p "Press [ENTER] to continue..."
	make
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

#Assume we are not upgrading anything.
if [ "$1" != "--update" ]
then	
	compile_libpri
	compile_dahdhi_kernel
	compile_dahdi_tools
	#compile_asterisk
	exit;
fi

#If we are upgrading something, do only that.
if [ "$1" == "--update" ]
	then
	if [ $# -eq 1 ]
		then
		echo "You asked me to update, but you didn't tell me WHAT to update.. Usage: `basename $0` --update [libpri | dahdi | asterisk | all]"
		exit;
	fi

	if [ "$2" == "libpri" ]
		then
		compile_libpri
		exit;
	fi

	if [ "$2" == "dahdi" ]
		then
		compile_dahdhi_kernel
		compile_dahdi_tools
		exit;
	fi

	if [ "$2" == "asterisk" ]
		then
		compile_asterisk
		exit;
	fi

	if [ "$2" == "all" ]
		then
		compile_libpri
		compile_dahdhi_kernel
		compile_dahdi_tools
		compile_asterisk
		exit;
	fi
echo "Recompiles / upgrades completed. You will need to restart services for the new version to take effect."
fi


	
