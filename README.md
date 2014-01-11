Drupal 8 Tools
==============

This is a placeholder for simple D8 goodies that will hopefully help you speed up recurring tasks.

Notes
-----

- Those Shell scripts have been tested against **Ubuntu 12.04 LTS** (Precise Pangolin) and **13.10** (Saucy Salamander)
- Make sure all scripts are executable (**chmod +x script.sh**)
- It's safer to run those scripts within a container or VM (e.g. Docker or Vagrant)

Recommended usage
-----------------

Add the following bash aliases in your **.bash_aliases** file:

<pre>
alias install='sudo /path/to/drupal-8-tools/provisioning/install.sh'
alias delete='sudo /path/to/drupal-8-tools/provisioning/delete.sh'
alias module='sudo /path/to/drupal-8-tools/scaffolding/module.sh'
alias audit='sudo /path/to/drupal-8-tools/system_audit.sh'
alias dump='sudo /path/to/drupal-8-tools/cmi/dump.sh'
alias restore='sudo /path/to/drupal-8-tools/cmi/restore.sh'
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

You might also want to run a quick system audit to make sure your LAMP stack is compatible with Drupal 8's minimum requirements. Simply run:

<code>$ audit</code>
