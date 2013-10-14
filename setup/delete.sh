#!/bin/bash

# Invoke the script from anywhere (e.g .bashrc alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/common

if [ "$(whoami)" != "root" ]; then
	echo -e "${RED_START}You are required to run this script as root or with sudo! Aborting...${RED_END}"
	exit 1
fi

echo -e "${RED_START}############################################################${RED_END}"
echo -e "${RED_START}# WARNING! You're about to delete a site and all its data! #${RED_END}"
echo -e "${RED_START}############################################################${RED_END}"

SITENAME=$1
if [ -z $1 ]; then
	echo -n "Which Drupal docroot should we delete? "
	read SITENAME
fi

read -p "Are you sure? [Y/N] "
if [[ ${REPLY} =~ ^[Nn]$ ]]
then
	echo -e "${GREEN_START}Back to the comfort zone. Aborting.{$GREEN_END}"
	exit 0
fi

# Docroot exists
if [[ ! -d ${WEBROOT}/${SITENAME} ]]; then
	echo -e "${GREEN_START}The ${SITENAME} docroot doesn't exist! Aborting.${GREEN_END}"
	exit 0
fi

echo -e "\tDeleting Drupal docroot..."
	rm -Rf ${WEBROOT}/${SITENAME}

echo -e "\tDeleting Apache vHost..."
	a2dissite ${SITENAME} > /dev/null 2>&1
	service apache2 reload > /dev/null 2>&1
	rm -f ${SITES_AVAILABLE}/${SITENAME}
	
echo -e "\tDeleting hosts file entry..."
	sed -i "/${SITENAME}.${SUFFIX}/d" /etc/hosts

echo -e "\tDeleting database..."
	${MYSQL} -uroot -proot -e "DROP DATABASE IF EXISTS $SITENAME"

echo -e "${GREEN_START}Successfully removed http://${SITENAME}.${SUFFIX}${GREEN_END}"