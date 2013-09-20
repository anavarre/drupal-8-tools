#!/bin/bash

# Invoke the script from anywhere (e.g system alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/common

echo -e $RED_START"############################################################"$RED_END
echo -e $RED_START"# WARNING! You're about to delete a site and all its data! #"$RED_END
echo -e $RED_START"############################################################"$RED_END

echo -e "Which Drupal docroot should we delete?"
read SITE

read -p "Are you sure? [Y/N] "
if [[ $REPLY =~ ^[Nn]$ ]]
then
	echo -e $GREEN_START"Back to the comfort zone. Aborting."$GREEN_END
	exit 0
fi

# Docroot exists
if [[ ! -d $WEBROOT/$SITE ]]; then
	echo -e $GREEN_START"The $SITE docroot doesn't exist! Aborting."$GREEN_END
	exit 0
fi

echo -e "\tDeleting Drupal docroot..."
	rm -Rf $WEBROOT/$SITE

echo -e "\tDeleting Apache vHost..."
	rm -f $SITES_AVAILABLE/$SITE
	a2dissite $SITE

echo -e "\tDeleting hosts file entry..."
	sed -i "/$SITE.$SUFFIX/d" /etc/hosts

echo -e "\tDeleting database..."
	$MYSQL -uroot -proot -e "DROP DATABASE IF EXISTS $SITE"

echo -e $GREEN_START"Successfully removed http://$SITE.$SUFFIX"$GREEN_END