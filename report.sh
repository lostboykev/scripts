#!/bin/bash

#VARIABLES
load=$(cut -d " " -f2 /proc/loadavg)
date=$(date +"%m_%d_%y_%I")
cpanel=/usr/local/cpanel/cpanel

#LOAD CHECK - CHANGE THE NUMBER VALUE OF "load_value = 5" TO THE LOAD YOU WANT TO REPORT AT. IT WILL TRIGGER AT EQUAL TO OR GREATER THAN THAT NUMBER VALUE
let "load_value = 0"
if (( $(echo "$load $load_value" | awk '{print ($1 > $2)}') ))
then
#THIS IS THE REPORTING PORTION WERE COMMANDS CAN BE RUN WITH OUTPUT FOR INVESTIGATING
exec &> load_report_$date.txt
echo
echo "GENERAL CHECK SCRIPT FOR CPANEL" 
echo
echo
echo
echo " You can locate this report in the same directory as the load script: load_report_$date.txt" 
echo
echo
echo
if [ -f "$cpanel" ]
then
#ANYTHING HERE CAN BE ADJUSTED TO YOUR PREFERENCES
        /usr/local/cpanel/cpanel -V
        echo 
        echo "//HOSTNAME//" 
        echo
        hostname
        echo 
        echo "//TOP//" 
        echo
        COLUMNS=512 top -b -n1 -c | sed 's/  *$//'
        echo 
        echo "//DISK AVAILABILITY//" 
        echo
        df -h
        echo 
        echo "//IO TOP//" 
        echo    
        /usr/sbin/iotop -bon2 -d5
        echo "//INODE AVAILABILITY//" 
        echo
        df -ih
        echo 
        echo "//FREE MEMORY//" 
        echo
        free -m
        echo
        echo "//EMAIL QUEUE COUNT//" 
        echo
        /usr/sbin/exim -bpc
        echo
        echo "//LYNX DUMP//" 
        echo
        lynx --dump --width=250 localhost/whm-server-status|grep -Ev "OPTION|NULL" | tr "_" " "
        echo 
        echo "//IP AND NUMBER OF CONNECTIONS//" 
        echo
        netstat -plan |grep :80|awk '{print $5}' |cut -d: -f1 |sort |uniq -c |sort -n
        echo "second try"
	netstat -ano | awk {'print $5'} | sort -u | cut -d: -f1 | uniq -c | sort -n
	echo  
        echo "//TOTAL CONNECTIONS :80//" 
        echo
        echo
        netstat -plan |grep :80 |wc -l
        echo 
        echo "//USER BEAN COUNTERS//" 
        echo
        grep -v Version /proc/user_beancounters | sed 's/[0-9]*://' | sed 's/uid //' | column -t | awk '{print $6" "$1"  "$2"/"$3}'
        echo
        echo "//LOAD HISTORY//" 
        echo
        sar
        echo
        echo    
        echo "/////////FIN//////////" 
#THIS IS THE MAIL COMMAND THAT WILL OUTPUT ALL RUN COMMANDS TO YOUR EMAIL. JUST CHANGE THE ADDRESS.
        mail -s "High Load Warning on $(hostname)" email-address < load_report_$date.txt
else
        echo "THIS IS NOT A CPANEL SERVER!" 
fi
else
        exit 1
fi

