#!/bin/bash

source common

echo -e "Which Drupal docroot should we delete?"
read SITE

echo -e "\tDelete Drupal docroot..."
	rm -Rf $WEBROOT/$SITE

echo -e "\tDelete vHost..."
	rm -Rf /etc/apache2/sites-available/$SITE /etc/apache2/sites-enabled/$SITE

echo -e "\tDelete hosts entry..."
	sed -i "/$SITE.$SUFFIX/d" /etc/hosts

echo -e "\tDelete database..."
	$MYSQL -uroot -proot -e "DROP $SITE;"

echo -e $GREEN_START"Successfully removed http://$SITE.$SUFFIX"$GREEN_END