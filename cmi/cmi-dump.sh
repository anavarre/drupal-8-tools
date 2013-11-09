#!/bin/bash

# Invoke the script from anywhere (e.g .bashrc alias).
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source common
source ../colors

# Make sure only root can execute the script.
if [[ "$(whoami)" != "root" ]]; then
	echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
	exit 1
fi

# List all existing docroots
echo -e "${BLUE}What Drupal docroot should we work with?${COLOR_ENDING} "
cd ${WEBROOT}

# Docroot selection
PS3="Enter docroot number: "
CODEBASE=(`ls -d */ | sed s:/::g;`)
select DOCROOT in "${CODEBASE[@]}"; do
	if [[ ! -d ${DOCROOT}/core ]]; then
		echo -e "${RED}There is no Drupal 8 core folder. Aborting!${COLOR_ENDING}"
		exit 1
	fi
	break;
done

echo -e "${GREEN}Docroot is: ${DOCROOT}${COLOR_ENDING}"

# List all existing sites
echo -e "${BLUE}What site should we trigger a backup for?${COLOR_ENDING} "
cd ${WEBROOT}/${DOCROOT}/sites/

# Site selection
PS3="Enter site number: "
DIR=(`ls -d */ | sed s:/::g;`)
select SITE in "${DIR[@]}"; do
	if [[ ! -f ${SITE}/settings.php ]]; then
		echo -e "${RED}There is no settings.php file in this directory. Aborting!${COLOR_ENDING}"
		exit 1
	fi
	break;
done

echo -e "${GREEN}Site is: ${SITE}${COLOR_ENDING}"

exit 0

ACTIVE="(${WEBROOT}/${DOCROOT}/sites/${DIR}/files/config_*/active)"
echo -e "${GREEN}Active CMI directory is sites/${DIR}${ACTIVE}${COLOR_ENDING}"