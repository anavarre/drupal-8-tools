#!/bin/bash

# Invoke the script from anywhere (e.g .bashrc alias).
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ../colors

# Make sure only root can execute the script.
if [[ "$(whoami)" != "root" ]]; then
	echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
	exit 1
fi

# Set path to scan
MODULE_PATH=$1
if [[ -z $1 ]]; then
  echo -n "Enter the Unix path for the module to scan: "
  # @todo: check that the path is valid.
  read VALID_PATH 
fi

# Functions array.
declare -A FUNCTIONS
FUNCTIONS=(
  [drupal_build_form]="\Drupal::formBuilder()->buildForm()"
  [drupal_form_submit]="\Drupal::formBuilder()->submitForm()"
  [drupal_get_form]="\Drupal::formBuilder()->getForm()"
  [drupal_goto]="$this->redirect($route_name);"
  [drupal_prepare_form]="\Drupal::formBuilder()->prepareForm()"
  [drupal_process_form]="\Drupal::formBuilder()->processForm()"
  [drupal_rebuild_form]="\Drupal::formBuilder()->rebuildForm()"
  [drupal_redirect_form]="\Drupal::formBuilder()->redirectForm()"
  [drupal_retrieve_form]="\Drupal::formBuilder()->retrieveForm()"
  [drupal_validate_form]="\Drupal::formBuilder()->validateForm()"
  [form_clear_error]="\Drupal::formBuilder()->clearErrors()"
  [form_get_cache]="\Drupal::formBuilder()->getCache()"
  [form_get_errors]="\Drupal::formBuilder()->getErrors()"
  [form_get_error]="\Drupal::formBuilder()->getError()"
  [form_error]="\Drupal::formBuilder()->setError()"
  [form_execute_handlers]="\Drupal::formBuilder()->executeHandlers()"
  [form_set_cache]="\Drupal::formBuilder()->setCache()"
  [form_set_error]="\Drupal::formBuilder()->setErrorByName()"
  [form_state_defaults]="\Drupal::formBuilder()->getFormStateDefaults()"
)

echo -e "${BLUE}Auditing functions...${COLOR_ENDING}"

for API_REF in ${!FUNCTIONS[@]}; do
  if [[ $(find ${VALID_PATH} -type f | xargs grep "${API_REF}") ]]; then
    echo -e "\tUpdate ${RED}${API_REF}${COLOR_ENDING} with ${GREEN}${FUNCTIONS[@]}${COLOR_ENDING}"
  fi
done
