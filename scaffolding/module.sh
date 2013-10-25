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
NAME_LOWER="${NAME,,}"

# Create module directory.
if [[ -d ${NAME_LOWER} ]]; then
	echo -e "${RED}${NAME_LOWER} directory already exists! Aborting...${COLOR_ENDING}"
	exit 1
else
	echo -e "\tCreating ${NAME_LOWER} directory..."
	mkdir ${NAME_LOWER}
fi

# Offer to create a Controller.
read -p "Create Controller scaffolding? [Y/N] "
if [[ ${REPLY} =~ ^[Yy]$ ]]; then

	if [[ -d ${NAME_LOWER}/lib ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib directory..."
		mkdir ${NAME_LOWER}/lib
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal directory..."
		mkdir ${NAME_LOWER}/lib/Drupal
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER} ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER} directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER} directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Controller ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Controller directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Controller directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Controller
	fi

	# Ensure module's first letter is uppercase.
	NAME_1ST_UP=`sed 's/\(.\)/\U\1/' <<< "${NAME_LOWER}"`
	touch ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Controller/${NAME_1ST_UP}Controller.php
	echo -e "${GREEN}Successfully created Controller scaffolding!${COLOR_ENDING}"
fi

# Offer to create Form config.
read -p "Create Form config scaffolding? [Y/N] "
if [[ ${REPLY} =~ ^[Yy]$ ]]; then

	if [[ -d ${NAME_LOWER}/lib ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib directory..."
		mkdir ${NAME_LOWER}/lib
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal directory..."
		mkdir ${NAME_LOWER}/lib/Drupal
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER} ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER} directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER} directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Form ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Form directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Form directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Form
	fi

	# Ensure module's first letter is uppercase.
	NAME_1ST_UP=`sed 's/\(.\)/\U\1/' <<< "${NAME_LOWER}"`
	touch ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Form/${NAME_1ST_UP}ConfigForm.php
	echo -e "${GREEN}Successfully created Form config scaffolding!${COLOR_ENDING}"
fi

# Offer to create a Block.
read -p "Create Block scaffolding? [Y/N] "
if [[ ${REPLY} =~ ^[Yy]$ ]]; then

	if [[ -d ${NAME_LOWER}/lib ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib directory..."
		mkdir ${NAME_LOWER}/lib
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal directory..."
		mkdir ${NAME_LOWER}/lib/Drupal
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER} ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER} directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER} directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin/Block ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin/Block directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin/Block directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin/Block
	fi

	# Ensure module's first letter is uppercase.
	NAME_1ST_UP=`sed 's/\(.\)/\U\1/' <<< "${NAME_LOWER}"`
	touch ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Plugin/Block/${NAME_1ST_UP}Block.php
	echo -e "${GREEN}Successfully created Block scaffolding!${COLOR_ENDING}"
fi

# Offer to create Tests.
read -p "Create Tests scaffolding? [Y/N] "
if [[ ${REPLY} =~ ^[Yy]$ ]]; then

	if [[ -d ${NAME_LOWER}/lib ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib directory..."
		mkdir ${NAME_LOWER}/lib
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal directory..."
		mkdir ${NAME_LOWER}/lib/Drupal
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER} ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER} directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER} directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}
	fi

	if [[ -d ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Tests ]]; then
		echo -e "\t${BLUE}${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Tests directory already exists! Skipping...${COLOR_ENDING}"
	else
		echo -e "\tCreating ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Tests directory..."
		mkdir ${NAME_LOWER}/lib/Drupal/${NAME_LOWER}/Tests
	fi

	echo -e "${GREEN}Successfully created Tests scaffolding!${COLOR_ENDING}"
fi

#################
# Default files #
#################
if [[ ! -f ${NAME_LOWER}/${NAME_LOWER}.info.yml ]]; then
	echo -e "\tCreating ${NAME}.info.yml..."
	touch ${NAME_LOWER}/${NAME_LOWER}.info.yml
fi

if [[ ! -f ${NAME_LOWER}/${NAME_LOWER}.module ]]; then
	echo -e "\tCreating ${NAME_LOWER}.module..."
	touch ${NAME_LOWER}/${NAME_LOWER}.module
fi

if [[ ! -f ${NAME_LOWER}/${NAME_LOWER}.routing.yml ]]; then
	echo -e "\tCreating ${NAME_LOWER}.routing.yml..."
	touch ${NAME_LOWER}/${NAME_LOWER}.routing.yml
fi

if [[ ! -f ${NAME_LOWER}/${NAME_LOWER}.services.yml ]]; then
	echo -e "\tCreating ${NAME_LOWER}.services.yml..."
	touch ${NAME_LOWER}/${NAME_LOWER}.services.yml
fi

# Generating info.yml default values
cat <<EOT >> ${NAME_LOWER}/${NAME_LOWER}.info.yml
name: ${NAME}
type: module
description: '${DESCRIPTION}.'
core: 8.x
EOT

# Only add package if any was entered.
if [[ ! -z ${PACKAGE} ]]; then
	sed -i "4ipackage: ${PACKAGE}" ${NAME_LOWER}/${NAME_LOWER}.info.yml
fi

#######
# CMI #
#######
if [[ -d ${NAME_LOWER}/config ]]; then
	echo -e "\t${BLUE}${NAME_LOWER}/config directory already exists! Skipping...${COLOR_ENDING}"
else
	echo -e "\tCreating ${NAME_LOWER}/config directory..."
	mkdir ${NAME_LOWER}/config
fi

echo -e "${GREEN}Successfully generated module scaffolding!${COLOR_ENDING}"