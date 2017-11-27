#!/bin/bash

h=$(( 60*60 ));
d=$(( ${h}*24 ));
w=$(( ${d}*7 ));
m=$(( ${w}*5 ));

hard_reject="554 5"
soft_reject="454 4"

PYZ="/usr/bin/pyzor -t 5"
WRITELOG="logger -t postfix/pyzor -i -p mail.info"
action="DUNNO"
pyzor="no"
test -f  /var/www/security.cfg && .  /var/www/security.cfg

case $1 in
volume)


test -f $2/../email.txt && fp=`$PYZ digest < $2/../email.txt` || exit 2;

if echo $fp | $PYZ -r $(( ${Body_filter} * 2 )) -w 1 -s digests check > /dev/null 2>&1; then

	action="${soft_reject}.7.2 Maximum complaints limit exceeded: ${fp}";
	pyzor="yes";

fi

get_data=`cat <<END | redis-cli -n 5 | awk -F '>' '{print $NF}'
hget "fp:${fp}" volume
hget "fp:${fp}" junk
get "fp_score:${fp}"
END`

if [ "${get_data}" != "" -a "$action" == "DUNNO" ]; then
	volume=`echo "${get_data}" | awk 'NR == 1'`
	junk=`echo "${get_data}" | awk 'NR == 2'`
	score=`echo "${get_data}" | awk 'NR == 3'`

	[[ "$action" == "DUNNO" ]] && echo "${volume} ${score}" | awk '{if ($1>='"${Average_reputation}"') exit $2/$1>='"${Average_reputation}"'?25:24}';
	[ $? -eq 25 ] && action="${soft_reject}.7.3 Poor avg. reputation for FP: ${fp}"; 
	
	[[ "$action" == "DUNNO" ]] && echo "${volume} ${junk}" | awk '{if ($1>='"${Average_reputation}"'*2) exit $2/$1*100>='"${Average_reputation}"'*10?25:24}';
	[ $? -eq 25 ] && action="${hard_reject}.7.3 Poor avg. rate for FP: ${fp}";
		
fi

echo "action=$action"

echo "FP: ${fp}, Pyzor: ${pyzor}, FP Volume: ${volume}, FP Junk: ${junk}, FP Score:${score}" | $WRITELOG

;;

esac

exit 2
