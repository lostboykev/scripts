#! /bin/bash
#CHECK CP ACCOUNTS OVER 30GB IF BACKUPS ARE ENABLED: SEND EMAIL

if [ -f ./tmpquota ]; then

        rm -f ./tmpquota

fi




quota=$(for i in `awk '{print $2}' /etc/userdomains |  grep -v "nobody" | sort -u`; do repquota -a | awk {'print $1 " " $3'} | grep -w $i |  awk  '{if ($2 >= 3145) print $0 ; else;}'; done)
IFS=$'\n'

for element in $quota; do

                user=$(echo $element | awk {'print $1'})
                size=$(echo $element | awk '{ tmp=($2) / 1024 / 1024 ; printf"%.2f\n", tmp}')
                backupsenabled=$(grep -w  "BACKUP\=1" /var/cpanel/users/$user | cut -d "=" -f2)
		owner=$(grep  "OWNER\=" /var/cpanel/users/$user | cut -d "=" -f2)

                if [[ "$backupsenabled" == "1" ]]; then

			echo "OWNER: $owner"
                        output=$(echo "User: $user // Usage: $size"GB" // Owner: $owner")
			echo $output
                        echo $output |sed '/^$/d' >> ./tmpquota

                fi

done





actualsize=$(wc -c <"tmpquota")
minimumsize=2

if [[ -f "./tmpquota" ]] && [[ "$actualsize" -ge "$minimumsize" ]]; then

        echo -e "Please disable backups for these users and notify customers.\n \n""$(cat "./tmpquota")"| mail -s "Accounts with over 30GB on $(hostname)" kevin.t@eboundhost.com
else

        rm -f ./tmpquota
        exit 1
fi

