#!/bin/bash

# Invoke the script from anywhere (e.g .bashrc alias).
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/common

# Make sure only root can execute the script.
if [[ "$(whoami)" != "root" ]]; then
	echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
	exit 1
fi

# Fill-in module details.
NAME=$1
DESCRIPTION=$2
PACKAGE=$3

if [[ -z $1 ]] && [[ -z $2 ]] && [[ -z $3 ]]; then
	echo -n "Module name (required): "
	read NAME
	
	echo -n "Description (required): "
	read DESCRIPTION

	echo -n "Package (optional): "
	read PACKAGE
fi

########################
# Dependency Injection #
########################
read -p "Module scaffolding will be generated under $(pwd). Should we proceed? [Y/N] "
if [[ ${REPLY} =~ ^[Nn]$ ]]; then
	echo -e "Understood. Where should we create this module, then? "
	read NEW_PATH
fi

# Change directory if needed.
if [[ ! -z ${NEW_PATH} ]]; then
	cd ${NEW_PATH}
	echo -e "${GREEN}New scaffolding path is ${NEW_PATH}${COLOR_ENDING}"
else
	echo -e "${GREEN}Generating scaffolding under $(pwd)${COLOR_ENDING}" 
fi

# Convert module name to lowercase.
NAME="${NAME,,}"

# Create module directory.
if [[ -d ${NAME} ]]; then
	echo -e "${RED}${NAME} directory already exists! Aborting...${COLOR_ENDING}"
	exit 1
else
	echo -e "\tCreating ${NAME} directory..."
	mkdir ${NAME}
fi

# Offer to create a Controller.
read -p "Create Controller scaffolding? [Y/N] "
if [[ ${REPLY} =~ ^[Yy]$ ]]; then

	if [[ -d ${NAME}/lib ]]; then
		echo -e "\t${BLUE}${NAME}/lib directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib directory..."
		mkdir ${NAME}/lib
	fi

	if [[ -d ${NAME}/lib/Drupal ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal directory..."
		mkdir ${NAME}/lib/Drupal
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME} ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME} directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME} directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME}/Controller ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME}/Controller directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME}/Controller directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}/Controller
	fi

	# Ensure module's first letter is uppercase.
	NAME_1ST_UP=`sed 's/\(.\)/\U\1/' <<< "${NAME}"`
	touch ${NAME}/lib/Drupal/${NAME}/Controller/${NAME_1ST_UP}Controller.php
	echo -e "${GREEN}Successfully created Controller scaffolding!${COLOR_ENDING}"
fi

# Offer to create Form config.
read -p "Create Form config scaffolding? [Y/N] "
if [[ ${REPLY} =~ ^[Yy]$ ]]; then

	if [[ -d ${NAME}/lib ]]; then
		echo -e "\t${BLUE}${NAME}/lib directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib directory..."
		mkdir ${NAME}/lib
	fi

	if [[ -d ${NAME}/lib/Drupal ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal directory..."
		mkdir ${NAME}/lib/Drupal
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME} ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME} directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME} directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME}/Form ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME}/Form directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME}/Form directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}/Form
	fi

	# Ensure module's first letter is uppercase.
	NAME_1ST_UP=`sed 's/\(.\)/\U\1/' <<< "${NAME}"`
	touch ${NAME}/lib/Drupal/${NAME}/Form/${NAME_1ST_UP}ConfigForm.php
	echo -e "${GREEN}Successfully created Form config scaffolding!${COLOR_ENDING}"
fi

# Offer to create a Block.
read -p "Create Block scaffolding? [Y/N] "
if [[ ${REPLY} =~ ^[Yy]$ ]]; then

	if [[ -d ${NAME}/lib ]]; then
		echo -e "\t${BLUE}${NAME}/lib directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib directory..."
		mkdir ${NAME}/lib
	fi

	if [[ -d ${NAME}/lib/Drupal ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal directory..."
		mkdir ${NAME}/lib/Drupal
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME} ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME} directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME} directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME}/Plugin ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME}/Plugin directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME}/Plugin directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}/Plugin
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME}/Plugin/Block ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME}/Plugin/Block directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME}/Plugin/Block directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}/Plugin/Block
	fi

	# Ensure module's first letter is uppercase.
	NAME_1ST_UP=`sed 's/\(.\)/\U\1/' <<< "${NAME}"`
	touch ${NAME}/lib/Drupal/${NAME}/Plugin/Block/${NAME_1ST_UP}Block.php
	echo -e "${GREEN}Successfully created Block scaffolding!${COLOR_ENDING}"
fi

# Offer to create Tests.
read -p "Create Tests scaffolding? [Y/N] "
if [[ ${REPLY} =~ ^[Yy]$ ]]; then

	if [[ -d ${NAME}/lib ]]; then
		echo -e "\t${BLUE}${NAME}/lib directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib directory..."
		mkdir ${NAME}/lib
	fi

	if [[ -d ${NAME}/lib/Drupal ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal directory..."
		mkdir ${NAME}/lib/Drupal
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME} ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME} directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME} directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}
	fi

	if [[ -d ${NAME}/lib/Drupal/${NAME}/Tests ]]; then
		echo -e "\t${BLUE}${NAME}/lib/Drupal/${NAME}/Tests directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME}/lib/Drupal/${NAME}/Tests directory..."
		mkdir ${NAME}/lib/Drupal/${NAME}/Tests
	fi

	echo -e "${GREEN}Successfully created Tests scaffolding!${COLOR_ENDING}"
fi

#################
# Default files #
#################
if [[ ! -f ${NAME}/${NAME}.info.yml ]]; then
	echo -e "\tCreating ${NAME}.info.yml..."
	touch ${NAME}/${NAME}.info.yml
fi

if [[ ! -f ${NAME}/${NAME}.module ]]; then
	echo -e "\tCreating ${NAME}.module..."
	touch ${NAME}/${NAME}.module
fi

if [[ ! -f ${NAME}/${NAME}.routing.yml ]]; then
	echo -e "\tCreating ${NAME}.routing.yml..."
	touch ${NAME}/${NAME}.routing.yml
fi

if [[ ! -f ${NAME}/${NAME}.services.yml ]]; then
	echo -e "\tCreating ${NAME}.services.yml..."
	touch ${NAME}/${NAME}.services.yml
fi

# Generating info.yml default values
cat <<EOT >> ${NAME}/${NAME}.info.yml
name: ${NAME}
type: module
description: '${DESCRIPTION}.'
core: 8.x
EOT

# Only add package if any was entered.
if [[ ! -z ${PACKAGE} ]]; then
	sed -i "4ipackage: ${PACKAGE}" ${NAME}/${NAME}.info.yml
fi

#######
# CMI #
#######
if [[ -d ${NAME}/config ]]; then
	echo -e "\t${BLUE}${NAME}/config directory already exists! Skipping...${COLOR_ENDING}"
else
	echo -e "\tCreating ${NAME}/config directory..."
	mkdir ${NAME}/config
fi

echo -e "${GREEN}Successfully generated module scaffolding!${COLOR_ENDING}"