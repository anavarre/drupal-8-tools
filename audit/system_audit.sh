#!/bin/bash

# Invoke the script from anywhere (e.g .bashrc alias).
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/common

# Make sure only root can execute the script.
if [[ "$(whoami)" != "root" ]]; then
  echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
  exit 1
fi

PHP_MINIMUM="$(php -v | awk '{print $2}' | head -n1 | sed -r 's/.{9}$//')"
DISABLE_FUNCTIONS="$(php -c /etc/php5/cli/php.ini -i | grep disable_functions | awk '{print $3$4}')"

# Drupal 8 requires PHP 5.4.2 at a minimum.
if [[ "${PHP_MINIMUM}" > "5.4.2" ]]; then
  echo -e "PHP version is ${PHP_MINIMUM} ${GREEN}[OK]${COLOR_ENDING}"
else
  echo -e "Your PHP version is too old (${PHP_MINIMUM}). Minimum requirement for Drupal 8 is PHP 5.4.2. ${RED}[ERROR]${COLOR_ENDING}"
fi

# Drush requires PHP's disable_functions to be empty, except for PHP 5.5 - See https://github.com/drush-ops/drush/pull/357
if [[ "${DISABLE_FUNCTIONS}" == "novalue" ]]; then
  echo -e "PHP CLI's disable_functions are turned off ${GREEN}[OK]${COLOR_ENDING}"
else
  echo -e "PHP CLI's disable_functions are turned on and might cause issues with Drush. ${RED}[ERROR]${COLOR_ENDING}"
fi

# @todo
# php date.timezone shouldn't be empty for apache2's php.ini and CLI
