#! /bin/bash
##Sort cPanel accounts by quota usage##

##ensure no temp file exists##
if [ -f ./tmpquota ]; then

 rm -f ./tmpquota

fi

quota=$(for i in `awk '{print $2}' /etc/userdomains | grep -v "nobody" | sort -u`; do repquota -a | awk {'print $1 " " $3'} | grep -w $i | awk '{if ($2 >= 100) print $0 ; else;}'; done)
IFS=$'\n'

for element in $quota; do

 user=$(echo $element | awk {'print $1'}) ##cPanel user##
 size=$(echo $element | awk '{ tmp=($2) / 1024 / 1024 ; printf"%.2f\n", tmp}') ##quota usage converted into GB##
 owner=$(grep "OWNER\=" /var/cpanel/users/$user | cut -d "=" -f2) ##reseller/owner of account##
 output=$(echo "User: $user // Usage: $size "GB" // Owner: $owner") ##variable that echos user; disk quota; owner/reseller##

 echo $output |sed '/^$/d'   >> ./tmpquota  ##above variable output appended into tempfile##
 cat ./tmpquota | sort -k 5 -n  


done
