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

#Setup the system

apt-get install subversion
apt-get install make
apt-get install linux-source kernel-package
apt-get install linux-kernel-headers
apt-get install linux-headers
#apt-get install linux-headers-2.6.31-14-generic-pae #<-- or whatever matches your version.
apt-get install linux-headers-`uname -r`

#Install other needed stuff

aptitude install libconfig-tiny-perl libcupsimage2 libcups2 libmime-lite-perl libemail-date-format-perl libfile-sync-perl libfreetype6 libspandsp1 libtiff-tools libtiff4 libjpeg62 libmime-types-perl libpaper-utils psutils libpaper1 ncurses ncurses-dev libncurses-dev libncurses-gst ncurses-term libnewt libnewt-dev libnewt-pic libxml2 libxml2-dev libspandsp-dev libspandsp1 pwgen

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

#Assume we are not upgrading anything.
if [ "$1" == "--nonroot" ]
then
	echo -n "Checking to see if asterisk user exists..."
	USEREXISTS=`grep -rin asterisk /etc/passwd`
	if [ ${USEREXISTS} ]; then
		echo "YES"
	else
		echo "NO"
		echo "Setting up user..."
		setupUser asterisk
	fi
	compile_libpri
	compile_dahdhi_kernel
	compile_dahdi_tools
	echo "Everything but Asterisk has been compiled. Now, you need to create the non-root user ('asterisk'?), and compile using the following configure script:"
	echo ""
	echo "su asterisk"
	echo "cd /usr/src/asterisk"
	echo "make clean"
	echo "./configure --prefix=$HOME/asterisk-bin --sysconfdir=$HOME/asterisk-bin --localstatedir=$HOME/asterisk-bin"
	echo "make menuselect"
	echo "make"
	echo "make install"
	echo ""
	# echo "Note: for reference, here's how to create the user:"
	# echo ""
	# echo 'adduser -c "Asterisk PBX" asterisk'
	# echo "passwd asterisk"
	# echo ""
	# echo "SET A STRONG PASSWORD FOR THE ASTERISK USER!"
	# echo "Use the pwgen utility to generate a 32 character random password to effectively disable it, then enable key authentication to manage the asterisk user"
	exit;
fi

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
