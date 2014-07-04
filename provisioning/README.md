provisioning/install.sh
-----------------------

- Enable Apache mod_rewrite if it is disabled
- Check that the php5-curl package is installed, or it'll install it to support Guzzle support in D8
- Allow you to customize the name of the new Drupal docroot
- Download Drupal (if needed) and set up a new docroot for you, with correct permissions to start the installer
- Create the required Apache vhost and tweak your hosts file accordingly
- Create a MySQL database

The script assumes that your MySQL credentials are root/root and that you're downloading the latest Drupal 8 dev release to set up a new docroot under _/var/www/html_. Feel free to modify the script according to your preferences.

The *install.sh* script supports passing arguments to load a specific Drush make file. There's a make file named **dev.make** that ships with the repo. It loads some handy dev modules (devel, coder, webprofiler...) that most Drupal 8 developers will need. You can invoke it by passing **--dev** (or simply **dev**) to the script.

<code>$ install d8 --dev</code>

The other make file does NOT ship with the repo and you'll have to create it manually:

* Place it under the *provisioning* directory
* Name it **custom.make** for the install script to find it

The intent of supporting a custom make file is that you can come up with your own requirements and quickly spin up a D8 instance with just what you need. That file has been added to *.gitignore* so that it won't be wiped at any point in time. You can invoke it by passing **--custom** (or simply **custom**) to the script.

<code>$ install d8 --custom</code>

provisioning/delete.sh
----------------------

Does the exact opposite and cleans up everything (docroot, DB, vhost, hosts entry).

provisioning/common
-------------------

Simple admin script to store common variables.
