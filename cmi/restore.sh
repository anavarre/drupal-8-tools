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

# Docroot selection
echo -e "${BLUE}What Drupal docroot should we work with?${COLOR_ENDING} "
cd ${WEBROOT}

# List all existing docroots
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

# (Multi)site selection
echo -e "${BLUE}What site should we trigger a restore for?${COLOR_ENDING} "
cd ${WEBROOT}/${DOCROOT}/sites/

# List all existing (multi)sites
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

# Check if backup dir exists
if [[ ! -d ${WEBROOT}/${DOCROOT}/backup ]]; then
	echo -e "${RED}There is no backup directory and we can't thus find your database and CMI backups! Aborting...${COLOR_ENDING}"
	exit 1
else
	echo -e "Backup directory exists. Proceeding..."
fi

# Database selection
echo -e "${BLUE}What database should we trigger a MySQL restore for?${COLOR_ENDING} "

# List all existing databases
PS3="Enter database number: "
SQL=$(mysql -u root -proot -e "SHOW DATABASES;")
DATABASES=( $( for DB in ${SQL} ; do echo ${DB} | egrep -v "(test|*_schema|Database)" ; done ) )
select DB in "${DATABASES[@]}"; do
	break;
done

echo -e "${GREEN}Database is: ${DB}${COLOR_ENDING}"

# Start restore operations
echo -e "${BLUE}Starting restore...${COLOR_ENDING} "

read -p "Are you sure? This will overwrite your database and CMI files. [Y/N] "
if [[ ${REPLY} =~ ^[Nn]$ ]]; then
	echo -e "${GREEN}Back to the comfort zone. Aborting.${COLOR_ENDING}"
	exit 0
fi

# List all existing backups
cd ${WEBROOT}/${DOCROOT}/backup/
PS3="Enter backup number: "
BACKUP=(`ls *.tar.gz`)
select BKP in "${BACKUP[@]}"; do
	if [[ ! -f ${WEBROOT}/${DOCROOT}/sites/${SITE}/settings.php ]]; then
		echo -e "${RED}There is no settings.php file in this directory. Aborting!${COLOR_ENDING}"
		exit 1
	fi
	break;
done

# Uncompress data
tar -xzf ${BKP}

# Trigger MySQL site restore
DUMP=`ls ${BKP} | sed 's/.tar.gz//g'`
cd ${DUMP}
	echo -e "\tRestoring MySQL database..."
mysql -u root -proot -h localhost ${DB} < ${DB}.sql

# Determine CMI's config dir.
cd ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/
CONFIG=`(find . -maxdepth 1 -type d -name "config_*" | sed 's/^.\{2\}//')`

# Set permissions for active config
	echo -e "\tSetting correct permissions for active directory..."
chmod g+w ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/${CONFIG}/active

# Delete current active config
	echo -e "\tDeleting current CMI configuration..."
rm -Rf ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/${CONFIG}/active/

# CMI restore
	echo -e "\tRestoring CMI backup files"
cp -R ${WEBROOT}/${DOCROOT}/backup/${DUMP}/active ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/${CONFIG}/

# Set permissions back
	echo -e "\tSetting correct permissions for YAML files..."
chmod g+w ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/${CONFIG}/active/*.yml

echo -e "${GREEN}Both the database and CMI files have been successfully restored!${COLOR_ENDING}"