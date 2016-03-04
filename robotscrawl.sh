#! /bin/bash

dir=$(grep "DocumentRoot"  /usr/local/apache/conf/httpd.conf | grep -v htdocs | awk {'print $2'} | sort | uniq)
IFS=$'\n'

for element in $dir; do

	robots=$(cat ./robot >> $element/robots.txt)
	owner=$(echo $element | sed -e 's/\/home\///g' | cut -d "/" -f1)
	$robots
	chown $owner:$owner $element/robots.txt
	
done
