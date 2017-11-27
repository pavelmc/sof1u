#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################



CONFIG=/var/www/bin/config.sh
. $CONFIG



test -f $run/reload.pid && exit 0;

echo $$ > $run/reload.pid



lockfile-create $tmp/restarting


test -f /etc/postfix/bcc_maps && postmap /etc/postfix/bcc_maps;
test -f /etc/postfix/recipients && postmap /etc/postfix/recipients;
test -f /etc/postfix/relay_recipients && postmap /etc/postfix/relay_recipients;
test -f /etc/postfix/sender && postmap /etc/postfix/sender;
test -f /etc/postfix/transport && postmap /etc/postfix/transport;
test -f /etc/postfix/virtual && postmap /etc/postfix/virtual;
test -f /etc/postfix/login_maps && postmap /etc/postfix/login_maps;

test -f /var/lib/.pyzor/pyzord.pid && kill -9 `cat /var/lib/.pyzor/pyzord.pid` > /dev/null 2>&1;
rm -f /var/lib/.pyzor/pyzord.pid;
pyzord --detach /dev/null --homedir=/var/lib/.pyzor/ -a 127.0.0.1 --cleanup-age=2592000

for service in rsyslog redis-server quagga postsrsd unattended-upgrades prosody jitsi-videobridge jicofo jigasi clamav-daemon; do
echo "$service"
done | parallel --gnu "service {} restart" > /dev/null 2>&1

/etc/init.d/amavis stop
kill -9 `lsof -t -u amavis`
/etc/init.d/amavis start

for service in bind9 dovecot postfix php5-fpm incron cron rbldnsd nginx; do
echo "$service"
done | parallel --gnu "service {} reload || service {} restart" > /dev/null 2>&1

postqueue -f

ps -A | grep fail2ban | awk '{print $1}' | parallel --gnu kill -9 {} > /dev/null 2>&1
rm -f /var/run/fail2ban/fail2ban.sock
/etc/init.d/fail2ban restart > /dev/null 2>&1 &

lockfile-remove $tmp/restarting

rm -f $run/reload.pid