Drupal 8 Tools
==============

This is a placeholder for simple D8 goodies that will hopefully help you speed up recurring tasks.

scripts/d8_setup.sh
-------------------

Caution: this script has only been tested with Ubuntu 12.04. It might break with any other configuration.

Instead of using any *AMP stack, VM or container, why not simply use a shell script to provision a Drupal site? This is what this script is all about. Within a few seconds it will:

- Enable Apache mod_rewrite if it is disabled
- Check that the php5-curl package is installed, or it'll install it to provide Guzzle support in D8
- Allow you to customize the name of the new Drupal docroot
- Download Drupal (if needed) and set up a new docroot for you, with correct permissions to start the installer
- Create the required Apache vhosts and tweak your hosts file accordingly
- Create a MySQL database
