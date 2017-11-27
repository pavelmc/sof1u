#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

. /var/www/security.cfg

WRITELOG="logger -t postfix/policy_verify -i -p mail.info"
unset key; unset volume; unset junk; unset score; unset encryption;
declare -A key; declare -A volume; declare -A junk; declare -A score; declare -A encryption;

h=$(( 60*60 ));
d=$(( ${h}*24 ));
w=$(( ${d}*7 ));
m=$(( ${w}*5 ));


check_ns_names=('bl-ns.scrolloutf1.local' ${check_ns_names[*]});
check_ns_ips=('bl-ip.scrolloutf1.local' ${check_ns_ips[*]});

hard_reject="554 5"
soft_reject="454 4"

action=DUNNO;

function policy {

action="DUNNO";

if [ "$action" == "DUNNO" ]; then

	# query for NS Names and IPs
    s_ns=""; s_ns_ip=; s_ns_all=; s_ns_allips=; res_s_domain=;
    
  if [ "${s_domain}" != "" ]; then
    
    res_s_domain=`dig -t any ${s_domain}. +trace +all +bufsize=1252 +time=3 +tries=2 2> /dev/null`;
    if [ $? -eq 0 ]; then

	s_ns=(`echo "$res_s_domain" | awk '/^\S+\.\S+\s+\S+\s+IN\s+NS\s+\S+\.$/ {print tolower($NF)}' | sort -u`);

	# end query for NS Names and IPs
	
	# Check NS Names and IPs in RBL - draft - Not all IPs are check. 
    for ((ns=0; ns<${#s_ns[*]}; ns++ )); do

        s_ns_ip[$ns]=`echo "$res_s_domain" | awk '/\s+\S+\s+IN\s+A+\s+/ {print tolower($0)}' | awk '/^'"${s_ns[$ns]}"'/ {print tolower($NF)}' | sort -u`

        [[ -z ${s_ns_ip[$ns]} ]] && s_ns_ip[$ns]=`host -W 3 -R 2 ${s_ns[$ns]} 2> /dev/null | awk '/ has / {print $NF}' | sort -u`
        s_ns_allips=( `echo ${s_ns_allips[*]} ${s_ns_ip[$ns]}` )
        s_ns_all=( `echo ${s_ns_all[*]} ${s_ns[$ns]}"["${s_ns_ip[$ns]}"]"` )
	

	# check NS Name in RBL
	for ((check_ns_name=0; check_ns_name<${#check_ns_names[*]}; check_ns_name++)); do
    if [[ ! -z ${s_ns[$ns]} && "$action" = "DUNNO" && "${check_ns_names[$check_ns_name]}" != "" ]]; then


	    host -W 3 -R 2 -t a ${s_ns[$ns]}${check_ns_names[$check_ns_name]}. > /dev/null 2>&1;

	    if [ $? -eq 0 ]; then
		action="REJECT ${s_ns[$ns]} listed in ${check_ns_names[$check_ns_name]}."
		descriptive=`host -W 3 -R 2 -t txt ${s_ns[$ns]}${check_ns_names[$check_ns_name]}. 2> /dev/null | awk -F '"' '{print $2}'`
    		[ $? -eq 0 ] && action="REJECT $descriptive";
	    fi
	fi
	done
	# end check NS Name in RBL
	
	[ ! -z ${s_ns_ip[$ns]} ] && rev_ip[$ns]=`echo "${s_ns_ip[$ns]}" | awk -F '.' '!/:/ && /\./ {print $4FS$3FS$2FS$1 }'`

	# check NS IP in RBL
	for ((check_ns_ip=0; check_ns_ip<${#check_ns_ips[*]}; check_ns_ip++)); do
    if [[ ! -z ${rev_ip[$ns]} && "$action" = "DUNNO" && "${check_ns_ips[$check_ns_ip]}" != "" ]]; then


	    host -W 3 -R 2 -t a ${rev_ip[$ns]}.${check_ns_ips[$check_ns_ip]}. > /dev/null 2>&1;

	    if [ $? -eq 0 ]; then
		action="REJECT ${s_ns_ip[$ns]} listed in ${check_ns_ips[$check_ns_ip]}."
		descriptive=`host -W 3 -R 2 -t txt ${rev_ip[$ns]}.${check_ns_ips[$check_ns_ip]}. 2> /dev/null | awk -F '"' '{print $2}'`
    		[ $? -eq 0 ] && action="REJECT $descriptive";
	    fi
	fi
	done
	# end check NS IP in RBL


    done
    fi
	
	# Check local redis
	
	get_data=`cat <<EOF
hget "sr:${sender} -- ${recipient}" volume
hget "sr:${sender} -- ${recipient}" junk
get "sr_score:${sender} -- ${recipient}"
hget "s:${sender}" volume
hget "s:${sender}" junk
get "s_score:${sender}"
hget "sd:${s_domain}" volume
hget "sd:${s_domain}" junk
get "sd_score:${s_domain}"
hget "ip:${ip}" volume
hget "ip:${ip}" junk
get "ip_score:${ip}"
hget "ipc:${class_c}" volume
hget "ipc:${class_c}" junk
get "ipc_score:${class_c}"
hget "c:${client}" volume
hget "c:${client}" junk
get "c_score:${client}"
get "stls:${s_domain}"
get "stls:${ip}"
EOF
`


get_db=`cat <<END | redis-cli -n 5 | awk -F '>' '{print $NF}'
${get_data}
END`
	
	volume[${sender} -- ${recipient}]=`echo "${get_db}" | awk 'NR == 1'`
	junk[${sender} -- ${recipient}]=`echo "${get_db}" | awk 'NR == 2'`
	score[${sender} -- ${recipient}]=`echo "${get_db}" | awk 'NR == 3'`

	# echo "${volume[${sender} -- ${recipient}]} ${score[${sender} -- ${recipient}]}" | $WRITELOG
	[[ "$action" == "DUNNO" ]] && echo "${junk[${sender} -- ${recipient}]}" | awk '{if exit $1>=1?25:24}';
	[ $? -eq 25 ] && action="${hard_reject}.7.1 Recipient rejected messages from ${sender} to ${recipient}"
	
	[[ "$action" == "DUNNO" ]] && echo "${volume[${sender} -- ${recipient}]}|${score[${sender} -- ${recipient}]}" | awk -F '|' '{if ($1>='"${Average_reputation}"' && $1*$2>0) exit $2/$1>='"${Average_reputation}"'?25:24}';
	[ $? -eq 25 ] && action="${soft_reject}.7.1 Poor avg. reputation for: ${sender} to ${recipient}"
	
	[[ "$action" == "DUNNO" ]] && echo "${volume[${sender} -- ${recipient}]}|${junk[${sender} -- ${recipient}]}" | awk -F '|' '{if ($1>'"${Average_reputation}"'*2 && $1*$2>0) exit $2/$1*100>'"${Average_reputation}"'*10?25:24}';
	[ $? -eq 25 ] && action="${hard_reject}.7.1 Poor avg. rate for: ${sender} to ${recipient}"
	
	
	volume[${sender}]=`echo "${get_db}" | awk 'NR == 4'`
	junk[${sender}]=`echo "${get_db}" | awk 'NR == 5'`
	score[${sender}]=`echo "${get_db}" | awk 'NR == 6'`

	# echo "${volume[${sender}]} ${score[${sender}]}" | $WRITELOG
	[[ "$action" == "DUNNO" ]] && echo "${volume[${sender}]}|${volume[${ip}]}|${score[${sender}]}|${score[${ip}]}" | awk -F '|' '{if (($1+$2)/2>'"${Average_reputation}"' && $1*$2*$3*$4>0) exit (($3+$4)/2)/(($1+$2)/2)>='"${Average_reputation}"'?25:24}';
	[ $? -eq 25 ] && action="${soft_reject}.7.1 Poor avg. reputation for sender: ${sender} and IP: ${ip}"
	
	[[ "$action" == "DUNNO" ]] && echo "${volume[${sender}]}|${volume[${ip}]}|${junk[${sender}]}|${junk[${ip}]}" | awk -F '|' '{if (($1+$2)/2>'"${Average_reputation}"'*2 && $1*$2*$3>0) exit (($3+$4)/2)/(($1+$2)/2)*100>'"${Average_reputation}"'*10?25:24}';
	[ $? -eq 25 ] && action="${hard_reject}.7.1 Poor avg. rate for sender: ${sender} and IP: ${ip}"
	
	
	volume[${s_domain}]=`echo "${get_db}" | awk 'NR == 7'`
	junk[${s_domain}]=`echo "${get_db}" | awk 'NR == 8'`
	score[${s_domain}]=`echo "${get_db}" | awk 'NR == 9'`	

	# echo "${volume[${s_domain}]} ${score[${s_domain}]}" | $WRITELOG
	[[ "$action" == "DUNNO" ]] && echo "${volume[${s_domain}]}|${volume[${ip}]}|${score[${s_domain}]}|${score[${sender}]}" | awk -F '|' '{if (($1+$2)/2>'"${Average_reputation}"' && $1*$2*$3*$4>0) exit (($3+$4)/2)/(($1+$2)/2)>='"${Average_reputation}"'?25:24}';
	[ $? -eq 25 ] && action="${soft_reject}.7.1 Poor avg. reputation for sender domain: ${s_domain} and IP: ${ip}"
	
	[[ "$action" == "DUNNO" ]] && echo "${volume[${s_domain}]}|${volume[${ip}]}|${junk[${s_domain}]}|${junk[${sender}]}" | awk -F '|' '{if (($1+$2)/2>'"${Average_reputation}"'*2 && $1*$2*$3>0) exit (($3+$4)/2)/(($1+$2)/2)*100>'"${Average_reputation}"'*10?25:24}';
	[ $? -eq 25 ] && action="${hard_reject}.7.1 Poor avg. rate for sender domain: ${s_domain} and IP: ${ip}"
	
	
	volume[${ip}]=`echo "${get_db}" | awk 'NR == 10'`
	junk[${ip}]=`echo "${get_db}" | awk 'NR == 11'`
	score[${ip}]=`echo "${get_db}" | awk 'NR == 12'`
	
	# echo "${volume[${ip}]} ${score[${ip}]}" | $WRITELOG
	[[ "$action" == "DUNNO" ]] && echo "${volume[${ip}]}|${score[${ip}]}" | awk -F '|' '{if ($1>'"${Average_reputation}"' && $1*$2>0) exit $2/$1>='"${Average_reputation}"'?25:24}';
	[ $? -eq 25 ] && action="${soft_reject}.7.1 Poor avg. reputation for IP: ${ip}"
	
	[[ "$action" == "DUNNO" ]] && echo "${volume[${ip}]}|${junk[${ip}]}" | awk -F '|' '{if ($1>'"${Average_reputation}"'*2 && $1*$2>0) exit $2/$1*100>'"${Average_reputation}"'*10?25:24}';
	[ $? -eq 25 ] && action="${hard_reject}.7.1 Poor avg. rate for IP: ${ip}"


	volume[${class_c}]=`echo "${get_db}" | awk 'NR == 13'`
	junk[${class_c}]=`echo "${get_db}" | awk 'NR == 14'`
	score[${class_c}]=`echo "${get_db}" | awk 'NR == 15'`	
	
	# echo "${volume[${class_c}]} ${score[${class_c}]}" |$WRITELOG
	[[ "$action" == "DUNNO" ]] && echo "${volume[${class_c}]}|${volume[${ip}]}|${score[${class_c}]}|${score[${ip}]}" | awk -F '|' '{if (($1+$2)/2>'"${Average_reputation}"' && $1*$2*$3*$4>0) exit (($3+$4)/2)/(($1+$2)/2)>='"${Average_reputation}"'?25:24}';
	[ $? -eq 25 ] && action="${soft_reject}.7.1 Poor avg. reputation for IP class: ${class_c}.0/24"
	
	[[ "$action" == "DUNNO" ]] && echo "${volume[${class_c}]}|${volume[${ip}]}|${junk[${class_c}]}|${junk[${ip}]}" | awk -F '|' '{if (($1+$2)/2>'"${Average_reputation}"'*10 && $1*$2*$3>0) exit (($3+$4)/2)/(($1+$2)/2)*10>'"${Average_reputation}"'*10?25:24}';
	[ $? -eq 25 ] && action="${hard_reject}.7.1 Poor avg. rate for IP class: ${class_c}.0/24"
	

	volume[${client}]=`echo "${get_db}" | awk 'NR == 16'`
	junk[${client}]=`echo "${get_db}" | awk 'NR == 17'`
	score[${client}]=`echo "${get_db}" | awk 'NR == 18'`
	
	# echo "${volume[${client}]} ${score[${client}]}" |$WRITELOG
	[[ "$action" == "DUNNO" ]] && echo "${volume[${client}]}|${volume[${s_domain}]}|${score[${client}]}|${score[${s_domain}]}" | awk -F '|' '{if (($1+$2)/2>'"${Average_reputation}"' && $1*$2*$3*$4>0) exit (($3+$4)/2)/(($1+$2)/2)>='"${Average_reputation}"'?25:24}';
	[ $? -eq 25 ] && action="${soft_reject}.7.1 Poor avg. reputation for client: ${client} and sender domain: ${s_domain}"
	
	[[ "$action" == "DUNNO" ]] && echo "${volume[${client}]}|${volume[${s_domain}]}|${junk[${client}]}|${junk[${s_domain}]}" | awk -F '|' '{if (($1+$2)/2>'"${Average_reputation}"'*2 && $1*$2*$3*$4>0) exit (($3+$4)/2)/(($1+$2)/2)*100>'"${Average_reputation}"'*10?25:24}';
	[ $? -eq 25 ] && action="${hard_reject}.7.1 Poor avg. rate for client: ${client} and sender domain: ${s_domain}"

	# Enforce STARTTLS for sources known as using it - defer if otherwise

	if [ ${Average_reputation} -le 5 ]; then
	    encryption[${s_domain}]=`echo "${get_db}" | awk 'NR == 19'`
	    encryption[${ip}]=`echo "${get_db}" | awk 'NR == 20'`

	    # echo "${volume[${s_domain}]} ${encryption[${s_domain}]} ${volume[${ip}]} ${encryption[${ip}]} ${starttls}" | $WRITELOG
	    [[ "$action" == "DUNNO" ]] && echo "${volume[${s_domain}]}|${encryption[${s_domain}]}|${starttls}" | awk -F '|' '{if ($1>'"${Average_reputation}"' && $2==1) exit $2*$3==0?25:24}';
	    [ $? -eq 25 ] && action="430 4.7.0 Message content not accepted without STARTTLS. Encryption protocol required from Sender domain: ${s_domain}"

		[[ "$action" == "DUNNO" ]] && echo "${volume[${ip}]}|${encryption[${ip}]}|${starttls}" | awk -F '|' '{if ($1>=1 && $2==1) exit $2*$3==0?25:24}';
		[ $? -eq 25 ] && action="430 4.7.0 Message content not accepted without STARTTLS. Encryption protocol required from IP: ${ip}"
	fi

  fi


echo "Sender: ${key[sender]}, NS: ${s_ns_all[*]}, Recipients: ${key[recipient]}, Client: ${client}[${ip}], Protocol: ${key[encryption_protocol]}" |\
$WRITELOG 

fi

echo "action=$action" && echo "";


	if [[ "$action" == "DUNNO" && ${starttls} -eq 1 ]]; then

	# Record some data from successful session

post_data=$(cat <<END
set "stls:${s_domain}" "${starttls}"
set "stls:${ip}" "${starttls}"
expire "stls:${s_domain}" "${d}"
expire "stls:${ip}" "${h}"
END
)

	# Write data into DB
cat <<END | redis-cli -n 5
${post_data}
END

	fi

}


while read line; do

if ! [[ -z $line ]]; then

    left=`echo $line 	| cut -d "=" -f1 	| awk '{print tolower($0)}'`
    right=`echo $line 	| cut -d "=" -f2- 	| awk '{print tolower($0)}'`

    key[$left]="${right}";

    [ "${key[sender]}" != "" ]		&& sender=`echo ${key[sender]} 					| awk -F '@' '/@/ {print tolower($0)}'`
    [ "${key[sender]}" != "" ]		&& s_domain=`echo ${key[sender]} 				| awk -F '@' '/@/ {print tolower($2)}'`

    [ "${key[recipient]}" != "" ]	&& recipient=`echo ${key[recipient]} 			| awk -F '@' '/@/ {print tolower($0)}'`
    [ "${key[recipient]}" != "" ]	&& recipient_mbx=`echo ${key[recipient]}		| awk -F '@' '/@/ {print tolower($1)}'`
    [ "${key[recipient]}" != "" ]	&& r_domain=`echo ${key[recipient]}				| awk -F '@' '/@/ {print tolower($2)}'`

    [ "${key[client_address]}" != "" ]	&& ip=${key[client_address]}
    [ "${key[client_address]}" != "" ]	&& class_b=`echo ${key[client_address]} 	| awk -F '.' '{print $1"."$2}'`
    [ "${key[client_address]}" != "" ]	&& class_c=`echo ${key[client_address]} 	| awk -F '.' '{print $1"."$2"."$3}'`
    [ ! -z ${key[reverse_client_name]} ]	&& client="${key[reverse_client_name]}"
    starttls=1;
    [ -z ${key[encryption_protocol]} ] && starttls=0;

else

    action=DUNNO;
    ([ "${key[sender]}" != "" -a "${key[recipient]}" != "" -a "${key[client_address]}" != "" -a "${starttls}" != "" ] && policy) || (echo "action=$action" && echo "");
	unset key; unset volume; unset junk; unset score; unset encryption;
	declare -A key; declare -A volume; declare -A junk; declare -A score; declare -A encryption;
    action=DUNNO;

fi

done

exit $?

