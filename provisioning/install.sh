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

##################
# Drupal install #
##################
if [[ $1 == "-d" ]] || [[ $1 == "-c" ]]; then
SITENAME_UPPER=$2
  if [[ -z $2 ]]; then
    echo -n "What should be the name of the new Drupal docroot? "
    read SITENAME_UPPER
  fi
elif [[ $1 == *-* ]]; then
  echo -e "${RED}Only -d (dev make file) or -c (custom make file) parameters are accepted! Aborting.${COLOR_ENDING}"
  exit 0
else
SITENAME_UPPER=$1
  if [[ -z $1 ]]; then
    echo -n "What should be the name of the new Drupal docroot? "
    read SITENAME_UPPER
  fi
fi

# Convert sitename to lowercase if needed.
SITENAME="${SITENAME_UPPER,,}"

# Abort if docroot exists. Else, copy from Git
if [[ -d ${WEBROOT}/${SITENAME} ]]; then
  echo -e "${RED}The ${SITENAME} docroot already exists! Aborting.${COLOR_ENDING}"
  exit 0
else
  echo "Pulling changes from upstream 8.x repo..."
  cd ${GIT} && git pull -q
  cp -R ${GIT}/ ${WEBROOT}/${SITENAME}
fi

echo "Creating settings.php file..."
cp ${WEBROOT}/${SITENAME}/sites/default/default.settings.php ${WEBROOT}/${SITENAME}/sites/default/settings.php

# Apache setup
echo "Provisionning Apache vhost..."

# First, determine if we're running Apache 2.2 or 2.4
if [[ -f ${SITES_AVAILABLE}/${APACHE_22_DEFAULT} ]]; then
  cp ${SITES_AVAILABLE}/${APACHE_22_DEFAULT} ${SITES_AVAILABLE}/${SITENAME}
  # ServerName directive
  sed -i "3i\\\tServerName ${SITENAME}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME}
  # Modifying directives
  sed -i "s:/var/www:/${WEBROOT}/${SITENAME}:g" ${SITES_AVAILABLE}/${SITENAME}
  # Make sure that Drupal's .htaccess clean URLs will work fine
  sed -i "s/AllowOverride None/AllowOverride All/g" ${SITES_AVAILABLE}/${SITENAME}
  
  echo "Enabling site..."
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
  sed -i "s:DocumentRoot /var/www/html:DocumentRoot ${WEBROOT}/${SITENAME}:g" ${SITES_AVAILABLE}/${SITENAME}.conf
  sed -i "s:Directory /var/www/:Directory ${WEBROOT}/${SITENAME}/:g" ${SITES_AVAILABLE}/${SITENAME}.conf
  
  # Custom logging
  sed -i "s:error.log:${SITENAME}-error.log:g" ${SITES_AVAILABLE}/${SITENAME}.conf
  sed -i "s:access.log:${SITENAME}-access.log:g" ${SITES_AVAILABLE}/${SITENAME}.conf
  
  echo "Enabling site..."
  a2ensite ${SITENAME}.conf > /dev/null 2>&1
fi

# Restart Apache to apply the new configuration
service apache2 reload > /dev/null 2>&1

echo "Adding hosts file entry..."
sed -i "1i127.0.0.1\t${SITENAME}.${SUFFIX}" /etc/hosts

# MySQL queries
DB_CREATE="CREATE DATABASE IF NOT EXISTS \`${SITENAME}\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci"
DB_PERMS="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON \`${SITENAME}\`.* TO '${CREDS}'@'${DB_HOST}' IDENTIFIED BY '${CREDS}'"
SQL="${DB_CREATE};${DB_PERMS}"

echo "Creating MySQL database..."
$MYSQL -u${CREDS} -p${CREDS} -e "${SQL}"

# Drush alias
echo "Creating Drush aliases..."

cat <<EOT >> $HOME/.drush/${SITENAME}.aliases.drushrc.php
<?php

\$aliases['local'] = array(                                                                    
 'parent' => '@parent',
 'site' => '${SITENAME}',
 'env' => 'local',
 'root' => '/var/www/html/${SITENAME}',
);
EOT

echo "Running Drupal installation..."

cd ${WEBROOT}/${SITENAME}/sites/default/
drush site-install standard install_configure_form.update_status_module='array(FALSE,FALSE)' -qy --db-url=mysql://${CREDS}:${CREDS}@${DB_HOST}:${DB_PORT}/${SITENAME} --site-name=${SITENAME} --site-mail=${CREDS}@${SITENAME}.${SUFFIX} --account-name=${CREDS} --account-pass=${CREDS} --account-mail=${CREDS}@${SITENAME}.${SUFFIX}

# Disable CSS and JS aggregation
drush @${SITENAME}.${SUFFIX} cset -qy system.performance css.preprocess false --format=yaml
drush @${SITENAME}.${SUFFIX} cset -qy system.performance js.preprocess false --format=yaml

# Load the make file, if any. (-d = dev.make / -c = custom.make)
while getopts ":dc" opt; do
  case $opt in
    d)
      echo "Loading the dev make file..." >&2
      # Drush doesn't place the modules at the right location so we're changing directory manually.
      cd ${WEBROOT}/${SITENAME}
      drush make --no-core -qy ${DIR}/dev.make --contrib-destination=.
      ;;
    c)
      echo "Loading custom make file..." >&2
      cd ${WEBROOT}/${SITENAME}
      drush make --no-core -qy ${DIR}/custom.make --contrib-destination=.
      ;;
  esac
done

echo "Setting correct permissions..."
# Drupal
chmod go-w ${WEBROOT}/${SITENAME}/sites/default
chmod go-w ${WEBROOT}/${SITENAME}/sites/default/settings.php
chmod 777 ${WEBROOT}/${SITENAME}/sites/default/files/
chmod -R 777 ${WEBROOT}/${SITENAME}/sites/default/files/config_*/active
chmod -R 777 ${WEBROOT}/${SITENAME}/sites/default/files/config_*/staging
chown -R ${PERMS} ${WEBROOT}/${SITENAME}
# Drush
chown ${PERMS} $HOME/.drush/${SITENAME}.aliases.drushrc.php
chmod 600 $HOME/.drush/${SITENAME}.aliases.drushrc.php
chmod -R 777 $HOME/.drush/cache

# Rebuild Drush commandfile cache to load the aliases
drush -q cc drush

# Rebuilding Drupal caches
drush -q @${SITENAME}.${SUFFIX} cache-rebuild

if [[ $(curl -sL -w "%{http_code} %{url_effective}\\n" "http://${SITENAME}.${SUFFIX}" -o /dev/null) ]]; then
  echo -e "${GREEN}Site is available at http://${SITENAME}.${SUFFIX}${COLOR_ENDING}"
else
  echo -e "${RED}There has been a problem when accessing the site. Is Apache running?${COLOR_ENDING}"
fi
