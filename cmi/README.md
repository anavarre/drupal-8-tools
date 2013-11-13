cmi/dump.sh
---------------------

- Allows docroot, (multi)site and database selection.
- Creates a snapshot of the selected database + its corresponding CMI files.
- Compresses files into the DOCROOT/backup directory and add timestamp for ease of use.

cmi/restore.sh
---------------------

- Allows docroot, (multi)site and database selection.
- Offers to restore any available backup (database + CMI files).
- Preserves permissions and does not add cruft in the backup folder.

cmi/common
------------------

Simple admin script to store common variables.

Notes
-----

- Very much inspired by @yched in https://drupal.org/node/2130441.
- This is a Proof Of Concept only. drush will always be preferred.
- Do NOT use in production.
