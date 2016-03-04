#OpenVZ first minute load average of all containers on node; sorted and ouput only load average of 2 and up
echo "     CTID  LOAD"
/usr/sbin/vzlist -o ctid,laverage | grep -v "CTID" | cut -d "/" -f1 | awk '$2>=2{print}'

