#!/bin/bash

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

# Functions array.
declare -A FUNCTIONS
FUNCTIONS=(
  [cache_get]="\$this->cache()->get(\$key);"
  [check_plain]="String::checkPlain"
  [drupal_add_css]="drupal_process_attached()"
  [drupal_add_js]="drupal_process_attached()"
  [drupal_add_library]="drupal_process_attached()"
  [drupal_build_form]="\Drupal::formBuilder()->buildForm()"
  [drupal_form_submit]="\Drupal::formBuilder()->submitForm()"
  [drupal_get_form]="\Drupal::formBuilder()->getForm()"
  [drupal_goto]="\$this->redirect(\$route_name);"
  [drupal_prepare_form]="\Drupal::formBuilder()->prepareForm()"
  [drupal_process_form]="\Drupal::formBuilder()->processForm()"
  [drupal_rebuild_form]="\Drupal::formBuilder()->rebuildForm()"
  [drupal_redirect_form]="\Drupal::formBuilder()->redirectForm()"
  [drupal_retrieve_form]="\Drupal::formBuilder()->retrieveForm()"
  [drupal_validate_form]="\Drupal::formBuilder()->validateForm()"
  [field_info_instances]="EntityManager::getFieldDefinitions()"
  [field_views_field_label]="TBD: https://drupal.org/node/2231863"
  [filter_xss]="Namespace: use Drupal\Component\Utility\Xss; / Method: Xss::filter()"
  [filter_xss_admin]="Namespace: use Drupal\Component\Utility\Xss; / Method: Xss::filterAdmin()"
  [filter_xss_bad_protocol]="TODO"
  [form_clear_error]="\Drupal::formBuilder()->clearErrors()"
  [form_error]="\Drupal::formBuilder()->setError()"
  [form_execute_handlers]="\Drupal::formBuilder()->executeHandlers()"
  [form_get_cache]="\Drupal::formBuilder()->getCache()"
  [form_get_error]="\Drupal::formBuilder()->getError()"
  [form_get_errors]="\Drupal::formBuilder()->getErrors()"
  [form_set_cache]="\Drupal::formBuilder()->setCache()"
  [form_set_error]="\Drupal::formBuilder()->setErrorByName()"
  [form_state_defaults]="\Drupal::formBuilder()->getFormStateDefaults()"
  [get_t]="TODO"
  [hook_date_formats]="system.date_format.{string}.yml"
  [hook_date_formats_alter]="system.date_format.{string}.yml"
  [hook_date_format_types]="system.date_format.{string}.yml"
  [hook_library_info]="{module}.libraries.yml"
  [image_style_path]="buildUri()"
  [image_style_url]="buildUrl()"
  [image_style_flush]="flush()"
  [image_style_create_derivative]="createDerivative()"
  [image_style_transform_dimensions]="transformDimensions()"
  [image_style_path_token]="getPathToken()"
  [image_style_deliver]="deliver()"
  [l]="\$this->l('title', \$route_name);"
  [language]="LanguageManagerInterface::getCurrentLanguage"
  [language_default]="LanguageManagerInterface::getDefaultLanguage"
  [language_list]="LanguageManagerInterface::getLanguages"
  [language_load]="LanguageManagerInterface::getLanguage"
  [language_default_locked_languages]="LanguageManagerInterface::getDefaultLockedLanguages"
  [language_types_get_default]="LanguageManagerInterface::getLanguageTypes"
  [language_name]="LanguageManagerInterface::getLanguageName"
  [language_is_locked]="LanguageManagerInterface::isLanguageLocked"
  [language_negotiation_get_switch_links]="LanguageManagerInterface::getLanguageSwitchLinks"
  [language_types_info]="ConfigurableLanguageManagerInterface::getDefinedLanguageTypesInfo"
  [language_types_get_configurable]="ConfigurableLanguageManagerInterface::getLanguageTypes"
  [language_types_disable]="Removed, no actual use case for this."
  [language_update_locked_weights]="ConfigurableLanguageManagerInterface::updateLockedLanguageWeights"
  [language_types_get_all]="ConfigurableLanguageManagerInterface::getDefinedLanguageTypes"
  [language_types_set]="LanguageNegotiatorInterface::updateConfiguration"
  [language_types_initialize]="LanguageNegotiatorInterface::initializeType"
  [language_negotiation_method_get_first]="LanguageNegotiatorInterface::getPrimaryNegotiationMethod"
  [language_negotiation_method_enabled]="LanguageNegotiatorInterface::isNegotiationMethodEnabled"
  [language_negotiation_purge]="LanguageNegotiatorInterface::purgeConfiguration"
  [language_negotiation_set]="LanguageNegotiatorInterface::saveConfiguration"
  [language_negotiation_info]="LanguageNegotiatorInterface::getNegotiationMethods"
  [language_negotiation_method_invoke]="LanguageNegotiator::negotiateLanguage (protected)"
  [language_url_split_prefix]="LanguageNegotiationFoo::processInbound"
  [language_from_selected]="LanguageNegotiationSelected::getLangcode"
  [language_from_browser]="LanguageNegotiationBrowser::getLangcode"
  [language_from_user]="LanguageNegotiationUser::getLangcode"
  [language_from_user_admin]="LanguageNegotiationUserAdmin::getLangcode"
  [language_from_session]="LanguageNegotiationSession::getLangcode"
  [language_from_url]="LanguageNegotiationFoo::getLangcode"
  [language_url_fallback]="LanguageNegotiationFooFallback::getLangcode"
  [language_switcher_session]="LanguageNegotiationSession::getLanguageSwitchLinks"
  [language_switcher_url]="LanguageNegotiationFoo::getLanguageSwitchLinks"
  [language_url_rewrite_session]="LanguageNegotiationSession::processOutbound"
  [list_themes]="\$theme_handler = \Drupal::service('theme_handler');"
  [module_exists]="\$this->moduleHandler()->moduleExists(\$m);"
  [st]="TODO"
  [system_get_date_format]="Drupal 8's Configuration API"
  [system_get_date_formats]="Drupal 8's Configuration API"
  [system_get_date_types]="Drupal 8's Configuration API"
  [t]="\$this->t('some text');"
  [theme_enable]="\$theme_handler->enable(\$theme_list);"
  [theme_disable]="\$theme_handler->disable(\$theme_list);"
  [theme_link]="#type' => 'link'"
  [url]="\$this->url(\$route_name);"
  [user_access]="User::hasPermission()"
)

echo -e "${BLUE}Auditing functions...${COLOR_ENDING}"

for API_FUNCTIONS in ${!FUNCTIONS[@]}; do
  if [[ $(find ${VALID_PATH} -type f ! -name "*.css" ! -name "*.js" | xargs grep -s -E " ${API_FUNCTIONS}[(*$]") ]]; then
    echo -e "\tReplace ${RED}${API_FUNCTIONS}()${COLOR_ENDING} by ${GREEN}${FUNCTIONS[${API_FUNCTIONS}]}${COLOR_ENDING}"
  fi
done

echo -e "${BLUE}Auditing superglobals...${COLOR_ENDING}"

# Superglobals array.
declare -A SUPERGLOBALS
SUPERGLOBALS=(
  [\$_POST]="TODO"
  [\$_SERVER]="TODO"
)

# Searching for $GET_['q'] doesn't work well as an array key. Hardcoding it for now.
if [[ $(find ${VALID_PATH} -type f ! -name "*.css" ! -name "*.js" | xargs grep "\$_GET\['q']") ]]; then
  echo -e "\tReplace ${RED}\$_GET['q']${COLOR_ENDING} by ${GREEN}current_path()${COLOR_ENDING}"
fi

for API_SGLOBALS in ${!SUPERGLOBALS[@]}; do
  if [[ $(find ${VALID_PATH} -type f ! -name "*.css" ! -name "*.js" | xargs grep "${API_SGLOBALS}") ]]; then
    echo -e "\tReplace ${RED}${API_SGLOBALS}()${COLOR_ENDING} by ${GREEN}${SUPERGLOBALS[${API_SGLOBALS}]}${COLOR_ENDING}"
  fi
done 
