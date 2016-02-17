#/bin/bash
# ray@eboundhost.com
#
# Nov 30, 2011 v.02 # code cleanup
# Dec 30, 2015 v.02.1 # syntax adjustments to make script work // Jarett E & Kevin T

# User-set Variables
msg_count_limit=50  #  <---- specify mail queue count limit here
queue=`exim -bpc`
if [ $queue -ge "$msg_count_limit" ]; then
echo "" > /tmp/queuecheck.tmp
echo "" >> /tmp/queuecheck.tmp
echo "Elevated email queue ($queue) detected on ${HOSTNAME}. This alert will continue until the queue is below $msg_count_limit." >> /tmp/queuecheck.tmp
echo " " >> /tmp/queuecheck.tmp
echo " " >> /tmp/queuecheck.tmp
echo " " >> /tmp/queuecheck.tmp
echo " " >> /tmp/queuecheck.tmp
echo "-=( Brought to you by /root/bin/eximqchk.sh .  To disable this check, comment out root's crontab )=-" >> /tmp/queuecheck.tmp
echo " " >> /tmp/queuecheck.tmp

mail -s "Warning, Mail queue on $(hostname) = $queue" support@eboundhost.com < /tmp/queuecheck.tmp
fi

