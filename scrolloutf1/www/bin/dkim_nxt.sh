#!/bin/bash

case $1 in
gen)
	. /var/www/bin/config.sh;
	dkim=/var/www/dkim;
	dkim22=/etc/amavis/conf.d/22-dkim;
	test -d /var/www/dkim || mkdir /var/www/dkim;
	rm -f $tmp/*\.pem;
	mv -f $dkim/*\.pem $tmp;

empty="";

[ "$hostrelay" = "$empty" ] && sign="1" || sign="0";

	printf "
use strict;

\$enable_dkim_signing = $sign;
 " > $tmp/dkim22;

i=0;
	# generate keys per each domain if does not exist
	for each_domain in ${domain[*]}
	do
		# test if a key already exists
	if [ -f $tmp/$each_domain-dkim.key.pem ];
		then
		mv $tmp/$each_domain-dkim.key.pem $dkim;
		([ "${hrelays[$i]}" = "$empty" ] && [ "$hostrelay" = "$empty" ] && [ "${d_dkim[$i]}" = "$empty" ]) && \
		(printf "
  dkim_key('$each_domain', 'dkim', '$dkim/$each_domain-dkim.key.pem');" >> $tmp/dkim22);
		else
		([ "${hrelays[$i]}" = "$empty" ] && [ "$hostrelay" = "$empty" ] && [ "${d_dkim[$i]}" = "$empty" ]) && \
		(amavisd-new genrsa $dkim/$each_domain-dkim.key.pem 2048 > /dev/null 2>&1;
		printf "
  dkim_key('$each_domain', 'dkim', '$dkim/$each_domain-dkim.key.pem');" >> $tmp/dkim22);
	   fi
	 let i++;
	done;
# generate amavis 22-dkim file
printf "
  @dkim_signature_options_bysender_maps = (
	{ '.' => { ttl => 21*24*3600, c => 'relaxed/relaxed' } } );
  @mynetworks = qw([fc00::]/7 [::ffff:127.0.0.0]/104 [::1]/128 0.0.0.0/8 127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
				${mynets[*]});  # list your internal networks

1;  # ensure a defined return
" >> $tmp/dkim22 && mv $tmp/dkim22 $dkim22;
amavisd-new showkeys > $dkim/allkeys;
/etc/init.d/amavis restart;
;;

# read all keys
showkeys) test -f /var/www/dkim/allkeys && cat /var/www/dkim/allkeys || amavisd-new showkeys
;;


*)

. /var/www/traffic.cfg;

empty="";
mess="Updates are processed on a delay. Reload in a short while.";
[ "$hostrelay" = "$empty" ] && mess="Updates are processed on a delay. Reload in a short while.";
[ "$hrelays[$2]" != "$empty" ] && mess="DKIM not available for $2";
[ "$hostrelay" != "$empty" ] && mess="All DKIM are disabled. All domains are relayed";

(echo "$1" | awk "/$2/,/\)/" | grep "DKIM" > /dev/null) && (echo "$1" | awk "/$2/,/\)/" | grep -v "key#" | grep -v "^$"  |\
 sed "s/  \"\|\"//g" | awk '$1=$1' ORS='' | sed "s/(/ \
 \&nbsp;<br\/>\<input class\=\"form-control\" size\=\"100\" disabled\=\"disabled\" type\=\"text\" value\=\"/g" | sed "s/)/\"\>/g") || \
 printf "<input class=\"form-control\" size=\"100\" disabled=\"disabled\" type=\"text\" value=\"$mess\" /></b>";
 ;;
esac;

 rm -f $tmp/*dkim.key.pem;