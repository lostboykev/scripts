EMAIL="alerts@eboundhost.com"
LOG="/var/log/exim_queue.log"
QUEUE=`/usr/sbin/exim -bpc`

if [[ ${QUEUE} > "500" ]];
        then
                echo "Date: ${NOW}

                ${HOSTNAME}

                Exim Queue: ${QUEUE}" >> ${LOG}

                echo "Warning, 

                The Exim mail queue on ${HOSTNAME} has grown larger than 500 messages. 
                
                ${QUEUE} messages in queue."|mail -s "${HOSTNAME} EXIM QUEUE WARNING!" ${EMAIL}

fi

if [[ `find ${LOG} -mtime +30` != "" ]];
        then
                rm -rf ${LOG}

fi

