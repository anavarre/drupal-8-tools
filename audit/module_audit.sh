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
  [_external_url_is_local]="TODO"
  [_module_build_dependencies]="\Drupal::moduleHandler()->buildModuleDependencies(\$modules);"
  [ajax_deliver]="TODO"
  [block_list]="entity_load_multiple_by_properties() - See https://www.drupal.org/node/2291171"
  [block_get_blocks_by_region]="entity_load_multiple_by_properties() - See https://www.drupal.org/node/2291171"
  [cache_get]="\$this->cache()->get(\$key);"
  [check_plain]="String::checkPlain"
  [check_url]="TODO"
  [drupal_add_css]="drupal_process_attached()"
  [drupal_add_http_header]="\$response->headers->set(\$name, \$value);"
  [drupal_add_js]="drupal_process_attached()"
  [drupal_add_library]="drupal_process_attached()"
  [drupal_alter]="\$module_handler->alter(\$type, &\$data, &\$context1 = NULL, &\$context2 = NULL);"
  [drupal_build_form]="\Drupal::formBuilder()->buildForm()"
  [drupal_deliver_html_page]="TODO"
  [drupal_deliver_page]="TODO"
  [drupal_encode_path]="use \Drupal\Component\Utility\UrlHelper; / UrlHelper::encodePath('drupal');"
  [drupal_exit]="throw new ServiceUnavailableHttpException(3, t('Custom message goes here.'));"
  [drupal_form_submit]="\Drupal::formBuilder()->submitForm()"
  [drupal_get_form]="\Drupal::formBuilder()->getForm()"
  [drupal_get_library]="\Drupal::service('library.discovery')->getLibrariesByExtension('module_name') / \Drupal::service('library.discovery')->getLibraryByName('module_name', 'library_name');"
  [drupal_get_query_array]="use \Drupal\Component\Utility\UrlHelper; / parse_str('foo=bar&bar=baz', \$query_array);"
  [drupal_get_query_parameters]="use \Drupal\Component\Utility\UrlHelper; / UrlHelper::filterQueryParameters('foo=bar&bar=baz');"
  [drupal_goto]="\$this->redirect(\$route_name);"
  [drupal_page_header]="TODO"
  [drupal_http_build_query]="TODO"
  [drupal_parse_url]="TODO"
  [drupal_prepare_form]="\Drupal::formBuilder()->prepareForm()"
  [drupal_process_form]="\Drupal::formBuilder()->processForm()"
  [drupal_rebuild_form]="\Drupal::formBuilder()->rebuildForm()"
  [drupal_redirect_form]="\Drupal::formBuilder()->redirectForm()"
  [drupal_retrieve_form]="\Drupal::formBuilder()->retrieveForm()"
  [drupal_send_headers]="TODO"
  [drupal_session_destroy_uid]="SessionManager: \$session_manager = \Drupal::service('session_manager'); / \$session_manager->delete(\$uid);"
  [drupal_session_regenerate]="SessionManager: \$session_manager = \Drupal::service('session_manager'); / \$session_manager->regenerate();"
  [drupal_session_start]="SessionManager: \$session_manager = \Drupal::service('session_manager'); / \$session_manager->start();"
  [drupal_session_started]="SessionManager: \$session_manager = \Drupal::service('session_manager'); / \$session_manager->isStarted();"
  [element_child]="use Drupal\Core\Render\Element; / Element::child('foo');"
  [element_children]="use Drupal\Core\Render\Element; / Element::children(\$elements);"
  [element_get_visible_children]="use Drupal\Core\Render\Element; / Element::getVisibleChildren(\$elements);"
  [element_property]="use Drupal\Core\Render\Element; / Element::property('#markup');"
  [element_properties]="use Drupal\Core\Render\Element; / Element::properties(\$elements['foo']);"
  [element_set_attributes]="use Drupal\Core\Render\Element; / Element::setAttributes(\$elements['foo'], array('#title' => 'Custom title'));"
  [drupal_validate_form]="\Drupal::formBuilder()->validateForm()"
  [field_info_field]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_field_by_id]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_field_by_ids]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_field_map]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_instance]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_instances]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_views_field_label]="TBD: https://www.drupal.org/node/2231863"
  [filter_xss]="use Drupal\Component\Utility\Xss; / Xss::filter()"
  [filter_xss_admin]="use Drupal\Component\Utility\Xss; / Xss::filterAdmin()"
  [filter_xss_bad_protocol]="use \Drupal\Component\Utility\UrlHelper; / UrlHelper::filterBadProtocol('javascript://example.com?foo&bar');"
  [form_clear_error]="\Drupal::formBuilder()->clearErrors()"
  [form_error]="\Drupal::formBuilder()->setError()"
  [form_execute_handlers]="\Drupal::formBuilder()->executeHandlers()"
  [form_get_cache]="\Drupal::formBuilder()->getCache()"
  [form_get_error]="\Drupal::formBuilder()->getError()"
  [form_get_errors]="\Drupal::formBuilder()->getErrors()"
  [form_options_flatten]="use Drupal\Core\Form\OptGroup; / \$flattened_options = OptGroup::flattenOptions(\$options);"
  [form_set_cache]="\Drupal::formBuilder()->setCache()"
  [form_set_error]="\Drupal::formBuilder()->setErrorByName()"
  [form_state_defaults]="\Drupal::formBuilder()->getFormStateDefaults()"
  [get_t]="TODO"
  [hook_date_formats]="system.date_format.{string}.yml"
  [hook_date_formats_alter]="system.date_format.{string}.yml"
  [hook_date_format_types]="system.date_format.{string}.yml"
  [hook_disable]="TODO"
  [hook_drupal_goto_alter]="Event Listener on kernel.response"
  [hook_enable]="TODO"
  [hook_init]="Register EventSubscriber in {module}.services.yml / use Symfony\Component\EventDispatcher\EventSubscriberInterface; / getSubscribedEvents()"
  [hook_library_info]="{module}.libraries.yml"
  [hook_menu]="{module}.local_actions.yml / {module}.local_tasks.yml / {module}.menu_links.yml"
  [hook_menu_site_status_alter]="Register an EventSubscriber"
  [hook_modules_enabled]="TODO"
  [hook_modules_disabled]="TODO"
  [hook_page_delivery_callback_alter]="TODO"
  [hook_url_outbound_alter]="Class implementing OutboundPathProcessorInterface and {module}.services.yml"
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
  [menu_get_active_trail]="\Drupal::service('menu_link.tree')->getActiveTrailIds(\$menu_name);"
  [menu_set_active_item]="\Drupal::service('menu_link.tree')->getActiveTrailIds(\$menu_name);"
  [menu_set_active_trail]="\Drupal::service('menu_link.tree')->getActiveTrailIds(\$menu_name);"
  [module_exists]="\Drupal::moduleHandler()->moduleExists('module_name')"
  [module_invoke]="\$module_handler->invoke(\$module, \$hook, \$args = array())"
  [module_invoke_all]="\Drupal::moduleHandler()->invokeAll(\$hook, \$args = array())"
  [module_hook]="\Drupal::moduleHandler()->implementsHook(\$module, \$hook)"
  [module_implements]="\Drupal::moduleHandler()->getImplementations(\$hook)"
  [module_list]="\$module_handler->setModuleList(array \$module_list = array());"
  [module_load_all]="\Drupal::moduleHandler()->loadAll();"
  [module_load_all(\$bootstrap = NULL)]="\$this->moduleHandler->loadAllIncludes();"
  [module_load_all_includes]="\Drupal::moduleHandler()->loadAllIncludes(\$type, \$name = NULL)"
  [st]="TODO"
  [system_get_date_format]="Drupal 8's Configuration API"
  [system_get_date_formats]="Drupal 8's Configuration API"
  [system_get_date_types]="Drupal 8's Configuration API"
  [system_list]="ModuleHandlerInterface::getModuleList"
  [t]="\$this->t('some text');"
  [theme_enable]="\$theme_handler->enable(\$theme_list);"
  [theme_disable]="\$theme_handler->disable(\$theme_list);"
  [theme_link]="#type' => 'link'"
  [url]="\$this->url(\$route_name);"
  [url_is_external]="use \Drupal\Component\Utility\UrlHelper; / UrlHelper::isExternal('http://www.drupal.org');"
  [user_access]="User::hasPermission()"
  [valid_url]="TODO"
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
