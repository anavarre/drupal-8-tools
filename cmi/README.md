cmi/dump.sh
---------------------

- Allows docroot, (multi)site and database selection
- Creates a snapshot of the selected database + its corresponding CMI files
- Compresses files into the DOCROOT/backup directory and add timestamp for ease of use

Notes:

- Inspired by @yched in https://drupal.org/node/2130441
- Do NOT use in production 

cmi/common
------------------

Simple admin script to store common variables.
