audit/system_audit.sh
-----------------------

[WORK IN PROGRESS]

Performs several server checks:

- Minimum PHP version
- php.ini requirements

The script assumes that your MySQL credentials are root/root and that you're downloading the latest Drupal 8 dev release to set up a new docroot under _/var/www/html_. Feel free to modify the script according to your preferences.

audit/module_audit.sh
----------------------

[WORK IN PROGRESS]

This script audits a Drupal 7 module directory for any deprecated function. On top of that, it provides for a carefully crafted mapping that will suggest a new function or methodology (when applicable) to embrace a Drupal 8-friendly API usage.

audit/common
-------------------

Common variables.
