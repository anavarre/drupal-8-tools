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
DATE_TIMEZONE="$(php -c /etc/php5/apache2/php.ini -i | grep date.timezone | awk '{print $3$4}')"
DATE_TIMEZONE_CLI="$(php -c /etc/php5/cli/php.ini -i | grep date.timezone | awk '{print $3$4}')"

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

# date.timezone needs to be set.
if [[ "${DATE_TIMEZONE}" == "novalue" ]] || [[ "${DATE_TIMEZONE_CLI}" == "novalue" ]]; then
  echo -e "PHP's date.timezone is not set. You should check your apache2 and CLI php.ini file settings. ${RED}[ERROR]${COLOR_ENDING}"
else
  echo -e "PHP's date.timezone is set ${GREEN}[OK]${COLOR_ENDING}"
fi
