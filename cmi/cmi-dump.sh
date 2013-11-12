#!/bin/bash

# Invoke the script from anywhere (e.g .bashrc alias).
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/common
source ${DIR}/../colors

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

# Backup dir exists
if [[ ! -d ${WEBROOT}/${DOCROOT}/backup ]]; then
	echo -e "\t Creating backup directory..."
	mkdir ${WEBROOT}/${DOCROOT}/backup

else
	echo -e "Backup directory already exists. Ignoring..."
fi

echo -e "${BLUE}What database should we create a MySQL dump for?${COLOR_ENDING} "

# Database selection
PS3="Enter database number: "
SQL=$(mysql -u root -proot -e "SHOW DATABASES;")
DATABASES=( $( for DB in ${SQL} ; do echo ${DB} | egrep -v "(test|*_schema|Database)" ; done ) )
select DB in "${DATABASES[@]}"; do
	break;
done

# Creating on-demand backup dir
ONDEMAND=BACKUP_${DB}_${NOW}
mkdir ${WEBROOT}/${DOCROOT}/backup/${ONDEMAND}

# MySQL site backup
mysqldump -u root -proot ${DB} > ${WEBROOT}/${DOCROOT}/backup/${ONDEMAND}/${DB}.sql

# Determine CMI's config dir.
cd ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/
CONFIG=`(find . -maxdepth 1 -type d -name "config_*" | sed 's/^.\{2\}//')`

# CMI backup
cp -R ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/${CONFIG}/active/ ${WEBROOT}/${DOCROOT}/backup/${ONDEMAND}/

# Compressing data
cd ${WEBROOT}/${DOCROOT}/backup/
tar -zcvf ${ONDEMAND}.tar.gz ${ONDEMAND}/
rm -Rf ${ONDEMAND}/

echo -e "${GREEN}Both the database and CMI files have been successfully backed up!${COLOR_ENDING}"