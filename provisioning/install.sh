#!/usr/bin/env bash

# Invoke the script from anywhere (e.g .bashrc alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Required source files
source "${DIR}"/common
source "${DIR}"/functions.sh

is_root

DOCROOT=$1
OPTION=$2

# Requirements
mod_rewrite
curl
head_symlink

# Prepare deployment
installer
checkout
composer_dependencies

# Prepare Drupal files
settings_files
settings_php
twig_debugging

# Stack configuration
apache
hosts_file
mysql

# Drupal install
drush_alias
drupal_install

# Local setup
dev_mode
make_file
set_permissions

site_check
