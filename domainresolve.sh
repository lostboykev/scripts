#! /bin/bash
##ping for IP and dig name servers for domains located in /etc/userdatadomains 
##need to clean out array as some are empty lines or whitespace; quick fix was to sed match exact string and remove line "Domain and IP:  // Name Servers:

if [ -f /tmp/domainresolve.log ]; then

 rm -f /tmp/domainresolve.log

fi






domain=$(cat /etc/userdatadomains | grep -v "==sub=="| cut -d ":" -f1  |sed '/^\s*$/d')
IFS=$'\n'

for element in $domain; do

        ip=$(ping -c 1 $element | grep PING | awk {'print $2 " " $3'} |sed 's/\(\(\|\)\)//g' |grep -v "unkown host" |sed '/^\s*$/d')
        ns=$(for i in `echo $ip | awk {'print $1'}`; do dig ns $i +noall +answer | grep -v "DiG" | grep -v "global options:" | grep -v -e '^$' | awk {'print $5'} | sed '/^\s*$/d'; done)
        output=$(echo "Domain and IP: $ip // Name Servers: $ns")
        echo $output | sed '\/Domain and IP:  \/\/ Name Servers:/d' >> /tmp/domainresolve.log


done
