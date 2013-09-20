#!/bin/bash

source common

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
read SITE

# Docroot exists
if [[ -d $WEBROOT/$SITE ]]; then
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

mv $WEBROOT/$RELEASE $WEBROOT/$SITE
echo -e $GREEN_START"Successfully created Drupal docroot: $SITE"$GREEN_END

echo -e "\tCopying settings.php file..."
cp $WEBROOT/$SITE/sites/default/default.settings.php $WEBROOT/$SITE/sites/default/settings.php

echo -e "\tSetting correct permissions..."
# Allows to create the files and translations dirs automatically
chmod a+w $WEBROOT/$SITE/sites/default
chmod a+w $WEBROOT/$SITE/sites/default/settings.php  

# Apache setup
echo -e "\tProvisionning Apache vhost..."
cp $SITES_AVAILABLE/default $SITES_AVAILABLE/$SITE
	# Adding ServerName directive
	sed -i "3i\\\tServerName $SITE.$SUFFIX" $SITES_AVAILABLE/$SITE
	# Modifying DocumentRoot and Directory directives
	sed -i "s:/var/www:/var/www/html/$SITE:g" $SITES_AVAILABLE/$SITE
cd $SITES_ENABLED && ln -s $SITES_AVAILABLE/$SITE $SITES_ENABLED/$SITE
apache2ctl graceful

echo -e "\tAdding hosts file entry..."
	sed -i "1i127.0.0.1\t$SITE.$SUFFIX" /etc/hosts

# MySQL queries
DB_CREATE="CREATE DATABASE IF NOT EXISTS $SITE CHARACTER SET utf8 COLLATE utf8_general_ci;"
DB_PERMS="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON $SITE.* TO 'root'@'localhost' IDENTIFIED BY 'root'"
SQL="${DB_CREATE}${DB_PERMS}"

echo -e "\tCreating MySQL database..."
	$MYSQL -uroot -proot -e "$SQL"

echo -e $GREEN_START"Site is available at http://$SITE.$SUFFIX"$GREEN_END

# echo -e "Reverting permissions for security reasons..."
# chmod go-w sites/default
# chmod go-w sites/default/settings.php