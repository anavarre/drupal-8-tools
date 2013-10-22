Drupal 8 Tools
==============

This is a placeholder for simple D8 goodies that will hopefully help you speed up recurring tasks.

Notes
-----

- All scripts have been tested against **Ubuntu 12.04 LTS** (Precise Pangolin) and **13.10** (Saucy Salamander)
- Make sure all Shell scripts are executable (**chmod +x script.sh**)
- It's safer to run those scripts within a container or VM (e.g. Docker or Vagrant)

Recommended usage
-----------------

Add the following bash aliases in your **.bash_aliases** file:

<pre>
alias install='sudo /path/to/drupal-8-tools/provisioning/latest/install.sh'
alias delete='sudo /path/to/drupal-8-tools/provisioning/latest/delete.sh'
</pre>

Apply changes without rebooting:

<code>$ . ~/.bash_aliases</code>

Then, invoke the _install.sh_ or _delete.sh_ script directly and give it a sitename:

<code>$ install/remove {sitename}</code>

setup/install.sh
----------------

- Enable Apache mod_rewrite if it is disabled
- Check that the php5-curl package is installed, or it'll install it to support Guzzle support in D8
- Allow you to customize the name of the new Drupal docroot
- Download Drupal (if needed) and set up a new docroot for you, with correct permissions to start the installer
- Create the required Apache vhost and tweak your hosts file accordingly
- Create a MySQL database

The script assumes that your MySQL credentials are root/root and that you're downloading the latest Drupal 8 dev release to set up a new docroot under _/var/www/html_. Feel free to modify the script according to your preferences.

setup/delete.sh
---------------

Does the exact opposite and cleans up everything (docroot, DB, vhost, hosts entry).

setup/common
------------

Simple admin script to store common variables.
