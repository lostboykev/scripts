#sed -i '/\/usr\/local\/cpanel\/scripts\/upcp/s/^/#/g' /var/spool/cron/root && echo "FOUND" || echo "NOTFOUND"
crontab -l > /tmp/crontab.root && sed -i '/\/usr\/local\/cpanel\/scripts\/upcp/s/^/#/g' /tmp/crontab.root && echo "28 1 * * * /usr/local/cpanel/scripts/upcp --cron" >> /tmp/crontab.root && crontab /tmp/crontab.root 

