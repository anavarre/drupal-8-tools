#!/usr/bin/env bash

# Invoke the script from anywhere (e.g .bashrc alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Required source files
source ${DIR}/common
source ${DIR}/functions.sh

SITENAME=$1

is_root

warning

docroot_selection
deletion

# Rebuild Drush command file cache to purge the alias
${DRUSH} -q cc drush

echo -e "${GREEN}Successfully removed http://${SITENAME}.${SUFFIX}${COLOR_ENDING}"
