echo "     CTID  LOAD"
/usr/sbin/vzlist -o ctid,laverage | grep -v "CTID" | cut -d "/" -f1 | awk '$2>=2{print}'

