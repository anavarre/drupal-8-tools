#!/usr/bin/env bash

# Invoke the script from anywhere (e.g .bashrc alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/common

# Make sure only root can execute the script
if [[ "$(whoami)" != "root" ]]; then
  echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
  exit 1
fi

echo -e "${RED}############################################################${COLOR_ENDING}"
echo -e "${RED}# WARNING! You're about to delete a site and all its data! #${COLOR_ENDING}"
echo -e "${RED}############################################################${COLOR_ENDING}"

SITENAME=$1
if [[ -z $1 ]]; then
  echo -n "Which Drupal docroot should we delete? "
  read SITENAME
fi

read -p "Are you sure? [Y/N] "
if [[ ${REPLY} =~ ^[Nn]$ ]]; then
  echo -e "${GREEN}Back to the comfort zone. Aborting.${COLOR_ENDING}"
  exit 0
elif [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
  echo "Sorry, the only accepted input characters are [Yy/Nn]. Aborting..."
  exit 0
fi

# Docroot exists
if [[ ! -d ${WEBROOT}/${SITENAME} ]]; then
  echo -e "${GREEN}The ${SITENAME} docroot doesn't exist! Aborting.${COLOR_ENDING}"
  exit 0
fi

echo "Deleting Drupal docroot..."
  rm -Rf ${WEBROOT}/${SITENAME}

echo "Deleting Apache vHost..."
  a2dissite ${SITENAME} > /dev/null 2>&1
  service apache2 reload > /dev/null 2>&1

# First, determine if we're running Apache 2.2 or 2.4
if [[ -f ${SITES_AVAILABLE}/${SITENAME} ]]; then
  rm -f ${SITES_AVAILABLE}/${SITENAME}
else
  rm -f ${SITES_AVAILABLE}/${SITENAME}.conf
  rm /var/log/apache2/${SITENAME}-access.log && rm /var/log/apache2/${SITENAME}-error.log
fi

echo "Deleting hosts file entry..."
  sed -i "/${SITENAME}.${SUFFIX}/d" /etc/hosts

echo "Deleting database..."
  ${MYSQL} --defaults-file=${DIR}/.my.conf -e "DROP DATABASE IF EXISTS \`$SITENAME\`"

echo "Deleting Drush alias..."
  rm ${HOMEDIR}/.drush/${SITENAME}.aliases.drushrc.php

# Rebuild Drush command file cache to purge the alias
${DRUSH} -q cc drush

echo -e "${GREEN}Successfully removed http://${SITENAME}.${SUFFIX}${COLOR_ENDING}"
