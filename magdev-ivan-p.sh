#!/bin/bash

clear;
setterm -bold on
echo "PLEASE SELECT WHICH DOMAIN YOU WANT TO HAVE DEV REPLICATION: "
echo "------------------------------------------------------------ "
DOMAINS=(`cut -d" " -f2 /etc/domainusers `)
select DOMAIN_SOURCE in "${DOMAINS[@]}"; do [ -n "${DOMAIN_SOURCE}" ] && break;done
echo "You selected: ${DOMAIN_SOURCE}"
sleep 1; clear

echo "IS THIS WORDPRESS OR MAGENTO? "
echo "------------------------------------------------------------ "
select CMS_SOURCE in  WordPress Magento; do break; done

echo "STARTING $CMS_SOURCE DEV REPLICATION PROCESS ON $DOMAIN_SOURCE: "

if [[ $CMS_SOURCE = "WordPress" ]]
then 
	echo "ITS WORDPRESS";
else
	echo "ITS MAGENTO"
fi
exit

#generating new user name (dev)(domai)n.com = devdomain
USER_TARGET=`sed 's/\.//g' <(echo dev${DOMAIN_SOURCE:0:5})`
DOMAIN_TARGET="develop.$DOMAIN_SOURCE"

grep "$DOMAIN_TARGET" /etc/userdatadomains
if [ $? -eq 0 ]; then  echo "DOMAIN $DOMAIN_TARGET EXISTS!";exit;fi	
setterm -bold off

existing_users=(`cut -d: -f1 /etc/passwd`)
if [[ "${existing_users[@]}" =~ "$USER_TARGET" ]]; then	echo "The user $USER_TARGET EXISTS! ";exit;fi
	
#function to generate random password
rand_password(){ tr -dc _A-Z-a-z-0-9 < /dev/urandom | head -c${1:-15}; }

#cPanel script to create new cPanel account
PASSWORD=$(rand_password)
/scripts/wwwacct ${DOMAIN_TARGET} ${USER_TARGET} ${PASSWORD}

if [ $? != 0 ]; then echo "Something went wrong";exit
else
	grep ^$USER_TARGET: /etc/passwd
	if [ $? != 0 ]; then exit;fi
fi

#create database user
mysql_pass=$(rand_password);
mysql -e "CREATE USER '${USER_TARGET}_usr'@'localhost' IDENTIFIED BY '$mysql_pass';"
mysql -e "CREATE DATABASE IF NOT EXISTS ${USER_TARGET}_db;"
mysql -e "GRANT ALL PRIVILEGES ON ${USER_TARGET}_db.* TO ${USER_TARGET}_usr@localhost IDENTIFIED BY '$mysql_pass';"
mysql -e "FLUSH PRIVILEGES;"
/usr/local/cpanel/bin/dbmaptool $USER_TARGET  --type "mysql"  --dbs "${USER_TARGET}_db" --dbusers "${USER_TARGET}_usr"
/usr/local/cpanel/bin/setupdbmap

#copy source to target
SOURCE="`grep ^${DOMAIN_SOURCE}: /etc/userdomains|cut -d" " -f2`"
source_user=$SOURCE
SOURCE="`grep ^${SOURCE}: /etc/passwd|cut -d: -f6`/public_html/."
TARGET="`grep ^${USER_TARGET}: /etc/passwd|cut -d: -f6`/public_html/"

#\cp -r /home/magento/public_html/. /home/devmagp/public_html/
echo "COPYING WEB CONTENTS FROM: $SOURCE TO: $TARGET ..."
\cp -r $SOURCE $TARGET
echo "...DONE"
echo "UPDATING OWNERSHIP..."
cd $TARGET
chown ${USER_TARGET}:${USER_TARGET} ../public_html -R
chown ${USER_TARGET}:nobody ../public_html
echo "...DONE"

#find source magento database name:
#INSERT IF ELSE FOR MAGE OR WP
LOCALXML_PATH="`find $SOURCE -type f -name "local.xml"|grep "app/etc/local.xml"`"
SOURCE_DB=`grep "<dbname><\!\[CDATA\[.*\]\]></dbname>" $LOCALXML_PATH |sed 's/<dbname><\!\[CDATA\[//'|sed 's/\]\]><\/dbname>//'|sed 's/ //g'`

#dump database import database
echo "DATABASE EXPORTING AND IMPORTING..."
mysqldump  $SOURCE_DB | mysql ${USER_TARGET}_db
echo "...DONE"

#edit config local.xml
sed -i "s/<username><\!\[CDATA\[.*\]\]><\/username>/<username><\!\[CDATA\[${USER_TARGET}_usr\]\]><\/username>/" ${TARGET}app/etc/local.xml
sed -i "s/<password><\!\[CDATA\[.*\]\]><\/password>/<password><\!\[CDATA\[${mysql_pass}\]\]><\/password>/" ${TARGET}app/etc/local.xml
sed -i "s/<dbname><\!\[CDATA\[.*\]\]><\/dbname>/<dbname><\!\[CDATA\[${USER_TARGET}_db\]\]><\/dbname>/" ${TARGET}app/etc/local.xml

#delete magento cache
cd ${TARGET}/var/cache
if [ $? -eq 0 ]; then rm -r mage* ;fi

#edit database core config
echo "FIXING DATABASE URL..."
mysql -Be "UPDATE devmagp_db.core_config_data SET value='http://${DOMAIN_TARGET}/' WHERE path='web/unsecure/base_url';"
mysql -Be "UPDATE devmagp_db.core_config_data SET value='https://${DOMAIN_TARGET}/' WHERE path='web/secure/base_url';"
echo "...DONE"
echo "FINISH - FINISH - FINISH"

