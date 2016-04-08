#!/usr/bin/env bash

# Shared functions
is_root() {
  # Make sure only root can execute the script
  if [[ ! $(id -u) = 0 ]]; then
    echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
    exit 1
  fi
}
