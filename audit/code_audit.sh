#!/usr/bin/env bash

# Invoke the script from anywhere (e.g .bashrc alias).
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/common

# Make sure only root can execute the script.
if [[ "$(whoami)" != "root" ]]; then
  echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
  exit 1
fi

# Set path to scan
MODULE_PATH=$1
if [[ -z $1 ]]; then
  echo -n "Enter the Unix path for the module to scan: "
  read VALID_PATH
fi

if [[ ! -d ${VALID_PATH} ]]; then
  echo -e "${RED}This is not a valid Unix path! Aborting...${COLOR_ENDING}"
  exit 0
fi

MODULE=`basename $(pwd)`
BLOCK_FILES="$(pwd)/src/Plugin/Block/*"
BLOCKBASE="BlockBase"
FORMSTATEINTERFACE="FormStateInterface"
BLOCK_ANNOTATION="@Block"
BLOCK_ID="id = "
BLOCK_LABEL="admin_label = "
BLOCK_CATEGORY="category = "
BLOCKFORM="blockForm"
BLOCKSUBMIT="blockSubmit"
BUILD="build"

# File structure
echo -e "${BLUE}Auditing block file structure...${COLOR_ENDING}"
# namespace
if [[ -z $(grep -w --color=auto "namespace Drupal\\\\${MODULE}\\\Plugin\\\Block;" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The namespace is missing or incorrectly set!${COLOR_ENDING}"
  echo "The correct namespace to use is: Drupal\\${MODULE}\Plugin\Block;"
else
  echo "The namespace is correct."
fi

# BlockBase use statement
if [[ -z $(grep -w --color=auto "use Drupal\\\Core\\\Block\\\\${BLOCKBASE};" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The use statement for ${BLOCKBASE} is missing or incorrectly set!${COLOR_ENDING}"
  echo "The correct use statement to invoke is: Drupal\\Core\\Block\\${BLOCKBASE};"
else
  echo "The use statement for ${BLOCKBASE} is correct."
fi

# FormStateInterface use statement
if [[ -z $(grep -w --color=auto "use Drupal\\\Core\\\Form\\\\${FORMSTATEINTERFACE};" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The use statement for ${FORMSTATEINTERFACE} is missing or incorrectly set!${COLOR_ENDING}"
  echo "The correct use statement to invoke is: Drupal\\Core\\Block\\${FORMSTATEINTERFACE};"
else
  echo "The use statement for ${FORMSTATEINTERFACE} is correct."
fi

# @Block annotation
if [[ -z $(grep -w --color=auto "${BLOCK_ANNOTATION}(" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The ${BLOCK_ANNOTATION} annotation is missing or not correctly set!${COLOR_ENDING}"
  echo "The correct annotation to use is: ${BLOCK_ANNOTATION}"
else
  echo "The ${BLOCK_ANNOTATION} annotation exists."
fi

# @Block id annotation
if [[ -z $(grep -w --color=auto "${BLOCK_ID}" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The ${BLOCK_ANNOTATION} id annotation is missing or not correctly set!${COLOR_ENDING}"
  echo "The correct id annotation to use is: ${BLOCK_ID}"
else
  echo "The ${BLOCK_ANNOTATION} id annotation exists."
fi

# @Block admin_label annotation
if [[ -z $(grep -w --color=auto "${BLOCK_LABEL}" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The ${BLOCK_ANNOTATION} label annotation is missing or not correctly set!${COLOR_ENDING}"
  echo "The correct label annotation to use is: ${BLOCK_LABEL}"
else
  echo "The ${BLOCK_ANNOTATION} label annotation exists."
fi

# @Block category annotation
if [[ -z $(grep -w --color=auto "${BLOCK_CATEGORY}" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The ${BLOCK_ANNOTATION} category annotation is missing or not correctly set!${COLOR_ENDING}"
  echo "The correct category annotation to use is: ${BLOCK_CATEGORY}"
else
  echo "The ${BLOCK_ANNOTATION} category annotation exists."
fi

# Block methods
echo -e "${BLUE}Auditing block methods...${COLOR_ENDING}"
# blockForm()
if [[ -z $(grep -w --color=auto "public function ${BLOCKFORM}(\$form, ${FORMSTATEINTERFACE} \$form_state)" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The ${BLOCKFORM}() function is missing or not correctly instantiated!${COLOR_ENDING}"
  echo -e "\tThe correct implementation is: ${GREEN}public function ${BLOCKFORM}(\$form, FormStateInterface \$form_state)${COLOR_ENDING}"
else
  echo "The ${BLOCKFORM}() function seems to be correctly implemented."
fi

# blockSubmit()
if [[ -z $(grep -w --color=auto "public function ${BLOCKSUBMIT}(\$form, ${FORMSTATEINTERFACE} \$form_state)" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The ${BLOCKSUBMIT}() function is missing or not correctly instantiated!${COLOR_ENDING}"
  echo -e "\tThe correct implementation is: ${GREEN}public function ${BLOCKSUBMIT}(\$form, ${FORMSTATEINTERFACE} \$form_state)${COLOR_ENDING}"
else
  echo "The ${BLOCKSUBMIT}() function seems to be correctly implemented."
fi

# build()
if [[ -z $(grep -w --color=auto "public function ${BUILD}()" ${BLOCK_FILES}) ]]; then
  echo -e "${RED}The ${BUILD}() function is missing or not correctly instantiated!${COLOR_ENDING}"
  echo -e "\tThe correct implementation is: ${GREEN}public function ${BUILD}()${COLOR_ENDING}"
else
    echo "The ${BUILD}() function seems to be correctly implemented."
fi

