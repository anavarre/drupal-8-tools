#!/usr/bin/env bash

# Invoke the script from anywhere (e.g .bashrc alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Required source files
source ${DIR}/common
source ${DIR}/functions.sh

# Deployment functions
is_root

# Requirements
mod_rewrite
head_symlink

# Prepare deployment
installer
checkout

# Prepare Drupal files
settings_php
settings_files
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
