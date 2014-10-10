#!/bin/bash

# Invoke the script from anywhere (e.g .bashrc alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[94m"
COLOR_ENDING="\033[0m"

SOURCE="${DIR}/HEAD"
DEST="${PWD}"
FILES="composer.json composer.lock .csslintrc .editorconfig .eslintignore .eslintrc example.gitignore .gitattributes index.php README.txt web.config"
SITES="development.services.yml example.settings.local.php example.sites.php README.txt"
DEFAULT="default.settings.php default.services.yml"
LOG="/tmp/core-update-$(date +%F).log"

echo -e "${RED}###########################################################################${COLOR_ENDING}"
echo -e "${RED}# WARNING! You're about to update Drupal. This might result in data loss! #${COLOR_ENDING}"
echo -e "${RED}###########################################################################${COLOR_ENDING}"

echo -e "Current working directory: ${PWD}\n"

read -p "Are you sure? [Y/N] "
if [[ ${REPLY} =~ ^[Nn]$ ]]; then
  echo -e "${GREEN}Back to the comfort zone. Aborting.${COLOR_ENDING}"
  exit 0
elif [[ ${REPLY} =~ ^[Yy]$ ]]; then
  echo -e "${BLUE}Starting Drupal Core update...${COLOR_ENDING}"
else
  echo "Sorry, the only accepted input characters are [Yy/Nn]. Aborting..."
  exit 0
fi

if [[ ! -f ${DEST}/core/includes/bootstrap.inc ]]; then
  echo "Oops! This doesn't look like a Drupal docroot. Aborting..."
  exit 0
else
  echo -e "*\n**\n***\nDrupal Core update started: $(date)\n***\n**\n*" >> ${LOG}

  echo "The below files will stay untouched:"
  echo -e "\t.htaccess"
  echo -e "\trobots.txt"

  if [[ -d ${DEST}/sites/default ]]; then
    for DEFAULT_FILE in ${DEFAULT}; do
      echo -e "\t${DEST}/sites/default/${DEFAULT_FILE}"
    done
  fi
  
  echo -e "\t/modules"
  echo -e "\t/profiles"
  echo -e "\t/themes"

echo -e "\n#############################" >> ${LOG} 2>&1
  echo "# Updating docroot files... #" >> ${LOG} 2>&1
  echo -e "#############################\n" >> ${LOG} 2>&1
  for FILE in ${FILES}; do
    rsync -azP --delete --checksum ${SOURCE}/${FILE} ${DEST}/${FILE} >> ${LOG} 2>&1
  done
  
  echo -e "\n##############################"  >> ${LOG} 2>&1
  echo "# Updating core directory... #"  >> ${LOG} 2>&1
  echo -e "##############################\n"  >> ${LOG} 2>&1
  rsync -azP --delete --checksum ${SOURCE}/core/ ${DEST}/core/ >> ${LOG} 2>&1
  
  echo -e "\n###############################"  >> ${LOG} 2>&1
  echo "# Updating sites directory... #"  >> ${LOG} 2>&1
  echo -e "###############################\n"  >> ${LOG} 2>&1
  for SITES_FILE in ${SITES}; do
  rsync -azP --delete --checksum ${SOURCE}/sites/${SITES_FILE} ${DEST}/sites/${SITES_FILE} >> ${LOG} 2>&1
  done

  if [[ -d ${DEST}/sites/default ]]; then
    for DEFAULT_FILE in ${DEFAULT}; do
      rsync -azP --delete --checksum ${SOURCE}/sites/default/${DEFAULT_FILE} ${DEST}/sites/default/${DEFAULT_FILE} >> ${LOG} 2>&1
    done
  fi
  
  echo -e "\n*\n**\n***\nDrupal Core update completed: $(date)\n***\n**\n*\n" >> ${LOG}
fi

echo -e "${BLUE}Drupal Core update completed!${COLOR_ENDING}"
