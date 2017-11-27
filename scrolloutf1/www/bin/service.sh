#!/bin/bash

case $1 in
swap )
sync && /sbin/sysctl vm.drop_caches=3 && swapoff -a && swapon -a;
;;
postfix )
/etc/init.d/postfix status && /etc/init.d/postfix stop || /etc/init.d/postfix start;
;;
dovecot )
/etc/init.d/dovecot status && /etc/init.d/dovecot stop || /etc/init.d/dovecot start;
;;
amavis )
/etc/init.d/amavis status && (/etc/init.d/amavis stop; kill -9 `lsof -t -u amavis`) || (/etc/init.d/amavis start && sa-update);
;;
clamav )
/etc/init.d/clamav-daemon status && (/etc/init.d/clamav-daemon stop; /etc/init.d/clamav-freshclam stop) || (/etc/init.d/clamav-daemon start; /etc/init.d/clamav-freshclam start && freshclam);
;;
incron )
/etc/init.d/incron status | grep "is running" > /dev/null 2>&1 && /etc/init.d/incron stop || /etc/init.d/incron start;
;;
cron )
/etc/init.d/cron status && /etc/init.d/cron stop || /etc/init.d/cron start;
;;
cache )
htcacheclean -n -t -p /var/cache/apache2/mod_disk_cache -l 1024M;
sa-learn --force-expire
/etc/init.d/postfix stop
rm -fr /var/lib/postfix/*_*cache.db
/etc/init.d/postfix start
/etc/init.d/amavis stop
/etc/init.d/amavis start
;;
firewall )
iptables -nL | grep DROP > /dev/null 2>&1 && (/etc/init.d/fail2ban stop; iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X; iptables -t mangle -F; iptables -t mangle -X; iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT;) || /var/www/bin/reset_iptables.sh;
;;
reboot )
reboot;
;;
cert )
[[ -z $2 ]] && openssl rsa -in /etc/postfix/certs/scrollout.key -passin pass:$2 -out /etc/postfix/certs/scrollout.key > /dev/null 2>&1;
/etc/init.d/postfix reload;
/etc/init.d/apache2 reload;
/etc/init.d/dovecot reload;
;;
* )
;;

esac