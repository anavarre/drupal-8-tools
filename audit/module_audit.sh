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

#############
# FUNCTIONS #
#############
echo -e "${BLUE}Auditing functions...${COLOR_ENDING}"

declare -A FUNCTIONS
FUNCTIONS=(
  [_field_sort_items_value_helper]="_field_multiple_value_form_sort_helper()"
  [_external_url_is_local]="TODO"
  [_module_build_dependencies]="\Drupal::moduleHandler()->buildModuleDependencies(\$modules)"
  [_update_fetch_data]="UpdateProcessor::fetchData() / \Drupal::service('update.processor')->fetchData();"
  [_update_refresh]="UpdateManager::refreshUpdateData() / \Drupal::service('update.manager')->refreshUpdateData();"
  [ajax_deliver]="TODO"
  [block_list]="entity_load_multiple_by_properties() - See https://www.drupal.org/node/2291171"
  [block_get_blocks_by_region]="entity_load_multiple_by_properties() - See https://www.drupal.org/node/2291171"
  [cache_get]="\$this->cache()->get(\$key)"
  [check_plain]="\Drupal\Component\Utility\String::checkPlain()﻿"
  [check_url]="TODO"
  [comment_count_unpublished]="CommentStorage::getUnapprovedCount()"
  [comment_get_display_page]="CommentStorage::getDisplayOrdinal()"
  [comment_get_display_ordinal]="CommentStorage::getDisplayOrdinal()"
  [comment_get_recent]="Removed. To render a list of recent comments, check the 'comments_recent' view."
  [comment_get_thread]="CommentStorage::loadThread()"
  [comment_new_page_count]="CommentStorage::getNewCommentPageNumber()"
  [comment_num_new]="CommentManager::getCountNewComments(\$entity, \$field_name, \$timestamp)"
  [current_path]="Replaced by the <current> route - See https://www.drupal.org/node/2382211"
  [decode_entities]="String::decodeEntities()"
  [drupal_add_css]="drupal_process_attached()"
  [drupal_add_http_header]="\$response->headers->set(\$name, \$value)"
  [drupal_add_js]="drupal_process_attached()"
  [drupal_add_library]="drupal_process_attached()"
  [drupal_alter]="\$module_handler->alter(\$type, &\$data, &\$context1 = NULL, &\$context2 = NULL)"
  [drupal_basename]="FileSystem::basename()"
  [drupal_build_form]="\Drupal::formBuilder()->buildForm()"
  [drupal_chmod]="FileSystem::chmod()"
  [drupal_clean_css_identifier]="use Drupal\Component\Utility\Html; / Html::cleanCssIdentifier($foo);"
  [drupal_convert_to_utf8]="Unicode::convertToUtf8()"
  [drupal_deliver_html_page]="TODO"
  [drupal_deliver_page]="TODO"
  [drupal_dirname]="FileSystem::dirname()"
  [drupal_encode_path]="UrlHelper::encodePath('drupal')"
  [drupal_exit]="throw new ServiceUnavailableHttpException(3, t('Custom message goes here.'));"
  [drupal_form_submit]="\Drupal::formBuilder()->submitForm()"
  [drupal_get_form]="\Drupal::formBuilder()->getForm()"
  [drupal_get_library]="\Drupal::service('library.discovery')->getLibrariesByExtension('module_name') / \Drupal::service('library.discovery')->getLibraryByName('module_name', 'library_name')"
  [drupal_get_query_array]="use \Drupal\Component\Utility\UrlHelper; / parse_str('foo=bar&bar=baz', \$query_array)"
  [drupal_get_query_parameters]="UrlHelper::filterQueryParameters('foo=bar&bar=baz')"
  [drupal_get_title]="Titles (static or dynamic) are now defined on routes - See https://www.drupal.org/node/2067859"
  [drupal_goto]="\$this->redirect(\$route_name)"
  [drupal_html_class]="use Drupal\Component\Utility\Html; / Html::getClass($foo);"
  [drupal_html_id]="use Drupal\Component\Utility\Html; / Html::getId($foo);"
  [drupal_html_to_text]="MailManagerInterface::mail() method - \Drupal::service('plugin.manager.mail')->mail($module, $key, $to, $langcode);"
  [drupal_http_build_query]="use Drupal\Component\Utility\UrlHelper; / UrlHelper::buildQuery"
  [drupal_http_request]="Use the Guzzle HTTP client library"
  [drupal_is_cli]="if (PHP_SAPI === 'cli') { // Do stuff }"
  [drupal_is_front_page]="\$is_front = \Drupal::service('path.matcher')->isFrontPage();"
  [drupal_json_decode]="use Drupal\Component\Serialization\Json; / \$data = Json::decode(\$json);"
  [drupal_json_encode]="use Drupal\Component\Serialization\Json; / \$json = Json::encode(\$data);"
  [drupal_mail]="MailManagerInterface::mail() method - \Drupal::service('plugin.manager.mail')->mail($module, $key, $to, $langcode);"
  [drupal_match_path]="\Drupal\Core\Path\PathMatcherInterface::matchPath()"
  [drupal_mkdir]="FileSystem::mkdir()"
  [drupal_move_uploaded_file]="FileSystem::moveUploadedFile()"
  [drupal_page_header]="TODO"
  [drupal_parse_url]="TODO"
  [drupal_prepare_form]="\Drupal::formBuilder()->prepareForm()"
  [drupal_process_form]="\Drupal::formBuilder()->processForm()"
  [drupal_realpath]="FileSystem::realpath()"
  [drupal_rebuild_form]="\Drupal::formBuilder()->rebuildForm()"
  [drupal_redirect_form]="\Drupal::formBuilder()->redirectForm()"
  [drupal_render_page]="There is no direct equivalent in Drupal 8. See https://www.drupal.org/node/2337551"
  [drupal_retrieve_form]="\Drupal::formBuilder()->retrieveForm()"
  [drupal_rmdir]="FileSystem::rmdir()"
  [drupal_schema_fields_sql]="Developers should use \Drupal::database()->merge() , the Entity API  or one of the provided services, like key value"
  [drupal_send_headers]="TODO"
  [drupal_session_destroy_uid]="SessionManager: \$session_manager = \Drupal::service('session_manager') / \$session_manager->delete(\$uid)"
  [drupal_session_regenerate]="SessionManager: \$session_manager = \Drupal::service('session_manager') / \$session_manager->regenerate()"
  [drupal_session_start]="SessionManager: \$session_manager = \Drupal::service('session_manager') / \$session_manager->start()"
  [drupal_session_started]="SessionManager: \$session_manager = \Drupal::service('session_manager') / \$session_manager->isStarted()"
  [drupal_set_title]="Titles (static or dynamic) are now defined on routes - See https://www.drupal.org/node/2067859"
  [drupal_strlen]="Unicode::strlen()"
  [drupal_strtolower]="Unicode::strtolower()"
  [drupal_strtoupper]="Unicode::strtoupper()"
  [drupal_substr]="Unicode::substr()"
  [drupal_tempnam]="FileSystem::tempnam()"
  [drupal_truncate_bytes]="Unicode::truncateBytes()"
  [drupal_ucfirst]="Unicode::ucfirst()"
  [drupal_unlink]="FileSystem::unlink()"
  [drupal_validate_form]="\Drupal::formBuilder()->validateForm()"
  [drupal_validate_utf8]="Unicode::validateUtf8()"
  [drupal_wrap_mail]="MailManagerInterface::mail() method - \Drupal::service('plugin.manager.mail')->mail($module, $key, $to, $langcode);"
  [drupal_write_record]="Developers should use \Drupal::database()->merge(), the Entity API or one of the provided services, like key value"
  [element_child]="Element::child('foo')"
  [element_children]="Element::children(\$elements)"
  [element_get_visible_children]="Element::getVisibleChildren(\$elements)"
  [element_property]="Element::property('#markup')"
  [element_properties]="Element::properties(\$elements['foo'])"
  [element_set_attributes]="Element::setAttributes(\$elements['foo'], array('#title' => 'Custom title'))"
  [field_attach_extract_form_values]="Use the Entity API instead: https://drupal.org/developing/api/entity"
  [field_attach_form]="Use the Entity API instead: https://drupal.org/developing/api/entity"
  [field_attach_form_validate]="Use the Entity API instead: https://drupal.org/developing/api/entity"
  [field_form_get_state]="WidgetBaseInterface::getWidgetState()"
  [field_form_set_state]="WidgetBaseInterface::setWidgetState()"
  [field_info_field]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_field_by_id]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_field_by_ids]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_field_map]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_instance]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_info_instances]="See https://www.drupal.org/node/2167167 and https://www.drupal.org/node/2260037"
  [field_views_field_label]="TBD: https://www.drupal.org/node/2231863"
  [file_htaccess_lines]="FileStorage::htaccessLines(FALSE);"
  [file_stream_wrapper_valid_scheme]="FileSystem::validScheme()"
  [file_uri_scheme]="FileSystem::uriScheme()"
  [filter_xss]="Xss::filter()"
  [filter_xss_admin]="Xss::filterAdmin()"
  [filter_xss_bad_protocol]="UrlHelper::filterBadProtocol('javascript://example.com?foo&bar')"
  [form_clear_error]="\Drupal::formBuilder()->clearErrors()"
  [form_error]="\Drupal::formBuilder()->setError()"
  [form_execute_handlers]="\Drupal::formBuilder()->executeHandlers()"
  [form_get_cache]="\Drupal::formBuilder()->getCache()"
  [form_get_error]="\Drupal::formBuilder()->getError()"
  [form_get_errors]="\Drupal::formBuilder()->getErrors()"
  [form_load_include]="$form_state->loadInclude()"
  [form_options_flatten]="\$flattened_options = OptGroup::flattenOptions(\$options)"
  [form_set_cache]="\Drupal::formBuilder()->setCache()"
  [form_set_error]="\Drupal::formBuilder()->setErrorByName()"
  [form_set_value]="\Drupal::formBuilder()->setValue(\$element, \$value, \$form_state);"
  [form_state_defaults]="\Drupal::formBuilder()->getFormStateDefaults()"
  [form_state_values_clean]="$form_state->cleanValues()"
  [format_plural]="\Drupal::translation()->formatPlural() or \Drupal::service('date.formatter')->formatInterval() - See https://www.drupal.org/node/2173787"
  [get_t]="TODO"
  [hook_boot]="Create a mymodule.services.yml file and register an Event Subscriber. All details at https://www.drupal.org/node/1909596"
  [hook_comment_publish]="See https://www.drupal.org/node/2296867"
  [hook_comment_unpublish]="See https://www.drupal.org/node/2296867"
  [hook_date_formats]="system.date_format.{string}.yml"
  [hook_date_formats_alter]="system.date_format.{string}.yml"
  [hook_date_format_types]="system.date_format.{string}.yml"
  [hook_disable]="TODO"
  [hook_drupal_goto_alter]="Event Listener on kernel.response"
  [hook_enable]="TODO"
  [hook_field_attach_form]="Use the Entity API instead: https://drupal.org/developing/api/entity"
  [hook_field_attach_form_values]="Use the Entity API instead: https://drupal.org/developing/api/entity"
  [hook_file_download_access]="FileAccessController"
  [hook_init]="Register EventSubscriber in {module}.services.yml / use Symfony\Component\EventDispatcher\EventSubscriberInterface; / getSubscribedEvents()"
  [hook_library_alter]="hook_library_info_alter()"
  [hook_library_info]="{module}.libraries.yml"
  [hook_menu]="{module}.local_actions.yml / {module}.local_tasks.yml / {module}.menu_links.yml"
  [hook_menu_link_alter]="hook_menu_link_content_presave(\$entity)"
  [hook_menu_link_insert]="hook_menu_link_content_insert(\$entity)"
  [hook_menu_link_update]="hook_menu_link_content_update(\$entity)"
  [hook_menu_link_delete]="hook_menu_link_content_delete(\$entity)"
  [hook_menu_site_status_alter]="Register an EventSubscriber"
  [hook_modules_enabled]="TODO"
  [hook_modules_disabled]="TODO"
  [hook_node_validate]="See https://www.drupal.org/node/2420295"
  [hook_node_submit]="See https://www.drupal.org/node/2420295"
  [hook_page_alter]="TODO - See https://www.drupal.org/node/2357755"
  [hook_page_build]="TODO - See https://www.drupal.org/node/2357755"
  [hook_page_delivery_callback_alter]="TODO"
  [hook_url_outbound_alter]="Class implementing OutboundPathProcessorInterface and {module}.services.yml"
  [image_style_path]="buildUri()"
  [image_style_url]="buildUrl()"
  [image_style_flush]="flush()"
  [image_style_create_derivative]="createDerivative()"
  [image_style_transform_dimensions]="transformDimensions()"
  [image_style_path_token]="getPathToken()"
  [image_style_deliver]="deliver()"
  [l]="use Drupal\Core\Url; / \$internal_link = \$this->l(t('Book admin'), Url::fromRoute('book.admin')); / \$external_link = \$this->l(t('External link'), Url::fromUri('http://www.example.com/'));"
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
  [list_themes]="\$theme_handler = \Drupal::service('theme_handler')"
  [menu_get_active_trail]="\Drupal::service('menu_link.tree')->getActiveTrailIds(\$menu_name)"
  [menu_link_content_uninstall]=""
  [menu_set_active_item]="\Drupal::service('menu_link.tree')->getActiveTrailIds(\$menu_name)"
  [menu_set_active_trail]="\Drupal::service('menu_link.tree')->getActiveTrailIds(\$menu_name)"
  [mime_header_decode]="Unicode::mimeHeaderDecode()"
  [mime_header_encode]="Unicode::mimeHeaderEncode()"
  [module_exists]="\Drupal::moduleHandler()->moduleExists('module_name')"
  [module_invoke]="\$module_handler->invoke(\$module, \$hook, \$args = array())"
  [module_invoke_all]="\Drupal::moduleHandler()->invokeAll(\$hook, \$args = array())"
  [module_hook]="\Drupal::moduleHandler()->implementsHook(\$module, \$hook)"
  [module_implements]="\Drupal::moduleHandler()->getImplementations(\$hook)"
  [module_list]="\$module_handler->setModuleList(array \$module_list = array())"
  [module_load_all]="\Drupal::moduleHandler()->loadAll(); / module_load_all(\$bootstrap = NULL)] => \$this->moduleHandler->loadAllIncludes();"
  [module_load_all_includes]="\Drupal::moduleHandler()->loadAllIncludes(\$type, \$name = NULL)"
  [node_load]="\Drupal\node\Entity\Node::load()"
  [node_type_get_types]="\Drupal\node\Entity\NodeType::loadMultiple()"
  [request_path] = "\Drupal\Core\Url::fromRoute('<current>');"
  [st]="TODO"
  [system_get_date_format]="Drupal 8's Configuration API"
  [system_get_date_formats]="Drupal 8's Configuration API"
  [system_get_date_types]="Drupal 8's Configuration API"
  [system_list]="ModuleHandlerInterface::getModuleList"
  [t]="\$this->t('some text')"
  [taxonomy_get_tree]="\$tree = \Drupal::entityManager()->getStorage('taxonomy_term')->loadTree(\$vid, \$parent, \$max_depth, \$load_entities);"
  [taxonomy_term_load_children]="\$parents = \Drupal::entityManager()->getStorage('taxonomy_term')->loadChildren(\$tid);"
  [taxonomy_term_load_parents]="\$parents = \Drupal::entityManager()->getStorage('taxonomy_term')->loadParents(\$tid);"
  [taxonomy_term_load_parents_all]="\$parents = \Drupal::entityManager()->getStorage('taxonomy_term')->loadParentsAll(\$tid);"
  [theme_enable]="\$theme_handler->enable(\$theme_list)"
  [theme_disable]="\$theme_handler->disable(\$theme_list)"
  [theme_link]="#type' => 'link'"
  [truncate_utf8]="Unicode::truncate()"
  [unicode_check]="Unicode::check()"
  [url]="use Drupal\Core\Url; / \$internal_link = \$this->l(t('Book admin'), Url::fromRoute('book.admin')); / \$external_link = \$this->l(t('External link'), Url::fromUri('http://www.example.com/'));"
  [url_is_external]="UrlHelper::isExternal('http://www.drupal.org')"
  [user_access]="User::hasPermission()"
  [user_load_multiple]="\Drupal\user\Entity\User::loadMultiple()"
  [valid_url]="TODO"
  [views_get_applicable_views]="TBD"
)

for API_FUNCTIONS in ${!FUNCTIONS[@]}; do
  if [[ $(find ${VALID_PATH} -type f ! -name "*.css" ! -name "*.js" | xargs grep -s -E " ${API_FUNCTIONS}[(*$]") ]]; then
    echo -e "\tReplace ${RED}${API_FUNCTIONS}()${COLOR_ENDING} by ${GREEN}${FUNCTIONS[${API_FUNCTIONS}]}${COLOR_ENDING}"
  fi
done

#############
# CONSTANTS #
#############
echo -e "${BLUE}Auditing constants...${COLOR_ENDING}"

declare -A CONSTANTS
CONSTANTS=(
  [COMMENT_FORM_BELOW]="CommentItem::FORM_BELOW"
  [COMMENT_FORM_SEPARATE_PAGE]="CommentItem::FORM_SEPARATE_PAGE"
  [COMMENT_MODE_FLAT]="CommentManagerInterface::COMMENT_MODE_FLAT"
  [MENU_MAX_DEPTH]="MenuLinkTreeInterface::maxDepth() to retrieve the value or MenuTreeStorage::MAX_DEPTH for the default storage max depth"
  [MENU_VISIBLE_IN_BREADCRUMB]="Breadcrumbs are no longer defined as menu links - See https://www.drupal.org/node/2098323"
  [MENU_NORMAL_ITEM]="TODO"
  [MENU_SUGGESTED_ITEM]="TODO"
  [MENU_PREFERRED_LINK]="TODO"
  [MENU_LINKS_TO_PARENT]="No replacement"
  [MENU_VISIBLE_IN_TREE]="No replacement"
  [MENU_IS_ROOT]="No replacement"
  [PREG_CLASS_UNICODE_WORD_BOUNDARY]="Unicode::PREG_CLASS_WORD_BOUNDARY"
  [UNICODE_ERROR]="Unicode::STATUS_ERROR"
  [UNICODE_MULTIBYTE]="Unicode::STATUS_MULTIBYTE"
  [UNICODE_SINGLEBYTE]="Unicode::STATUS_SINGLEBYTE"
  )

for API_CONSTANTS in ${!CONSTANTS[@]}; do
  if [[ $(find ${VALID_PATH} -type f ! -name "*.css" ! -name "*.js" | xargs grep "${API_CONSTANTS}") ]]; then
    echo -e "\tReplace ${RED}${API_CONSTANTS}()${COLOR_ENDING} by ${GREEN}${CONSTANTS[${API_CONSTANTS}]}${COLOR_ENDING}"
  fi
done

################
# GLOBALS #
################
echo -e "${BLUE}Auditing globals...${COLOR_ENDING}"

declare -A GLOBALS
GLOBALS=(
  [\$user]="\Drupal::currentUser"
  [\$multibyte]="Unicode::getStatus() / Unicode::setStatus($status)"
)

for API_GLOBALS in ${!GLOBALS[@]}; do
  if [[ $(find ${VALID_PATH} -type f ! -name "*.css" ! -name "*.js" | xargs grep "${API_GLOBALS}") ]]; then
    echo -e "\tReplace ${RED}${API_GLOBALS}()${COLOR_ENDING} by ${GREEN}${GLOBALS[${API_GLOBALS}]}${COLOR_ENDING}"
  fi
done

################
# SUPERGLOBALS #
################
echo -e "${BLUE}Auditing superglobals...${COLOR_ENDING}"

declare -A SUPERGLOBALS
SUPERGLOBALS=(
  [\$_POST]="TODO"
  [\$_SERVER]="TODO"
)

# Searching for $GET_['q'] doesn't work well as an array key. Hardcoding it for now.
if [[ $(find ${VALID_PATH} -type f ! -name "*.css" ! -name "*.js" | xargs grep "\$_GET\['q']") ]]; then
  echo -e "\tReplace ${RED}\$_GET['q']${COLOR_ENDING} by ${GREEN}<current> route - See https://www.drupal.org/node/2382211${COLOR_ENDING}"
fi

for API_SGLOBALS in ${!SUPERGLOBALS[@]}; do
  if [[ $(find ${VALID_PATH} -type f ! -name "*.css" ! -name "*.js" | xargs grep "${API_SGLOBALS}") ]]; then
    echo -e "\tReplace ${RED}${API_SGLOBALS}()${COLOR_ENDING} by ${GREEN}${SUPERGLOBALS[${API_SGLOBALS}]}${COLOR_ENDING}"
  fi
done
