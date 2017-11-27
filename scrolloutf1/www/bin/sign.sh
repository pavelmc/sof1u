#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

pwd=/var/spool/filter
disclaimers=/var/spool/disclaimers
url="http://`hostname -f`/report.php"
id=sign.`echo $RANDOM`.`echo $RANDOM`
SENDMAIL="/usr/sbin/sendmail -G -i -f"
PYZ="/usr/bin/pyzor --homedir=$pwd -t 10"
WRITELOG="logger -t postfix/sign -i -p mail.info"

# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

test -d $pwd || mkdir -p $pwd
test -d $disclaimers || mkdir -p $disclaimers
umask 077

test -f /var/www/traffic.cfg && . /var/www/traffic.cfg

# encrypt="/var/www/bin/crypt.sh encrypt"
# decrypt="/var/www/bin/crypt.sh decrypt"
# encode="/var/www/bin/crypt.sh encode"
# decode="/var/www/bin/crypt.sh decode"

# Clean up when done or when aborting.
function cleanup() {
test -f $pwd/$id.$$ && (rm -f $pwd/$id.$$ && echo "${queue_id}: Message removed." | $WRITELOG)
test -f $disclaimers/$id.$$.txt && rm -f $disclaimers/$id.$$.txt
test -f $disclaimers/$id.$$.html && rm -f $disclaimers/$id.$$.html
test -f $disclaimers/$id.$$.b64 && rm -f $disclaimers/$id.$$.b64
}

trap cleanup 0 1 2 3 15

# Start processing.
cd $pwd || (
echo $pwd does not exist; exit $EX_TEMPFAIL; )

queue_id=""; queue_id=`echo "$@" | awk -F ' -- ' '{print $5}'`

sender=""; sender=`echo "$@" | awk -F ' -- '  '{print tolower($1)}'`
s_mbx=""; s_domain=`echo "$sender" | awk -F '@'  '/@/ {print tolower($1)}'`
s_domain=""; s_domain=`echo "$sender" | awk -F '@'  '/@/ {print tolower($2)}'`

recipient=""; recipient=`echo "$@" | awk -F ' -- ' '{print tolower($2)}'`
r_domain=""; r_domain=`echo "$recipient" | awk -F '@'  '/@/ {print tolower($2)}'`
recipient_array=(${recipient});
total_recipients=${#recipient_array[*]};


ip=""; ip=`echo "$@" | awk -F ' -- ' '{print tolower($3)}'`
[[ "${ip}" != "127.0.0.1" ]]    && class_c=`echo ${ip} | awk -F '.' '{print $1"."$2"."$3}'`

client=""; client=`echo "$@" | awk -F ' -- ' '{print tolower($4)}'`



cat >$pwd/$id.$$ && (echo "${queue_id}: Message saved." | $WRITELOG) || (
echo "Cannot save mail to file $pwd/$id.$$"; exit $EX_TEMPFAIL;
echo "${queue_id}: Message cannot be saved to $pwd/$id.$$" | $WRITELOG
)

if [ "${ip}" != "127.0.0.1" -a "${s_mbx}" != "postmaster" -a "${sender}" != "" ]; then

cat <<END >$disclaimers/$id.$$.txt

Report concern: $url?qid=${queue_id}
END

cat <<END >$disclaimers/$id.$$.html

<!-- Report concern: --><br><p style="font-family: Arial,Verdana,Helvetica,Calibri,sans-serif; font-size: 8pt;">
<!-- rReport concern: --><br>
<!-- Report concern: --><a href="$url?qid=${queue_id}" style="text-decoration: none;color:#424242;">Report concern<a>
<!-- Report concern: --></p><br>


END


cat <<END | base64 >$disclaimers/$id.$$.b64

<!-- Report concern: --><br><p style="font-family: Arial,Verdana,Helvetica,Calibri,sans-serif; font-size: 8pt;">
<!-- Report concern: --><br>
<!-- Report concern: --><a href="$url?qid=${queue_id}" style="text-decoration: none;color:#424242;">Report concern<a>
<!-- Report concern: --></p><br>

END


    if echo ${r_domain} | grep -q "scrolloutf1"; then
    /usr/bin/altermime --multipart-insert \
                    --input=$pwd/$id.$$ \
                    --disclaimer=$disclaimers/$id.$$.txt \
                    --xheader=X-Report-Abuse:" $url?qid=${queue_id}" \
                    --disclaimer-html=$disclaimers/$id.$$.html \
                    --force-for-bad-html || \
                     ( echo Message content rejected; exit $EX_UNAVAILABLE; )
    fi
fi

# Send the message
$SENDMAIL "${sender}" -- "${recipient}" < $pwd/$id.$$ || (
    echo "Cannot read $pwd/$$id.$$ file"; exit $EM_TEMPFAIL;)

[[ $? -eq 0 ]] && echo "${queue_id}: Message re-queued." | $WRITELOG || (
echo "${queue_id}: Message couldn't be re-queued." | $WRITELOG
)

# Investigate more data

h=$(( 60*60 ));
d=$(( ${h}*24 ));
w=$(( ${d}*7 ));
m=$(( ${w}*5 ));

	xspf=; spf=; true_spf=1;
    xspf=`grep -m1 "^Received-SPF: " $pwd/$id.$$`    
    [[ ! -z ${xspf} ]] && spf=`echo "${xspf}" | awk '{print tolower($2)}'`;
	echo "$spf" | awk '{if ($1 != "" ) exit $1 !~ /fail|error/ ?25:24}';
	[[ $? -eq 25 ]] && true_spf=1 || true_spf=0;

	s_ns=""; s_ns_ip=; s_ns_all=; s_ns_allips=; res_s_domain=;
	if [ "${ip}" != "127.0.0.1" -a ${true_spf} -eq 1 ]; then
	
	if [ "${s_domain}" != "" ]; then
	
	res_s_domain=`dig -t any ${s_domain}. +trace +all +bufsize=1252 +time=3 +tries=2 2> /dev/null`;
	if [ $? -eq 0 ]; then

		s_ns=(`echo "$res_s_domain" | awk '/^\S+\.\S+\s+\S+\s+IN\s+NS\s+\S+\.$/ {print tolower($NF)}' | sort -u`);

		for ((ns=0; ns<${#s_ns[*]}; ns++ )); do
			s_ns_ip[$ns]=`echo "$res_s_domain" | awk '/\s+\S+\s+IN\s+A+\s+/ {print tolower($0)}' | awk '/^'"${s_ns[$ns]}"'/ {print tolower($NF)}' | sort -u`
			[[ -z ${s_ns_ip[$ns]} ]] && s_ns_ip[$ns]=`host -W 3 ${s_ns[$ns]} 2> /dev/null | awk '/ has / {print $NF}' | sort -u`
			s_ns_allips=( `echo ${s_ns_allips[*]} ${s_ns_ip[$ns]}` )
			s_ns_all=( `echo ${s_ns_all[*]} ${s_ns[$ns]}"["${s_ns_ip[$ns]}"]"` )
		done

	fi
	
	fi
	
    junk=0;
    pck=1;
    fp=`$PYZ digest < $pwd/$id.$$`

    if [[ ! -z ${fp} ]]; then
	echo $fp | $PYZ -r 1 -w 1 -s digests check > /dev/null 2>&1;
	[[ $? -eq 0 ]] && pck=0;
    fi


    xspam=;
    xspam=`grep -m1 "^X-Spam-Status: " $pwd/$id.$$`
    score=;
    [[ ! -z ${xspam} ]] && score=`echo "${xspam}" | awk '{print $3}' | awk -F '=' '{print $2}'`

	if echo "${score} 5" | awk '{exit $1>=$2?0:1}'; then
		junk=1;
		[[ ! -z ${fp} && ${pck} -eq 1 ]] && (echo "$fp" | $PYZ -s digests report > /dev/null 2>&1)
    elif echo "${xspam}" | grep -qm1 "^X-Spam-Status: Yes"; then
		junk=1;
    elif echo "${score} -1" | awk '{exit $1<=$2?0:1}'; then
		junk=0;
		[[ ! -z ${fp} && ${pck} -eq 0 ]] && (echo "$fp" | $PYZ -s digests whitelist > /dev/null 2>&1)
    fi


[[ ${pck} -eq 0 ]] && pck_log="yes" || pck_log="no"
[[ ${junk} -eq 1 ]] && junk_log="yes" || junk_log="no"

total_junk=$(( ${junk} * ${#recipient_array[*]} ));
int_score=${score%.*};
total_score=`echo "${score} ${total_recipients}" | awk '{print $1 * $2}'`;
total_int_score=${total_score%.*};

post_data=$(cat <<END
hmset "qid:${queue_id}" sender "${sender}" spf "${spf}" ns "${s_ns_all[*]}" recipient "${recipient}" ip "${ip}" client "${client}" pyzor "${fp}:${pck}" junk "${junk_log}" score "${total_int_score}" volume "${total_recipients}"
hincrby "sr:${sender} -- ${recipient}" volume "$(( ${total_recipients} * ${true_spf} ))"
hincrby "sr:${sender} -- ${recipient}" junk "$(( ${total_junk} * ${true_spf} ))"
incrby "sr_score:${sender} -- ${recipient}" "$(( ${total_int_score} * ${true_spf} ))"
hincrby "s:${sender}" volume "$(( ${total_recipients} * ${true_spf} ))"
hincrby "s:${sender}" junk "$(( ${total_junk} * ${true_spf} ))"
incrby "s_score:${sender}" "$(( ${total_int_score} * ${true_spf} ))"
hincrby "sd:${s_domain}" volume "$(( ${total_recipients} * ${true_spf} ))"
hincrby "sd:${s_domain}" junk "$(( ${total_junk} * ${true_spf} ))"
incrby "sd_score:${s_domain}" "$(( ${total_int_score} * ${true_spf} ))"
hincrby "fp:${fp}" volume "${total_recipients}"
hincrby "fp:${fp}" junk "${total_junk}"
incrby "fp_score:${fp}" "${total_int_score}"
hincrby "ip:${ip}" volume "${total_recipients}"
hincrby "ip:${ip}" junk "${total_junk}"
incrby "ip_score:${ip}" "${total_int_score}"
hincrby "ipc:${class_c}" volume "${total_recipients}"
hincrby "ipc:${class_c}" junk "${total_junk}"
incrby "ipc_score:${class_c}" "${total_int_score}"
hincrby "c:${client}" volume "${total_recipients}"
hincrby "c:${client}" junk "${total_junk}"
incrby "c_score:${client}" "${total_int_score}"
expire "qid:${queue_id}" "${w}"
expire "sr:${sender} -- ${recipient}" "${w}"
expire "s:${sender}" "${d}"
expire "sd:${s_domain}" "${w}"
expire "fp:${fp}" "${w}"
expire "ip:${ip}" "${d}"
expire "ipc:${class_c}" "${w}"
expire "c:${client}" "${d}"
expire "sr_score:${sender} -- ${recipient}" "${w}"
expire "s_score:${sender}" "${h}"
expire "sd_score:${s_domain}" "${d}"
expire "fp_score:${fp}" "${w}"
expire "ip_score:${ip}" "${h}"
expire "ipc_score:${class_c}" "${d}"
expire "c_score:${client}" "${h}"
END
)

post_ns_names=$(
    for ((ns=0; ns<${#s_ns[*]}; ns++ )); do
cat<<END 
hincrby "ns:${s_ns[$ns]}" volume "$(( ${total_recipients} * ${true_spf} ))"
hincrby "ns:${s_ns[$ns]}" junk "$(( ${total_junk} * ${true_spf} ))"
incrby "ns_score:${s_ns[$ns]}" "$(( ${total_int_score} * ${true_spf} ))"
expire "ns:${s_ns[$ns]}" "${w}"
expire "ns_score:${s_ns[$ns]}" "${d}"
END
    done
)

post_ns_ips=$(
    for ((ns=0; ns<${#s_ns_allips[*]}; ns++ )); do
cat<<END 
hincrby "ns_ip:${s_ns_allips[$ns]}" volume "$(( ${total_recipients} * ${true_spf} ))"
hincrby "ns_ip:${s_ns_allips[$ns]}" junk "$(( ${total_junk} * ${true_spf} ))"
incrby "ns_ip_score:${s_ns_allips[$ns]}" "$(( ${total_int_score} * ${true_spf} ))"
expire "ns_ip:${s_ns_allips[$ns]}" "${w}"
expire "ns_ip_score:${s_ns_allips[$ns]}" "${d}"
END
    done
)

# Save collected data in db
cat <<END | redis-cli -n 5
${post_data}
${post_ns_names}
${post_ns_ips}
END


# Log collected data

echo "Sender: ${sender}, SPF: ${spf}, NS: ${s_ns_all[*]}, Recipients: ${recipient}, Client: ${client} [${ip}], Queue-ID: ${queue_id}, FP: ${fp}, Pyzor: ${pck_log}, Junk: ${junk_log}, Score: ${score}/${total_score}, Volume: ${total_recipients}" |\
$WRITELOG 

fi


exit $?


