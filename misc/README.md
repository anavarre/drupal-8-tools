Requirements
------------

- Git clone HEAD from drupal.org

<pre>
$ git clone --branch 8.0.x http://git.drupal.org/project/drupal.git
</pre>

- Create a *HEAD* symbolic link in the *misc* directory so that the installer knows where to git pull changes from.

<pre>
$ cd /path/to/misc/dir ; ln -s /path/to/d8/repo HEAD
</pre>

Note: The *HEAD* directory name has been added to the .gitignore file so that it won't be deleted ever.

misc/core-update.sh
-----------------------

- Checks if the current working directory contains a bootstrap.inc file
- Preserves common files you might have modified (.htaccess, robots.txt, settings.php, services.yml)
- Updates Drupal Core by leveraging advanced rsync options (e.g. --checksum)
