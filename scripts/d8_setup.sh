#!/bin/bash

#########################################################
#
# What you'll get:
#
#    $ time ./d8_setup.sh
#    What should be the name of the new Drupal docroot?
#    d8
#    Unpacking drupal-8.0-alpha3.tar.gz...
#    Successfully created Drupal docroot: d8
#    	Copying settings.php file...
#    	Setting correct permissions...
#    	Provisionning Apache vhost...
#    	Creating MySQL database...
#    Site is available at http://d8.local
#
#    real	0m1.210s
#    user	0m0.360s
#    sys	0m0.288s
#
########################################################

#############
# VARIABLES #
#############

# Drupal variables
WEBROOT="/var/www/html"
TMP="/tmp"
RELEASE="drupal-8.0-alpha3"
COMPRESSION="tar.gz"
DRUPAL="${RELEASE}.${COMPRESSION}"

# Apache variables
SITES_AVAILABLE="/etc/apache2/sites-available"
SITES_ENABLED="/etc/apache2/sites-enabled"
SUFFIX="local"

# PHP
PHP="php5-curl"

# Colors
GREEN_START="\033[38;5;148m"
GREEN_END="\033[39m"
RED_START="\033[0;31m"
RED_END="\033[0m"

################
# REQUIREMENTS #
################

# Enable mod_rewrite if needed
if [[ ! -L /etc/apache2/mods-enabled/rewrite.load ]]; then
	echo "Enabling mod_rewrite..."
	a2enmod rewrite
	service apache2 restart
fi

# Guzzle support
for pkg in $PHP; do
	if ! dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
		echo -e "\tInstalling $pkg..."
		apt-get -qq install $pkg
	fi
done

##################
# Drupal install #
##################
echo -e "What should be the name of the new Drupal docroot?"
read DOCROOT

# Docroot exists
if [[ -d $WEBROOT/$DOCROOT ]]; then
	echo -e $RED_START"docroot already exists! Aborting."$RED_END
	exit 0
fi

# Download archive only if needed
if [[ ! -f $TMP/$DRUPAL ]]; then
	echo "Downloading $DRUPAL..."
	wget -P $TMP -q http://ftp.drupal.org/files/projects/$DRUPAL
fi

echo "Unpacking $DRUPAL..."
tar -C $WEBROOT -xzf $TMP/$DRUPAL

mv $WEBROOT/$RELEASE $WEBROOT/$DOCROOT
echo -e $GREEN_START"Successfully created Drupal docroot: $DOCROOT"$GREEN_END

echo -e "\tCopying settings.php file..."
cp $WEBROOT/$DOCROOT/sites/default/default.settings.php $WEBROOT/$DOCROOT/sites/default/settings.php

echo -e "\tSetting correct permissions..."
# Allows to create the files and translations dirs automatically
chmod a+w $WEBROOT/$DOCROOT/sites/default
chmod a+w $WEBROOT/$DOCROOT/sites/default/settings.php  

# Apache setup
echo -e "\tProvisionning Apache vhost..."
cp $SITES_AVAILABLE/default $SITES_AVAILABLE/$DOCROOT
	# Adding ServerName directive
	sed -i "3i\\\tServerName $DOCROOT.$SUFFIX" $SITES_AVAILABLE/$DOCROOT
	# Modifying DocumentRoot and Directory directives
	sed -i "s:/var/www:/var/www/html/$DOCROOT:g" $SITES_AVAILABLE/$DOCROOT
cd $SITES_ENABLED && ln -s $SITES_AVAILABLE/$DOCROOT $SITES_ENABLED/$DOCROOT
apache2ctl graceful
	# Updating hosts file
	sed -i "1i127.0.0.1\t$DOCROOT.$SUFFIX" /etc/hosts

# MySQL setup
MYSQL=`which mysql`
DB_CREATE="CREATE DATABASE IF NOT EXISTS $DOCROOT CHARACTER SET utf8 COLLATE utf8_general_ci;"
DB_PERMS="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON $DOCROOT.* TO 'root'@'localhost' IDENTIFIED BY 'root'"
SQL="${DB_CREATE}${DB_PERMS}"

echo -e "\tCreating MySQL database..."
	#echo "CREATE DATABASE $DOCROOT CHARACTER SET utf8 COLLATE utf8_general_ci" | mysql -u root -proot
	#echo "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON `$DOCROOT`.* TO 'root'@'localhost' IDENTIFIED BY 'root'" | mysql -u root -proot
	#echo "FLUSH PRIVILEGES" | mysql -u root -proot
	$MYSQL -uroot -proot -e "$SQL"

echo -e $GREEN_START"Site is available at http://$DOCROOT.$SUFFIX"$GREEN_END

# echo "Deleting archive $DRUPAL..."
# rm $TMP/$DRUPAL

# echo -e "Reverting permissions for security reasons..."
# chmod go-w sites/default
# chmod go-w sites/default/settings.php