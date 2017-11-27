#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

empty=;
. /var/www/codes.cfg
. /var/www/collector.cfg;
. /var/www/traffic.cfg;

left=`echo "$spamtraps" | sed "s/ /|/g"`;
right=`echo "${domain[*]}" | sed "s/ /|/g"`;
log=/var/log/mail.log;

rm -f /tmp/iptrap[0-9]*.tmp
test -f /var/www/cfg/iptrap || touch /var/www/cfg/iptrap;
test -f /var/www/postfix/iptrap || touch /var/www/postfix/iptrap;

minute=`date +%M | sed "s/^0//"`;

let m1=$minute-1;
let m2=$minute-2;
let m3=$minute-3;
let m4=$minute-4;
let m5=$minute-5;


min=`date +%b" "%e" "%H:`;
lastmin=`grep -E "$min(0?($m1|$m2|$m3|$m4|$m5))" $log`;

flood=`echo "$lastmin" | grep -E " (connect|RCPT) from " | sed "s/^.* from .*\[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\].*$/\1/" | grep -v "^$" | sort | uniq -c | awk '{if ($1>10) print $2}'`;

helo=`echo "$lastmin" |\
grep " postfix.* RCPT from .*\[[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\]: .* helo=<[A-Za-z0-9\-\_]*>" |\
sed "s/.* RCPT from .*\[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\]: .*/\1/" | sort -u | grep -v "^$"`;

virus=`echo "$lastmin" |\
grep " amavis.* Blocked INFECTED " |\
sed "s/^.* amavis.* Blocked INFECTED .*\[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\] \[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\] .*$/\1 \2/" | sed "s/ /\n/"  | grep -v "^$" | sort -u`;

trap=`echo "$lastmin" |\
grep " amavis.* Blocked SPAM, " |\
grep -v " <> -> " |\
grep -iE "(> -> <("$left")@("$right")>| <("$left")@("$right")> -> <)" |\
sed "s/^.* amavis.* Blocked SPAM, .*\[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\] \[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\] .*$/\1 \2/" | grep -v "^$"  | sed "s/ /\n/" | sort -u`;

localdom=`echo "$lastmin" |\
grep -iE " postfix.* RCPT from .*\]: 5.* from=<.*@("$right")> to=<.*@("$right")>" |\
sed "s/.* RCPT from .*\[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\]: .*/\1/" | sort -u | grep -v "^$"`;

spam=`echo "$lastmin" |\
grep " amavis.* Blocked SPAM, .* Hits: [0-9]\{3\}\." |\
grep -v " <> -> " |\
sed "s/^.* amavis.* Blocked SPAM, .*\[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\] \[\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\] .*$/\1 \2/" | grep -v "^$"  | sed "s/ /\n/" | sort -u`;


printf "\n$flood\n$trap\n$virus\n" | grep -v "^$" | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$" | grep -vE "^(127|10|172\.16|192\.168|0\.0)\." |\

while read ip
do
(test "$ip" = "$empty") && exit 0 || (echo -e "$ip/32\txMESSAGEx\t`date +%s`" >> /tmp/iptrap$$.tmp);
done;


curdate=`date +%s`;
let timelimit=$curdate-3600*1*1;

test -f /tmp/iptrap$$.tmp && (cat /tmp/iptrap$$.tmp /var/www/cfg/iptrap | grep -v "^$" |\
 awk -F "\t" '{if ($3>'"$timelimit"') print $0}' | sort -u > /tmp/iptrap.tmp);

test -f /tmp/iptrap.tmp && (mv /tmp/iptrap.tmp /var/www/cfg/iptrap);
awk -F "\t" '{if ($3>'"$timelimit"') print $1"\t"$2}' /var/www/cfg/iptrap | sort -u | sed "s/xMESSAGEx/$cidr_client_code/g" > /tmp/iptrap;
curcks=`cksum /var/www/postfix/iptrap | cut -d " " -f2`;
newcks=`cksum /tmp/iptrap | cut -d " " -f2`;

if ! [ "$curcks" = "$newcks" ]
then
mv /tmp/iptrap /var/www/postfix/iptrap;
else
rm -f /tmp/iptrap;
fi

rm -f /tmp/iptrap[0-9]*.tmp
exit 0;

