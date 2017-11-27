#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################



sndr=/var/www/cfg/sndr;
wb=/var/www/spamassassin/20_wb.cf;
test -f $sndr || touch $sndr;
test -f $wb || touch $wb;
chmod 666 $sndr;
chmod 666 $wb;
sed -i "s/FILTER.*smtp-amavis.*/OK/g" $sndr
# sig=/var/www/cfg/signatures;
. /var/www/codes.cfg;
email="$file";
. /var/www/traffic.cfg
my_domains=`echo "${domain[*]}" | tr " " "|"`
empty=
from=
from0=

chown root /var/www/cfg/sndr;
chown root /var/www/postfix/sndr;
chown root /var/www/spamassassin/20_wb.cf;

# test -f $sig || touch $sig;




# attach=`grep -iEm1 "^Content-(Disposition|Type)" $email`;

test "$from0" = "$empty" && from0=`grep -m1 "^Subject:.*include.*\@.*" $email | awk -F "[ <]" '{print $NF}' |sed "s/[ <]\(.*@.*\..*\)[> ]$/\1/g" | sed "s/[<> ]//g" | grep -i "@"`;
test "$from0" = "$empty" && from0=`grep -m1 "^Sender:.*\@.*" $email | awk -F "[ <]" '{print $NF}' |sed "s/[ <]\(.*@.*\..*\)[> ]$/\1/g" | sed "s/[<> ]//g" | grep -i "@"`;
test "$from0" = "$empty" && from0=`grep -m1 "^Return-Path:.*\@.*" $email | awk -F "[ <]" '{print $NF}' |sed "s/[ <]\(.*@.*\..*\)[> ]$/\1/g" | sed "s/[<> ]//g" | grep -i "@"`;
test "$from0" = "$empty" && from0=`grep -m1 "^From:.*\@.*" $email | awk -F "[ <]" '{print $NF}' | sed "s/[ <]\(.*@.*\..*\)[> ]$/\1/g" | sed "s/[<> ]//g" | grep -i "@"`;
test "$from0" != "$empty" && from=`echo "$from0" | sed "s/\([[:punct:]]\)/\\\\\\\\\1/g"`;
from_domain0=`echo "$from0" | cut -d "@" -f2`;
from_domain=`echo "$from" | cut -d "@" -f2`;

case $learn in
"spam")
	if ! [ "$from" = "$empty" ];
	then
	old_sndr=`cat $sndr | grep -viE "\@$from_domain.*(FILTER|OK$)"`;
	(echo "$old_sndr" && printf "\n/^$from$/\txMESSAGEx\n") | grep -viE "$my_domains|^$"  | sort -u | sort +1 -2 | grep "\." > $sndr.tmp
	mv $sndr.tmp $sndr;
	sed "s/\txMESSAGEx$/\tREJECT/g" $sndr > /etc/postfix/sndr.tmp
	mv /etc/postfix/sndr.tmp /etc/postfix/sndr
	fi

	if ! [ "$from0" = "$empty" ];
	then
	old_wb=`grep -vi "whitelist_.*\@$from_domain0" $wb`;
	(echo "$old_wb" && printf "\nblacklist_from\t$from0\n") | grep -viE "$my_domains|^$" | sort -ur | grep "\." > /tmp/wb.tmp
	test -f /tmp/wb.tmp && mv /tmp/wb.tmp $wb;
#	cp $wb /var/www/spamassassin/20_wb.cf
	fi
;;

"ham")
	if ! [ "$from" = "$empty" ];
	then
	old_sndr=`cat $sndr | grep -vi "\@$from_domain.*xMESSAGEx"`;
	(echo "$old_sndr" && printf "\n/\@$from_domain$/\tOK\n") | grep -viE "$my_domains|^$"  | sort -u | sort +1 -2 | grep "\." > $sndr.tmp
	test -f $sndr.tmp && mv $sndr.tmp $sndr;
	sed -e "s/\txMESSAGEx$/\t$sender_code/g" -e "s/\tOK$/\tOK/g" $sndr > /etc/postfix/sndr.tmp
	test -f /etc/postfix/sndr.tmp && mv /etc/postfix/sndr.tmp /etc/postfix/sndr
	fi

	if ! [ "$from0" = "$empty" ];
	then
	old_wb=`grep -vi "blacklist_from.*\@$from_domain0" $wb`;
	(echo "$old_wb" && printf "\nwhitelist_auth\t*@$from_domain0\n") | grep -v "^$"  | sort -ur | grep "\." > /tmp/wb.tmp
	test -f /tmp/wb.tmp && mv /tmp/wb.tmp $wb;
#	cp $wb /var/www/spamassassin/20_wb.cf
	fi
chown www-data /var/www/spamassassin/20_wb.cf
;;
esac;

chown www-data /var/www/cfg/sndr;
chown www-data /var/www/postfix/sndr;
chown www-data /var/www/spamassassin/20_wb.cf;