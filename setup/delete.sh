#!/bin/bash

source common

echo -e "Which Drupal docroot should we delete?"
read SITE

echo -e "\tDeleting Drupal docroot..."
	rm -Rf $WEBROOT/$SITE

echo -e "\tDeleting Apache vHost..."
	rm -f $SITES_AVAILABLE/$SITE $SITES_ENABLED/$SITE

echo -e "\tDeleting hosts file entry..."
	sed -i "/$SITE.$SUFFIX/d" /etc/hosts

echo -e "\tDeleting database..."
	$MYSQL -uroot -proot -e "DROP DATABASE IF EXISTS $SITE"

echo -e $GREEN_START"Successfully removed http://$SITE.$SUFFIX"$GREEN_END