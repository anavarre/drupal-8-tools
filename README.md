Drupal 8 Tools
==============

This is a placeholder for simple D8 goodies that will hopefully help you speed up recurring tasks.

Notes
-----

- Those Shell scripts have been tested against **Ubuntu 12.04 LTS** (Precise Pangolin) and **14.04 LTS** (Trusty Tahr). If you're running a non LTS release, use at your own risk.
- Make sure all scripts are executable (**chmod +x script.sh**)
- It's safer to run those scripts from within a container or a VM (e.g. Docker or Vagrant)

Recommended usage
-----------------

Add the following bash aliases in your **.bash_aliases** file:

<pre>
alias saudit='sudo /path/to/drupal-8-tools/audit/system_audit.sh'
alias maudit='sudo /path/to/drupal-8-tools/audit/module_audit.sh'
alias dump='sudo /path/to/drupal-8-tools/cmi/dump.sh'
alias restore='sudo /path/to/drupal-8-tools/cmi/restore.sh'
alias install='sudo /path/to/drupal-8-tools/provisioning/install.sh'
alias delete='sudo /path/to/drupal-8-tools/provisioning/delete.sh'
alias module='sudo /path/to/drupal-8-tools/scaffolding/module.sh'
</pre>

Apply changes without rebooting:

<code>$ . ~/.bash_aliases</code>

To provision a Drupal 8 site, invoke the _install.sh_ or _delete.sh_ script directly and give it a sitename:

<code>$ install/delete {sitename}</code>

If you want a module scaffolding, invoke the _module.sh_ script:

<code>$ module</code>

Want to quickly dump your database and corresponding CMI files? Run:

<code>$ dump</code>

To perform a restore, run:

<code>$ restore</code>

To audit your system against Drupal 8 requirements, run:

<code>$ saudit</code>

If you wish to upgrade a Drupal 7 module to Drupal 8, there's also a script for that! Run the below command and enter the full Unix path to any D7 module to audit:

<code>$ maudit</code>

You might also want to run a quick system audit to make sure your LAMP stack is compatible with Drupal 8's minimum requirements. Simply run:

<code>$ audit</code>
