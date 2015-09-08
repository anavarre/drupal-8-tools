Requirements
------------

- Git clone `8.0.x` from drupal.org

<pre>
$ git clone --branch 8.0.x http://git.drupal.org/project/drupal.git
</pre>

- Create a `HEAD` symbolic link in the *provisioning* directory so that the installer knows where to git pull changes from

<pre>
$ cd /path/to/provisioning/dir ; ln -s /path/to/d8/repo HEAD
</pre>

Note: The `HEAD` symlink has been added to the `.gitignore` file so that it won't be deleted ever.

provisioning/install.sh
-----------------------

- Enable Apache's mod_rewrite if it is disabled
- Allow you to customize the name of the new Drupal docroot
- Git pull 8.0.x (HEAD) to make sure you're working with the latest dev release
- Set up a new docroot with the correct permissions and requirements (settings.php, files dir...)
- Create the required Apache vhost and tweak the hosts file accordingly
- Create a MySQL database
- Run the Drupal installer automatically and spin up the site in seconds

The script assumes that your MySQL credentials are root/root and that you're downloading the latest Drupal 8 dev release to set up a new docroot under _/var/www/html_. Feel free to modify the script according to your preferences.

<code>$ install d8</code>

The `install.sh` script supports passing arguments to load a specific Drush make file. There's a make file named `dev.make` that ships with the repo. It loads some handy dev modules (devel, coder, webprofiler...) that most Drupal 8 developers will need. You can invoke it by passing `-d` as a second argument to the script.

<code>$ install d8 -d</code>

The other make file does NOT ship with the repo and you'll have to create it manually:

* Place it under the `provisioning` directory
* Name it `custom.make` for the install script to find it

The intent of supporting a custom make file is that you can come up with your own requirements and quickly spin up a D8 instance with just what you need. That file has been added to `.gitignore` so that it won't be wiped at any point in time. You can invoke it by passing `-c` to the script.

<code>$ install d8 -c</code>

provisioning/delete.sh
----------------------

Does the exact opposite and cleans up everything (docroot, DB, vhost, hosts entry).

<code>$ delete d8</code>


provisioning/functions.sh
-------------------------

Holds shared functions and feature-specific functions to keep the main files clean.

provisioning/common
-------------------

Simple admin script to store common variables.
