#!/bin/bash

# Invoke the script from anywhere (e.g .bashrc alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/common

# Make sure only root can execute the script
if [[ "$(whoami)" != "root" ]]; then
	echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
	exit 1
fi

################
# REQUIREMENTS #
################

# Enable mod_rewrite if needed
if [[ ! -L /etc/apache2/mods-enabled/rewrite.load ]]; then
	echo "Enabling mod_rewrite..."
	a2enmod rewrite > /dev/null 2>&1
	service apache2 restart
fi

# Guzzle support
for pkg in ${PHP}; do
	if ! dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
		echo -e "\tInstalling $pkg..."
		apt-get -qq install ${pkg}
	fi
done

##################
# Drupal install #
##################
SITENAME=$1
if [[ -z $1 ]]; then
	echo -n "What should be the name of the new Drupal docroot? "
	read SITENAME
fi

# Docroot exists
if [[ -d ${WEBROOT}/${SITENAME} ]]; then
	echo -e "${RED}The ${SITENAME} docroot already exists! Aborting.${COLOR_ENDING}"
	exit 0
fi

# Download archive only if needed
if [[ ! -f ${TMP}/${DRUPAL} ]]; then
	echo "Downloading ${DRUPAL}..."
	wget -P ${TMP} -q http://ftp.drupal.org/files/projects/${DRUPAL}
fi

echo "Unpacking ${DRUPAL}..."
tar -C ${WEBROOT} -xzf ${TMP}/${DRUPAL}

mv ${WEBROOT}/${RELEASE} ${WEBROOT}/${SITENAME}
chown -R $(whoami):$(whoami) ${WEBROOT}/${SITENAME}
echo -e "${GREEN}Successfully created Drupal docroot under ${WEBROOT}/${SITENAME}${COLOR_ENDING}"

echo -e "\tCopying settings.php file..."
cp ${WEBROOT}/${SITENAME}/sites/default/default.settings.php ${WEBROOT}/${SITENAME}/sites/default/settings.php

echo -e "\tSetting correct permissions..."
# Allows to create the files and translations dirs automatically
chmod a+w ${WEBROOT}/${SITENAME}/sites/default
chmod a+w ${WEBROOT}/${SITENAME}/sites/default/settings.php  

# Apache setup
echo -e "\tProvisionning Apache vhost..."

# First, determine if we're running Apache 2.2 or 2.4
if [[ -f ${SITES_AVAILABLE}/${APACHE_22_DEFAULT} ]]; then
	cp ${SITES_AVAILABLE}/${APACHE_22_DEFAULT} ${SITES_AVAILABLE}/${SITENAME}
	# ServerName directive
	sed -i "3i\\\tServerName ${SITENAME}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME}
	# Modifying directives
	sed -i "s:/var/www:/var/www/html/${SITENAME}:g" ${SITES_AVAILABLE}/${SITENAME}
	# Make sure that Drupal's .htaccess clean URLs will work fine
	sed -i "s/AllowOverride None/AllowOverride All/g" ${SITES_AVAILABLE}/${SITENAME}

	echo -e "\tEnabling site..."
	a2ensite ${SITENAME} > /dev/null 2>&1
else
	cp ${SITES_AVAILABLE}/${APACHE_24_DEFAULT} ${SITES_AVAILABLE}/${SITENAME}.conf
	# ServerName directive
	sed -i "11i\\\tServerName ${SITENAME}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME}.conf
	# ServerAlias directive
	sed -i "12i\\\tServerAlias ${SITENAME}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME}.conf
	# vHost overrides
	sed -i "16i\\\t<Directory /var/www/>" ${SITES_AVAILABLE}/${SITENAME}.conf
    sed -i "17i\\\t\tOptions Indexes FollowSymLinks" ${SITES_AVAILABLE}/${SITENAME}.conf
	sed -i "18i\\\t\tAllowOverride All" ${SITES_AVAILABLE}/${SITENAME}.conf
	sed -i "19i\\\t\tRequire all granted" ${SITES_AVAILABLE}/${SITENAME}.conf
	sed -i "20i\\\t</Directory>" ${SITES_AVAILABLE}/${SITENAME}.conf

	# Modifying directives
	sed -i "s:/var/www:/var/www/html/${SITENAME}:g" ${SITES_AVAILABLE}/${SITENAME}.conf

	echo -e "\tEnabling site..."
	a2ensite ${SITENAME}.conf > /dev/null 2>&1
fi

# Restart Apache to apply the new configuration
service apache2 reload > /dev/null 2>&1

echo -e "\tAdding hosts file entry..."
	sed -i "1i127.0.0.1\t${SITENAME}.${SUFFIX}" /etc/hosts

# MySQL queries
DB_CREATE="CREATE DATABASE IF NOT EXISTS $SITENAME DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci"
DB_PERMS="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON $SITENAME.* TO 'root'@'localhost' IDENTIFIED BY 'root'"
SQL="${DB_CREATE};${DB_PERMS}"

echo -e "\tCreating MySQL database..."
	$MYSQL -uroot -proot -e "${SQL}"

echo -e "${GREEN}Site is available at http://${SITENAME}.${SUFFIX}${COLOR_ENDING}"

# echo -e "Reverting permissions for security reasons..."
# chmod go-w sites/default
# chmod go-w sites/default/settings.php
