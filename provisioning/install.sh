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

# Convert sitename to lowercase if needed.
SITENAME_LOWER="${SITENAME,,}"

mv ${WEBROOT}/${RELEASE} ${WEBROOT}/${SITENAME_LOWER}
chown -R ${PERMS} ${WEBROOT}/${SITENAME_LOWER}
echo -e "${GREEN}Successfully created Drupal docroot under ${WEBROOT}/${SITENAME_LOWER}${COLOR_ENDING}"

echo -e "\tCreating settings.php file..."
cp ${WEBROOT}/${SITENAME_LOWER}/sites/default/default.settings.php ${WEBROOT}/${SITENAME_LOWER}/sites/default/settings.php

echo -e "\tCreating files directory..."
mkdir ${WEBROOT}/${SITENAME_LOWER}/sites/default/files

echo -e "\tSetting correct permissions..."
# Also allows the automatic creation of the translations dir if needed
chmod a+w ${WEBROOT}/${SITENAME_LOWER}/sites/default && chown -R ${PERMS} ${WEBROOT}/${SITENAME_LOWER}/sites/default
chmod 775 ${WEBROOT}/${SITENAME_LOWER}/sites/default/files && chown -R ${PERMS} ${WEBROOT}/${SITENAME_LOWER}/sites/default/files
chmod a+w ${WEBROOT}/${SITENAME_LOWER}/sites/default/settings.php && chown ${PERMS} ${WEBROOT}/${SITENAME_LOWER}/sites/default/settings.php

# Apache setup
echo -e "\tProvisionning Apache vhost..."

# First, determine if we're running Apache 2.2 or 2.4
if [[ -f ${SITES_AVAILABLE}/${APACHE_22_DEFAULT} ]]; then
	cp ${SITES_AVAILABLE}/${APACHE_22_DEFAULT} ${SITES_AVAILABLE}/${SITENAME_LOWER}
	# ServerName directive
	sed -i "3i\\\tServerName ${SITENAME_LOWER}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME_LOWER}
	# Modifying directives
	sed -i "s:/var/www:/${WEBROOT}/${SITENAME_LOWER}:g" ${SITES_AVAILABLE}/${SITENAME_LOWER}
	# Make sure that Drupal's .htaccess clean URLs will work fine
	sed -i "s/AllowOverride None/AllowOverride All/g" ${SITES_AVAILABLE}/${SITENAME_LOWER}

	echo -e "\tEnabling site..."
	a2ensite ${SITENAME_LOWER} > /dev/null 2>&1
else
	cp ${SITES_AVAILABLE}/${APACHE_24_DEFAULT} ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf
	# ServerName directive
	sed -i "11i\\\tServerName ${SITENAME_LOWER}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf
	# ServerAlias directive
	sed -i "12i\\\tServerAlias ${SITENAME_LOWER}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf
	# vHost overrides
	sed -i "16i\\\t<Directory /var/www/>" ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf
    sed -i "17i\\\t\tOptions Indexes FollowSymLinks" ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf
	sed -i "18i\\\t\tAllowOverride All" ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf
	sed -i "19i\\\t\tRequire all granted" ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf
	sed -i "20i\\\t</Directory>" ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf

	# Modifying directives
	sed -i "s:/var/www:/${WEBROOT}/${SITENAME_LOWER}:g" ${SITES_AVAILABLE}/${SITENAME_LOWER}.conf

	echo -e "\tEnabling site..."
	a2ensite ${SITENAME_LOWER}.conf > /dev/null 2>&1
fi

# Restart Apache to apply the new configuration
service apache2 reload > /dev/null 2>&1

echo -e "\tAdding hosts file entry..."
	sed -i "1i127.0.0.1\t${SITENAME_LOWER}.${SUFFIX}" /etc/hosts

# MySQL queries
DB_CREATE="CREATE DATABASE IF NOT EXISTS $SITENAME DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci"
DB_PERMS="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON $SITENAME.* TO 'root'@'localhost' IDENTIFIED BY 'root'"
SQL="${DB_CREATE};${DB_PERMS}"

echo -e "\tCreating MySQL database..."
	$MYSQL -uroot -proot -e "${SQL}"

echo -e "${GREEN}Site is available at http://${SITENAME_LOWER}.${SUFFIX}${COLOR_ENDING}"