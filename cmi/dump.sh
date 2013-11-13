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

# Store user and group data
PERMS=`stat -c %U:%G ${WEBROOT}/${DOCROOT}/core`

# (Multi)site selection
echo -e "${BLUE}What site should we trigger a backup for?${COLOR_ENDING} "
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

# Create backup dir if needed
if [[ ! -d ${WEBROOT}/${DOCROOT}/backup ]]; then
	echo -e "\t Creating backup directory..."
	mkdir ${WEBROOT}/${DOCROOT}/backup
	chown -R ${PERMS} ${WEBROOT}/${DOCROOT}/backup

else
	echo -e "Backup directory already exists. Ignoring..."
fi

# Database selection
echo -e "${BLUE}What database should we create a MySQL dump for?${COLOR_ENDING} "

# List all existing databases
PS3="Enter database number: "
SQL=$(mysql -u root -proot -e "SHOW DATABASES;")
DATABASES=( $( for DB in ${SQL} ; do echo ${DB} | egrep -v "(test|*_schema|Database)" ; done ) )
select DB in "${DATABASES[@]}"; do
	break;
done

echo -e "${GREEN}Database is: ${DB}${COLOR_ENDING}"

# Start backup operations
echo -e "${BLUE}Starting backup...${COLOR_ENDING} "

# Create on-demand backup dir and add timestamp
ONDEMAND=BACKUP_${DB}_${NOW}
mkdir ${WEBROOT}/${DOCROOT}/backup/${ONDEMAND}
chown -R ${PERMS} ${WEBROOT}/${DOCROOT}/backup/${ONDEMAND}/

# Trigger MySQL site backup
mysqldump -u root -proot ${DB} --add-drop-table > ${WEBROOT}/${DOCROOT}/backup/${ONDEMAND}/${DB}.sql

# Determine CMI's config dir.
cd ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/
CONFIG=`(find . -maxdepth 1 -type d -name "config_*" | sed 's/^.\{2\}//')`

# Trigger CMI files backup
cp -R ${WEBROOT}/${DOCROOT}/sites/${SITE}/files/${CONFIG}/active/ ${WEBROOT}/${DOCROOT}/backup/${ONDEMAND}/

# Set permissions
cd ${WEBROOT}/${DOCROOT}/backup/
chown -R ${PERMS} ${ONDEMAND}/

# Compress data
tar -zcf ${ONDEMAND}.tar.gz ${ONDEMAND}/
rm -Rf ${ONDEMAND}/
chown -R ${PERMS} ${ONDEMAND}.tar.gz

echo -e "${GREEN}Both the database and CMI files have been successfully backed up!${COLOR_ENDING}"