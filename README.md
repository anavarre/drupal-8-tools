Drupal 8 Tools
==============

This is a placeholder for simple D8 goodies that will hopefully help you speed up recurring tasks.

scripts/install.sh
-------------------

Caution: this script has only been tested with Ubuntu 12.04. It might break with any other configuration.

Instead of using any *AMP stack, VM or container, why not simply use a shell script to provision a Drupal site? This is what this script is all about. Within a few seconds it will:

- Enable Apache mod_rewrite if it is disabled
- Check that the php5-curl package is installed, or it'll install it to provide Guzzle support in D8
- Allow you to customize the name of the new Drupal docroot
- Download Drupal (if needed) and set up a new docroot for you, with correct permissions to start the installer
- Create the required Apache vhosts and tweak your hosts file accordingly
- Create a MySQL database

The script assumes that your MySQL credentials are root/root and that you're downloading drupal-8.0-alpha3 to set up a new docroot under /var/www/html. Feel free to modify the script according to your preferences.

scripts/remove.sh
-------------------

Does the exact opposite and cleans up everything (docroot, DB, vhost, hosts entry).

In the future, plan is to abstract all this even more.