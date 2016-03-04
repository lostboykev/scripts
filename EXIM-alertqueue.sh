#!/bin/bash
QUEUE=`/usr/sbin/exim -bpc` #exim current queue
TRIGGER="0"     #set queue amount to trigger email of equal or greater this value
EMAIL="emailuser@example.com" #replace with actual email address

if [[ ${QUEUE} -ge ${TRIGGER} ]]; then

/bin/mail -s "Exim High Queue on $(hostname) = $QUEUE" $EMAIL <<< "Trigger is set to $(echo $TRIGGER)"

fi



#OLD#

#rm -f /tmp/tmpqueue
#
#exim -bpc | awk '{ if ($1 == 0) print $0; else;}' > /tmp/tmpqueue
#
#if [ -s /tmp/tmpqueue ]; then
#        /bin/mail -s "Exim High Queue on $(hostname) = $(cat /tmp/tmpqueue)" kevin.t@networkslice.com < /tmp/tmpqueue 
#else
#        rm -f /tmp/tmpqueue && exit
#fi
