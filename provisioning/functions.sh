# Shared functions
is_root() {
  # Make sure only root can execute the script
  if [[ ! $(id -u) = 0 ]]; then
    echo -e "${RED}You are required to run this script as root or with sudo! Aborting...${COLOR_ENDING}"
    exit 1
  fi
}

# Deployment functions

mod_rewrite() {
  # Enable mod_rewrite if needed
  if [[ ! -L /etc/apache2/mods-enabled/rewrite.load ]]; then
    echo "Enabling mod_rewrite..."
    a2enmod rewrite > /dev/null 2>&1
    service apache2 restart
  fi
}

head_symlink() {
  # Make sure the HEAD symbolic link exists
  if [[ ! -L ${DIR}/HEAD ]]; then
    echo "You need to create a HEAD symbolic link from your Drupal checkout in the provisioning directory..."
    exit 1
  fi
}

installer() {
  # @todo: implement --minimal parameter in the installer.
  if [[ ${OPTION} == "-d" ]] || [[ ${OPTION} == "-c" ]]; then
  SITENAME_UPPER=${OPTION}
    if [[ -z ${OPTION} ]]; then
      echo -n "What should be the name of the new Drupal docroot? "
      read SITENAME_UPPER
    fi
  elif [[ ${OPTION} == *-* ]]; then
    echo -e "${RED}Only -d (dev make file) or -c (custom make file) parameters are accepted! Aborting.${COLOR_ENDING}"
    exit 0
  else

  SITENAME_UPPER=${DOCROOT}
    if [[ -z ${DOCROOT} ]]; then
      echo -n "What should be the name of the new Drupal docroot? "
      read SITENAME_UPPER
    fi
  fi

  # Convert sitename to lowercase if needed.
  SITENAME="${SITENAME_UPPER,,}"
}

checkout() {
  # Abort if docroot exists. Else, copy from Git
  if [[ -d ${WEBROOT}/${SITENAME} ]]; then
    echo -e "${RED}The ${SITENAME} docroot already exists! Aborting.${COLOR_ENDING}"
    exit 0
  else
    echo "Pulling changes from upstream repo..."
    cd ${GIT} && git pull -q
    cp -R ${GIT}/ ${WEBROOT}/${SITENAME}
  fi
}

settings_php() {
  echo "Creating settings.php file..."
  cp ${WEBROOT}/${SITENAME}/sites/default/default.settings.php ${WEBROOT}/${SITENAME}/sites/default/settings.php
  sed -i'' '639,641 s/# //' ${WEBROOT}/${SITENAME}/sites/default/settings.php

  echo "Adding configuration for trusted hostnames..."
  cat <<EOT >> ${WEBROOT}/${SITENAME}/sites/default/settings.php

  \$settings['trusted_host_patterns'] = array(
  '^${SITENAME}\\.${SUFFIX}$',
  );

EOT
}

settings_files() {
  echo "Creating settings.local.php file..."
  cp ${WEBROOT}/${SITENAME}/sites/example.settings.local.php ${WEBROOT}/${SITENAME}/sites/default/settings.local.php

  echo "Creating settings.testing.php file..." # See https://www.drupal.org/node/2230005
  touch ${WEBROOT}/${SITENAME}/sites/default/settings.testing.php

  echo "Creating services.yml file..."
  cp ${WEBROOT}/${SITENAME}/sites/default/default.services.yml ${WEBROOT}/${SITENAME}/sites/default/services.yml
}

twig_debugging() {
  echo "Turning on Twig debugging mode..."
  sed -i "s/debug: false/debug: true/g" ${WEBROOT}/${SITENAME}/sites/default/services.yml
  sed -i "s/auto_reload: null/auto_reload: true/g" ${WEBROOT}/${SITENAME}/sites/default/services.yml
  sed -i "s/cache: true/cache: false/g" ${WEBROOT}/${SITENAME}/sites/default/services.yml
}

apache() {
  # Apache setup
  echo "Provisionning Apache vhost..."

  # First, determine if we're running Apache 2.2 or 2.4
  if [[ -f ${SITES_AVAILABLE}/${APACHE_22_DEFAULT} ]]; then
    cp ${SITES_AVAILABLE}/${APACHE_22_DEFAULT} ${SITES_AVAILABLE}/${SITENAME}
    # ServerName directive
    sed -i "3i\\\tServerName ${SITENAME}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME}
    # Modifying directives
    sed -i "s:/var/www:/${WEBROOT}/${SITENAME}:g" ${SITES_AVAILABLE}/${SITENAME}
    # Make sure that Drupal's .htaccess clean URLs will work fine
    sed -i "s/AllowOverride None/AllowOverride All/g" ${SITES_AVAILABLE}/${SITENAME}

    echo "Enabling site..."
    a2ensite ${SITENAME} > /dev/null 2>&1
  else
    cp ${SITES_AVAILABLE}/${APACHE_24_DEFAULT} ${SITES_AVAILABLE}/${SITENAME}.conf
    # ServerName directive
    sed -i "11i\\\tServerName ${SITENAME}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME}.conf
    # ServerAlias directive
    sed -i "12i\\\tServerAlias ${SITENAME}.${SUFFIX}" ${SITES_AVAILABLE}/${SITENAME}.conf
    # vHost overrides
    sed -i "16i\\\t<Directory /var/www/>" ${SITES_AVAILABLE}/${SITENAME}.conf
      sed -i "17i\\\t\tOptions Indexes FollowSymLinks" ${SITES_AVAILABLE}/${SITENAME}.conf
    sed -i "18i\\\t\tAllowOverride All" ${SITES_AVAILABLE}/${SITENAME}.conf
    sed -i "19i\\\t\tRequire all granted" ${SITES_AVAILABLE}/${SITENAME}.conf
    sed -i "20i\\\t</Directory>" ${SITES_AVAILABLE}/${SITENAME}.conf

    # Modifying directives
    sed -i "s:DocumentRoot /var/www/html:DocumentRoot ${WEBROOT}/${SITENAME}:g" ${SITES_AVAILABLE}/${SITENAME}.conf
    sed -i "s:Directory /var/www/:Directory ${WEBROOT}/${SITENAME}/:g" ${SITES_AVAILABLE}/${SITENAME}.conf

    # Custom logging
    sed -i "s:error.log:${SITENAME}-error.log:g" ${SITES_AVAILABLE}/${SITENAME}.conf
    sed -i "s:access.log:${SITENAME}-access.log:g" ${SITES_AVAILABLE}/${SITENAME}.conf

    echo "Enabling site..."
    a2ensite ${SITENAME}.conf > /dev/null 2>&1
  fi

  # Restart Apache to apply the new configuration
  service apache2 reload > /dev/null 2>&1
}

hosts_file() {
  echo "Adding hosts file entry..."
  sed -i "1i127.0.0.1\t${SITENAME}.${SUFFIX}" /etc/hosts
}

mysql() {
  # MySQL queries - See https://www.drupal.org/node/1314214
  DB_CREATE="CREATE DATABASE IF NOT EXISTS \`${SITENAME}\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci"

  # Custom DB queries if we're using Linux
  if [[ $(uname -s) == 'Linux' ]]; then
    DB_PERMS="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON \`${SITENAME}\`.* TO '${CREDS}'@'${DB_HOST}' IDENTIFIED BY '${CREDS}'"
    SQL="${DB_CREATE};${DB_PERMS}"

    echo "Creating MySQL database..."
    $MYSQL --defaults-file=${DIR}/.my.conf -e "${SQL}"

  # Custom DB queries if we're using a Mac
  elif [[ $(uname -s) == 'Darwin' ]]; then
    DB_PERMS="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON \`${SITENAME}\`.* TO '${DD_CREDS}'@'${DB_HOST}' IDENTIFIED BY '${DD_CREDS}'"
    SQL="${DB_CREATE};${DB_PERMS}"

    echo "Creating MySQL database..."
    $MYSQL --defaults-file=${DIR}/.mydevdesktop.conf -e "${SQL}"
  fi
}

drush_alias() {
  echo "Creating Drush alias..."

  cat <<EOT >> ${HOMEDIR}/.drush/${SITENAME}.aliases.drushrc.php
  <?php

  \$aliases['${SITENAME}.${SUFFIX}'] = array(
    'site' => '${SITENAME}',
    'env' => '${SUFFIX}',
    'root' => '${WEBROOT}/${SITENAME}',
    'uri' => '${SITENAME}.${SUFFIX}',
  );

EOT

  echo "Setting Drush permissions..."
  # Drush
  chown ${PERMS} ${HOMEDIR}/.drush/${SITENAME}.aliases.drushrc.php
  chmod 600 ${HOMEDIR}/.drush/${SITENAME}.aliases.drushrc.php
  chmod -R 777 ${HOMEDIR}/.drush/cache/
}

drupal_install() {
  echo "Running Drupal installation..."

  cd ${WEBROOT}/${SITENAME}/sites/default/

  # Custom installation if we're using Linux
  if [[ $(uname -s) == 'Linux' ]]; then
    ${DRUSH} site-install standard install_configure_form.update_status_module='array(FALSE,FALSE)' -qy --db-url=mysql://${CREDS}:${CREDS}@${DB_HOST}:${DB_PORT}/${SITENAME} --site-name=${SITENAME} --site-mail=${CREDS}@${SITENAME}.${SUFFIX} --account-name=${CREDS} --account-pass=${CREDS} --account-mail=${CREDS}@${SITENAME}.${SUFFIX}

  # Custom installation if we're using a Mac
  elif [[ $(uname -s) == 'Darwin' ]]; then
    ${DRUSH} site-install standard install_configure_form.update_status_module='array(FALSE,FALSE)' -qy --db-url=mysql://${DD_CREDS}@${DB_HOST}:${DB_PORT}/${SITENAME} --site-name=${SITENAME} --site-mail=${CREDS}@${SITENAME}.${SUFFIX} --account-name=${CREDS} --account-pass=${CREDS} --account-mail=${CREDS}@${SITENAME}.${SUFFIX}
  fi

  # Now that Drupal is installed, rebuild Drush commandfile cache to load the alias.
  ${DRUSH} -q cc drush
}

dev_mode() {
  echo "Setting up development mode..."
  # Enable Simpletest
  cd ../ ; mkdir simpletest ; chmod -R 777 simpletest
  ${DRUSH} --root=${WEBROOT}/${SITENAME} en -qy simpletest

  # Disable CSS and JS aggregation
  ${DRUSH} --root=${WEBROOT}/${SITENAME} cset -qy system.performance css.preprocess false --format=yaml
  ${DRUSH} --root=${WEBROOT}/${SITENAME} cset -qy system.performance js.preprocess false --format=yaml
}

make_file() {
  # Load the make file, if any. (-d = dev.make / -c = custom.make)
  while getopts ":dc" opt; do
    case $opt in
      d)
        echo "Loading the dev make file..." >&2
        # Drush doesn't place the modules at the right location so we're changing directory manually.
        cd ${WEBROOT}/${SITENAME}
        ${DRUSH} make --no-core -qy ${DIR}/dev.make --contrib-destination=.
        ;;
      c)
        echo "Loading custom make file..." >&2
        cd ${WEBROOT}/${SITENAME}
        ${DRUSH} make --no-core -qy ${DIR}/custom.make --contrib-destination=.
        ;;
    esac
  done
}

set_permissions() {
  echo "Setting correct permissions..."
  # Drupal
  chmod go-w ${WEBROOT}/${SITENAME}/sites/default
  chmod go-w ${WEBROOT}/${SITENAME}/sites/default/settings.php
  chmod go-w ${WEBROOT}/${SITENAME}/sites/default/services.yml
  chmod 777 ${WEBROOT}/${SITENAME}/sites/default/files/
  chmod -R 777 ${WEBROOT}/${SITENAME}/sites/default/files/config_*/staging
  # Supposedly, the below perms are too open, but it's the only way I found to fix broken image styles.
  chmod 777 ${WEBROOT}/${SITENAME}/sites/default/files/styles
  chown -R ${PERMS} ${WEBROOT}/${SITENAME}
}

site_check() {
  # Rebuilding Drupal caches
  ${DRUSH} --root=${WEBROOT}/${SITENAME} cache-rebuild -q

  if [[ $(curl -sL -w "%{http_code} %{url_effective}\\n" "http://${SITENAME}.${SUFFIX}" -o /dev/null) ]]; then
    echo -e "${GREEN}Site is available at http://${SITENAME}.${SUFFIX}${COLOR_ENDING}"
  else
    echo -e "${RED}There has been a problem when accessing the site. Is Apache running?${COLOR_ENDING}"
  fi
}

# Deletion functions

warning() {
  echo -e "${RED}############################################################${COLOR_ENDING}"
  echo -e "${RED}# WARNING! You're about to delete a site and all its data! #${COLOR_ENDING}"
  echo -e "${RED}############################################################${COLOR_ENDING}"
}

docroot_selection() {
  if [[ -z ${SITENAME} ]]; then
    echo -n "Which Drupal docroot should we delete? "
    read SITENAME
  fi

  read -p "Are you sure? [Y/N] "
  if [[ ${REPLY} =~ ^[Nn]$ ]]; then
    echo -e "${GREEN}Back to the comfort zone. Aborting.${COLOR_ENDING}"
    exit 0
  elif [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
    echo "Sorry, the only accepted input characters are [Yy/Nn]. Aborting..."
    exit 0
  fi
}

deletion() {
  # Docroot exists
  if [[ ! -d ${WEBROOT}/${SITENAME} ]]; then
    echo -e "${GREEN}The ${SITENAME} docroot doesn't exist! Aborting.${COLOR_ENDING}"
    exit 0
  fi

  echo "Deleting Drupal docroot..."
    rm -Rf ${WEBROOT}/${SITENAME}

  echo "Deleting Apache vHost..."
    a2dissite ${SITENAME} > /dev/null 2>&1
    service apache2 reload > /dev/null 2>&1

  # First, determine if we're running Apache 2.2 or 2.4
  if [[ -f ${SITES_AVAILABLE}/${SITENAME} ]]; then
    rm -f ${SITES_AVAILABLE}/${SITENAME}
  else
    rm -f ${SITES_AVAILABLE}/${SITENAME}.conf
    rm /var/log/apache2/${SITENAME}-access.log && rm /var/log/apache2/${SITENAME}-error.log
  fi

  echo "Deleting hosts file entry..."
    sed -i "/${SITENAME}.${SUFFIX}/d" /etc/hosts

  echo "Deleting database..."
    ${MYSQL} --defaults-file=${DIR}/.my.conf -e "DROP DATABASE IF EXISTS \`$SITENAME\`"

  echo "Deleting Drush alias..."
    rm ${HOMEDIR}/.drush/${SITENAME}.aliases.drushrc.php
}
