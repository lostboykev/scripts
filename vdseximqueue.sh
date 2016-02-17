#!/bin/bash
container=$(for i in `ps aux | grep /usr/sbin/exim | awk {'print $2'} | xargs /usr/sbin/vzpid | awk {'print $2'}  | grep -v VEID | sort | uniq `; do echo -n "Container $i "; echo "queue:" $(/usr/sbin/vzctl exec $i exim -bpc) | uniq ;done)

printf "%s\n" "${container[@]}" | awk '{ if ($4 >= 500) print $0; else;}' > /tmp/tmpqueue

if [ -s /tmp/tmpqueue ]; then
        /bin/mail -s "Exim high queue $(hostname)" support@eboundhost.com < /tmp/tmpqueue && rm -f /tmp/tmpqueue
else
        rm -f /tmp/tmpqueue && exit
fi
