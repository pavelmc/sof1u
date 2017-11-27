#!/bin/bash


#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################


CONFIG=/var/www/bin/config.sh
. $CONFIG

run=/var/run/scrollout;

f_cleanup() {
rm -f $tmp/*$uid
test -f $run/scrollout.pid && rm $run/scrollout.pid
postqueue -f
}

trap f_cleanup 0 1 2 3 15
test -f $run/scrollout.pid && sleep 30 && (test -f $run/scrollout.pid && kill -9 $(head -1 $run/scrollout.pid)) && rm -f $run/scrollout.pid;
echo $$ > $run/scrollout.pid

let max_servers=`free -m | grep "^Mem" | awk -F " " '{print $2}'`/200
let active_queue=`free -m | grep "^Mem" | awk -F " " '{print $2}'`*5
let conc_limit=$(( $max_servers / ${#domain[*]} ))
[[ $max_servers -gt 130 ]] && max_servers=130;
[[ $max_servers -lt 2 ]] && max_servers=2;
[[ $conc_limit -lt 4 ]] && conc_limit=4;


# mailname
# lockfile-create $tmp/mailname
test -f $tmp/mailname.tmp && rm -f $tmp/mailname.tmp
echo -e "$domain\n$hostname.$domain\n" > $tmp/mailname.tmp && mv $tmp/mailname.tmp /etc/mailname
# lockfile-remove $tmp/mailname

# config and place main.cf and fuzzy
# lockfile-create $tmp/main.cf
test -f $tmp/main.cf.tmp$uid && rm -f $tmp/main.cf.tmp$uid

	csip=`echo "${sip[*]}" | grep -v "^ *$" | sed "s/ $//"`
	rblt=${#sip[*]};
	rbl_action=enforce;
	test $rblt = 0 && (rblt=1 && rbl_action=ignore);
	# echo $csip
	
	if ! [ "$shostname" = "$empty" ]; then
	cshostname=`len=${#shostname[*]}
	i=0
	while [ $i -lt $len ];
	do
	printf "reject_rhsbl_helo ${shostname[$i]} "
	printf "reject_rhsbl_reverse_client ${shostname[$i]} "
	let i++
	done | grep -v "^ *$" | sed "s/ $//"`
	# echo $cshostname
	fi
	
	if ! [ "$sdomain" = "$empty" ]; then
	csdomain=`len=${#sdomain[*]}
	i=0
	while [ $i -lt $len ];
	do
	printf "reject_rhsbl_sender ${sdomain[$i]} "
	let i++
	done | grep -v "^ *$" | sed "s/ $//"`
	# echo $csdomain
	fi

i=0;
rm -fr /etc/postfix/ldaps/ldap-*-*.cf
while [ $i -lt ${#domain[*]} ]; do

if [[ ${ldap[$i]} == "" ]]; then	
    if echo ${lsrv[$i]} | grep -q ":"; then
		server_host[$i]=`echo "${lsrv[$i]}" | awk -F ":" '{print $1}'`;
		server_port[$i]=`echo "${lsrv[$i]}" | awk -F ":" '{print $2}'`;
		else
		server_host[$i]=${lsrv[$i]};
		server_port[$i]=389;
		fi
    start_tls[$i]=no;
else
    if echo ${lsrv[$i]} | grep -q ":"; then
		server_host[$i]=`echo "ldaps://${lsrv[$i]}" | awk -F ":" '{print $1":"$2}'`;
		server_port[$i]=`echo "ldaps://${lsrv[$i]}" | awk -F ":" '{print $3}'`;
		else
		server_host[$i]="ldaps://${lsrv[$i]}";
		server_port[$i]=636;
		fi
    start_tls[$i]=yes;
fi


test ! -z ${lsrv[$i]} && cat <<END> /etc/postfix/ldaps/ldap-common-${domain[$i]}.cf
domain = ${domain[$i]}
server_host = ${server_host[$i]}
server_port = ${server_port[$i]}
# start_tls = ${start_tls[$i]}
version = 3 
`[[ -z ${ldom[$i]} ]] && echo "search_base =" || echo "search_base = $(echo "${ldom[$i]}" | awk '{gsub(/^/,"dc="); gsub(/\./,", dc=")}{print}')"`
scope = sub
query_filter = (&(|(objectClass=inetOrgPerson)(objectclass=group)(objectclass=person)(objectclass=contact)(objectclass=user)(objectclass=publicFolder)(objectclass=msExchDynamicDistributionList)(objectclass=zimbraDistributionList)(zimbraMailStatus=enabled)(objectclass=dominoPerson)(objectclass=dominoGroup)(objectclass=dominoServerMailInDatabase))(|(mail=%s)(uid=%s)(proxyAddresses=SMTP:%s)(proxyAddresses=smtp:%s)(mailAlternateAddress=%s)(zimbraMailDeliveryAddress=%s)(zimbraMailAlias=%s)(zimbraMailCatchAllAddress=%s)))
leaf_result_attribute = proxyAddresses,mail,uid,msExchDynamicDistributionList,zimbraMailDeliveryAddress,zimbraMailForwardingAddress,zimbraPrefMailForwardingAddress #,zimbraMailCatchAllForwardingAddress
ldap_cache = yes
ldap_cache_expiry = 600
ldap_cache_size = 64256
timeout = 30
`[[ ! -z ${lpass[$i]} ]] && echo "bind = yes" || echo "bind = no"`
`[[ ! -z ${ldom[$i]} ]] && echo "bind_dn = ${luser[$i]}@${ldom[$i]}" || echo "bind_dn = ${luser[$i]}"`
`[[ ! -z ${lpass[$i]} ]] && echo "bind_pw = ${lpass[$i]}"`

END


let i++
done


ldap_nos=`grep -ls "^# start_tls = no" /etc/postfix/ldaps/* | awk '/ldap-common-/ {print " proxy:ldap:"$NF}'`
ldap_s=`grep -ls "^# start_tls = yes" /etc/postfix/ldaps/* | awk '/ldap-common-/ {print " proxy:ldap:"$NF}'`

ldap_maps=`printf "$ldap_nos\n$ldap_s\n"`;

let msg_size=`free -b | grep "^Mem" | awk -F " " '{print $2}'`/20

[ "$web" = "$empty" ] && web="http://www.$domain";
[ "$tel" = "$empty" ] && tel="your administrator";

jail_file=`cat $template/$Auto_defense/jail.local |\
sed -e "s#^ignoreip = .*#ignoreip = 127.0.0.1/8 192.168.0.0/16 10.0.0.0/8 172.16.0.0/12 $gateway $mynetworks ${mynets[*]}#" -e "s#^destemail = .*#destemail = $mailbox#"
`

echo "$jail_file" > /etc/fail2ban/jail.local
cp $template/$Auto_defense/spam.action.conf /etc/fail2ban/action.d/spam.conf
cp $template/$Auto_defense/spam.conf /etc/fail2ban/filter.d/
cp $template/$Auto_defense/spam_{light,bounce,rdns,malware,bulk,zero}.conf /etc/fail2ban/filter.d/
cp $template/$Auto_defense/postfix_exceeded.conf /etc/fail2ban/filter.d/
chmod 644 /etc/fail2ban/filter.d/*

local_ports=`netstat -natp | awk '{print $4}'`
cbpolicyd=`echo "$local_ports" | grep ":10031$"`
[[ "$cbpolicyd" = "$empty" ]] && cbpolicyd="###" || cbpolicyd="";

[[ $Rate_limits_in > 5 ]] && off_policy="###" || off_policy="";

main_file=`cat "$template/$Connection_filter/main.cf" |\
sed "s/:52428800/:$msg_size/" |\
sed "s/xSIPx/postscreen_dnsbl_action = $rbl_action\npostscreen_dnsbl_threshold = \$\{stress?1\}\$\{stress:$rblt\}\npostscreen_dnsbl_sites = $csip/" |\
sed "s/xSDOMAINx/$csdomain/" | sed "s/xSHOSTNAMEx/$cshostname/" |\
sed -e "s/xORGANIZATIONx/\- ${organization[*]}/" -e "s#web-here#$web#" -e "s#tel-here#$tel#" |\
sed "s/# check_policy_service inet:127.0.0.1:10031$/${cbpolicyd}check_policy_service inet:127.0.0.1:10031/" |\
sed "s/check_policy_service unix:private\/policy$/${off_policy}check_policy_service unix:private\/policy/" |\
sed "s/\tcheck_policy_service unix:private\/policy-spf$/\t${off_policy}check_policy_service unix:private\/policy-spf/" |\
sed "s/xHOSTNAMEx/$hostname/g" | sed "s/xDOMAINx/$domain/g" | sed "s/xRELAYDOMAINx/${domain[*]}/g" | grep -v "^   *$";
echo "default_process_limit=\$"{"stress?$(($max_servers*20*$Rate_limits_out))"}"\$"{"stress:$(($max_servers*10*$Rate_limits_out))"}""

# add host relay
	if ! [ "$hostrelay" = "$empty" ]
	then
	echo -e "\nrelayhost = $hostrelay\n"
	fi

# Disabled IPv6 is not in use
if [[ -z $ipv6 ]]; then
	echo "inet_protocols = ipv4"
fi
	
test "$uhostrelay" != "$empty" && printf "\nsmtp_sasl_auth_enable = yes\nsmtp_sasl_security_options =\nsmtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" ||\
(test "$urelays" != "$empty" && printf "\nsmtp_sasl_auth_enable = yes\nsmtp_sasl_security_options =\nsmtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd");

histchars=
	if ! [ "${tnets[*]}" = "$empty" ]
   then
	echo -e "\nmynetworks = !$gateway/32 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 $mynetworks ${tnets[*]}\n"
	else
	echo -e "\nmynetworks = !$gateway/32 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 $mynetworks\n"
	fi
unset histchars;
cat $template/$Rate_limits_in/anvil.cf
echo ""
[[ $Rate_limits_out -le 6 ]] && echo "smtp_helo_timeout=$(($Rate_limits_out*100))"
[[ $Rate_limits_out -le 6 ]] && echo "smtp_connect_timeout=$(($Rate_limits_out*10))"
[[ $Rate_limits_in -le 6 ]] && echo "smtpd_recipient_limit=$(($Rate_limits_in*100))"
[[ $Rate_limits_in -le 6 ]] && echo "smtpd_recipient_overshoot_limit=$Rate_limits_in"00""
[[ $Rate_limits_out -le 6 ]] && echo "initial_destination_concurrency=$((($Rate_limits_out+3)/2))"
[[ $Rate_limits_out -le 6 ]] && echo "default_destination_concurrency_limit=$(($Rate_limits_out*$Rate_limits_out))"
default_destination_recipient_limit=$(($Rate_limits_out*10))
echo "default_destination_recipient_limit=$default_destination_recipient_limit"
[[ $Rate_limits_out -le 2 ]] && echo "default_destination_rate_delay=$((60/$default_destination_recipient_limit))s"
[[ $Rate_limits_out -le 3 ]] && echo "default_destination_concurrency_failed_cohort_limit=$((($Rate_limits_out+3)/2*10))"
echo "qmgr_message_recipient_limit=$active_queue"
echo "qmgr_message_active_limit=$active_queue"
echo "default_recipient_limit=$active_queue"

echo "in_flow_delay = 2s"
[[ ! -z $msg_size ]] && echo "# queue_minfree = $(($msg_size*5))"

for ((i=0; i<${#domain[*]}; i++));do
# dest_dom=$(echo "${domain[$i]}" | sed "s/[[:punct:]]/_/g")
dest_dom=${domain[$i]};
cat $template/$Rate_limits_out/smtp_reply_wa.pcre > /etc/postfix/smtp_reply_filter/$dest_dom"_"reply_filter
[[ "${spamd[$i]}" = "checked" ]] && cat $template/$Rate_limits_out/smtp_reply_filter.pcre >> /etc/postfix/smtp_reply_filter/$dest_dom"_"reply_filter
[[ "${bounce[$i]}" = "checked" ]] && cat $template/$Rate_limits_out/smtp_reply_bounce.pcre >> /etc/postfix/smtp_reply_filter/$dest_dom"_"reply_filter

done
`

echo "$main_file" | awk -v ldap="$ldap_maps" '/relay_recipient_maps / {$0=$0 "\n"ldap} {print}' > $tmp/main.cf.tmp$uid
test -f $tmp/main.cf.tmp$uid && mv $tmp/main.cf.tmp$uid $www/postfix/main.cf
cp $cfg/{10-auth.conf,10-master.conf,auth-passwdfile.conf.ext,10-ssl.conf} /etc/dovecot/conf.d/

# lockfile-remove $tmp/main.cf

# copy fuzzyocr settings
# lockfile-create $tmp/fuzzy
cp -p $template/$Picture_filter/FuzzyOcr.* /etc/mail/spamassassin
cp $template/$Picture_filter/pic /etc/mail/spamassassin/pic.cf
cp $template/$URL_filter/urltemplate /etc/mail/spamassassin/urltemplate.cf
# cp -p /etc/mail/spamassassin/local.cf /etc/spamassassin/local.cf
# cp -p $template/$Body_filter/imageinfo.* /etc/mail/spamassassin
# lockfile-remove $tmp/fuzzy


# place master.cf
# lockfile-create $tmp/master.cf
test -f $tmp/master.cf.tmp$uid && rm -f $tmp/master.cf.tmp$uid
sed -e "s/max_servers/$max_servers/g" -e "s/conc_limit/$conc_limit/g" $template/$Rate_limits_in/master.cf > $tmp/master.cf.tmp$uid
test -f $tmp/master.cf.tmp$uid && mv $tmp/master.cf.tmp$uid  $www/postfix/master.cf;
# lockfile-remove $tmp/master.cf

# config and place postgrey
# lockfile-create $tmp/postgrey
#test -f $tmp/postgrey.tmp && rm -f $tmp/postgrey.tmp
#postgrey_message=`echo "$postgrey_code" | sed "s/[0-9]* \(.*\)$/\1/"`
#postgrey_code=`echo "$postgrey_code" | sed "s/^\([0-9]\{3\}\).*$/\1/"`
#cat "$template/$First_attempt_delay/postgrey" | sed "s/xCODEx/$postgrey_code/g" | sed "s/xMESSAGEx/$postgrey_message/g" > $tmp/postgrey.tmp && mv $tmp/postgrey.tmp /etc/default/postgrey
# lockfile-remove $tmp/postgrey



# config and place header
# lockfile-create $tmp/header
test -f $tmp/header.tmp && rm -f $tmp/header.tmp
header_mail=`echo "$header_code" | grep "@"`
test "$header_mail" = "$empty" || header_code="REDIRECT $header_code";
cat "$template/$Header_and_attachments_filter/header" | sed "s/xMESSAGEx/$header_code/g" > $tmp/header.tmp && mv $tmp/header.tmp $www/postfix/header;
cp $template/$Header_and_attachments_filter/header_{smtp,post_filter} /etc/postfix/;
cp $template/$Header_and_attachments_filter/clamd.conf /etc/clamav/;
# lockfile-remove $tmp/header


# config and place body
# lockfile-create $tmp/body
test -f $tmp/body.tmp && rm -f $tmp/body.tmp
body_mail=`echo "$body_code" | grep "@"`
test "$body_mail" = "$empty" || body_code="REDIRECT $body_code";
cat "$template/$Body_filter/body" | sed "s/xMESSAGEx/$body_code/g" > $tmp/body.tmp && mv $tmp/body.tmp $www/postfix/body;
# lockfile-remove $tmp/body



# config and place client
# lockfile-create $tmp/client
if [ $Hostname_filter -le 3 ]
then
	test -f $tmp/client.tmp && rm -f $tmp/client.tmp
	len=${#domain_reg[*]}
	i=0
	while [ $i -lt $len ];
	do
	printf "/\.${domain_reg[$i]}\$/\t$client_code\n" >> $tmp/client.tmp;
	let i++
	done
fi

if [ $Hostname_filter -gt 9 ]
then
	test -f $tmp/client.tmp && rm -f $tmp/client.tmp
	len=${#domain_reg[*]}
	i=0
	while [ $i -lt $len ];
	do
	printf "/\.${domain_reg[$i]}\$/\tOK\n" >> $tmp/client.tmp;
	let i++
	done
fi

cat "$template/$Hostname_filter/client" | sed "s/xMESSAGEx/$client_code/g" >> $tmp/client.tmp && mv $tmp/client.tmp $www/postfix/client;
# lockfile-remove $tmp/client

cp -p "$template/custom/postscreen_access.cidr" $www/postfix/postscreen_access.cidr

# config and place recipients
# lockfile-create $tmp/recipients;


test -f $tmp/recipients.tmp && rm -f $tmp/recipients.tmp
(len=${#domain_reg[*]}
i=0
while [ $i -lt $len ];
do
cat "$template/$Connection_filter/recipients" | sed "s/xDOMAINx/${domain_reg[$i]}/g";
	let i++
done | sort -u && printf "/^$mailbox_reg/\t$recipients_code\n") > $tmp/recipients.tmp && mv $tmp/recipients.tmp $www/postfix/recipients
postmap /etc/postfix/recipients
# lockfile-remove $tmp/recipients;

# config and place relay recipients
# lockfile-create $tmp/relay_recipients;
test -f $tmp/relay_recipients.tmp && rm -f $tmp/relay_recipients.tmp
len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
	[[ -z ${lsrv[$i]} ]] && cat "$template/$Connection_filter/relay_recipients" | sed "s/xDOMAINx/${domain[$i]}/g";
	let i++
done | sort -u > $tmp/relay_recipients.tmp && mv $tmp/relay_recipients.tmp $www/postfix/relay_recipients;
postmap /etc/postfix/relay_recipients
# lockfile-remove $tmp/relay_recipients;

if [ $Connection_filter -le 5 ]
then
# config and place sender
# lockfile-create $tmp/sender;
test -f $tmp/sender.tmp && rm -f $tmp/sender.tmp
len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
cat "$template/$Connection_filter/sender" | sed "s/xMESSAGEx/$sender_code/g" | sed -e "s/xDOMAINx/${domain[$i]}/g";
	let i++
done | sort -u > $tmp/sender.tmp && mv $tmp/sender.tmp $www/postfix/sender


else

test -f $tmp/sender.tmp && rm -f $tmp/sender.tmp
test -f /etc/postfix/sender && rm -f /etc/postfix/sender && touch /etc/postfix/sender;

fi


test -f /etc/postfix/sender && postmap /etc/postfix/sender;

test -f /etc/postfix/blocked_ips || touch /etc/postfix/blocked_ips
test -f /etc/postfix/allowed_ips || touch /etc/postfix/allowed_ips

test -f /etc/postfix/allowed_ips && postmap /etc/postfix/allowed_ips
test -f /etc/postfix/blocked_ips && postmap /etc/postfix/blocked_ips

test -f /etc/postfix/allowed_ips.db && mv /etc/postfix/allowed_ips.db /etc/postfix/allowed_ips.hash.db
test -f /etc/postfix/blocked_ips.db && mv /etc/postfix/blocked_ips.db /etc/postfix/blocked_ips.hash.db

# lockfile-remove $tmp/sender;

# config and place transport
# lockfile-create $tmp/transport;
test -f $tmp/transport.tmp && rm -f $tmp/transport.tmp


len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
	printf "\n${domain[$i]}\tto_${domain[$i]}:${transport[$i]}\n" | sed -e "s/,.*//g" -e "s/\]\[.*/]/g"
	let i++
done | sort -u +0 -0 | grep -v "^$" > $tmp/transport.tmp && mv $tmp/transport.tmp $www/postfix/transport
postmap /etc/postfix/transport;


cat /etc/postfix/transport | grep -i "^[a-z0-9]*" | awk '{print $1"\treject_unverified_sender"}' > /etc/postfix/sender_access && postmap /etc/postfix/sender_access
cat /etc/postfix/transport | grep -i "^[a-z0-9]*" | awk '{print $1"\tcheck_local_domain_spf"}' > /etc/postfix/check_local_domain_spf && postmap /etc/postfix/check_local_domain_spf
# lockfile-remove $tmp/transport;

# config and place host relays per each domain
test -f $tmp/relayhost_maps.tmp && rm -f $tmp/relayhost_maps.tmp
len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
	test ${hrelays[$i]} != " " > /dev/null 2>&1 && printf "@${domain[$i]}\t${hrelays[$i]}\n"
	let i++
done | sort -u +0 -0 > $tmp/relayhost_maps.tmp && mv $tmp/relayhost_maps.tmp $www/postfix/relayhost_maps

postmap /etc/postfix/relayhost_maps



# config and place outbound IP per each domain
test -f $tmp/assips_maps.tmp && rm -f $tmp/assips_maps.tmp
test -f $tmp/master_pipe.tmp$uid && rm -f $tmp/master_pipe.tmp$uid
test -f $tmp/master_smtp.tmp$uid && rm -f $tmp/master_smtp.tmp$uid


len=${#domain[*]}
i=0
eth=`ip link show | awk -F ": " '/^[0-9]*: .*: <BROADCAST,MULTICAST/ {print $2}'`;
dnet=`awk "/# This/,/^gateway/" /etc/network/interfaces`
echo -e "$dnet" > /etc/network/interfaces;

cat <<END >> $tmp/master_smtp.tmp$uid

127.0.0.1:10020 inet  n       n       n       -       0      spawn
	user=nobody argv=/var/www/bin/spawn.sh

END

. $run_dns pools;
. $run_srs;
# . $run_jitsi;

test -f $tmp/master_pipe.tmp$uid && cat $tmp/master_pipe.tmp$uid >> /etc/postfix/master.cf && rm -fr $tmp/master_pipe.tmp$uid
test -f $tmp/master_smtp.tmp$uid && cat $tmp/master_smtp.tmp$uid >> /etc/postfix/master.cf && rm -fr $tmp/master_smtp.tmp$uid
test -f /etc/postfix/assips_maps && postmap /etc/postfix/assips_maps


# config and place authentication for each host relays
test -f $tmp/sasl_passwd.tmp && rm -f $tmp/sasl_passwd.tmp
len=${#hrelays[*]}
i=0
while [ $i -lt $len ];
do
	# test ${urelays[$i]} != " " > /dev/null 2>&1 && printf "${hrelays[$i]}\t${urelays[$i]}:${prelays[$i]}\n"
	test ${urelays[$i]} != " " > /dev/null 2>&1 && printf "@${domain[$i]}\t${urelays[$i]}:${prelays[$i]}\n"
	let i++
done | sort -u +0 -0 > $tmp/sasl_passwd.tmp
(test "$uhostrelay" != "$empty" && printf "$hostrelay\t$uhostrelay:$phostrelay\n") >> $tmp/sasl_passwd.tmp
cat $tmp/sasl_passwd.tmp | sort -u > $www/postfix/sasl_passwd && rm -f $tmp/sasl_passwd.tmp ;

postmap /etc/postfix/sasl_passwd
chown root:root /etc/postfix/sasl_passwd && chmod 600 /etc/postfix/sasl_passwd


# lockfile-create $tmp/virtual;
# config and place virtual
test -f $tmp/virtual.tmp && rm -f $tmp/virtual.tmp
printf "\
\nroot\t$report_spam" | grep -v "^$" | sort -u > $tmp/virtual.tmp;

len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
	[[ ! -z ${redirect[$i]} ]] && printf "@`echo "${domain[$i]}\t${redirect[$i]}\n"`"
	let i++
done | sort -u | grep -v "^$" >> $tmp/virtual.tmp;

test -f $tmp/virtual.tmp && mv $tmp/virtual.tmp /etc/postfix/virtual
test -f /etc/postfix/virtual && postmap /etc/postfix/virtual

test -f $tmp/recipient_access.tmp && rm -f $tmp/recipient_access.tmp
printf "\
\nroot\tpermissive" | grep -v "^$" | sort -u > $tmp/recipient_access.tmp;
[[ ! -z $satrap ]] && (echo "$satrap" | parallel --gnu "echo {} permissive" | sort -u >> $tmp/recipient_access.tmp)
cat /etc/postfix/transport | grep -i "^[a-z0-9]*" | sort -u | awk '{print $1"\treject_unverified_recipient"}' >> $tmp/recipient_access.tmp
test -f $tmp/recipient_access.tmp && mv $tmp/recipient_access.tmp $www/postfix/recipient_access
postmap /etc/postfix/recipient_access
# lockfile-remove $tmp/virtual;


# config and place virtual_alias
# lockfile-create $tmp/virtual_alias;
test -f $tmp/virtual_alias.tmp && rm -f $tmp/virtual_alias.tmp
if ! [ "$split" = "$empty" ]
then
	 split=(`printf "${split[*]}\n" | sed "s/\(^\)/\1\\$1@/" | sed "s/\( \)/\1\\$1@/g"`)
len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
	printf "/^(.*)@${domain[$i]}\$/\t\$1@${domain[$i]} ${split[*]}\n"
	let i++
done | sort -u | grep -v "^$" > $tmp/virtual_alias.tmp && mv $tmp/virtual_alias.tmp $www/postfix/virtual_alias
else
    echo "" > $tmp/virtual_alias.tmp && mv $tmp/virtual_alias.tmp $www/postfix/virtual_alias;
fi


if ! [ "{$clones[*]}" = "$empty" ];
then

len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
	[[ ! -z ${clones[$i]} ]] && printf "\n/^(.*)\@`echo "${domain[$i]}" | sed "s/\([[:punct:]]\)/\\\\\\\\\1/g"`\$/\t\$1@${domain[$i]} `printf "${clones[$i]}\n" | sed -e "s/\(^\)/\1\\$1@/" -e "s/,/ /g" -e "s/\( \)/\1\\$1@/g"`"
	let i++
done | sort -u | grep -v "^$" > $tmp/virtual_alias.tmp && mv $tmp/virtual_alias.tmp $www/postfix/virtual_alias;
else
    echo "" > $tmp/virtual_alias.tmp && mv $tmp/virtual_alias.tmp $www/postfix/virtual_alias;
fi

echo "" > $www/postfix/recipient_bcc

if ! [ "{$receiversd[*]}" = "$empty" ];
then

len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
	[[ ! -z ${receiversd[$i]} ]] && printf "\n${receivers[$i]}@${domain[$i]}\t${receiversd[$i]}"
	let i++
done | sort -u | grep -v "^$" > $tmp/recipient_bcc.tmp && mv $tmp/recipient_bcc.tmp $www/postfix/recipient_bcc;
else
    echo "" > $tmp/recipient_bcc.tmp && mv $tmp/recipient_bcc.tmp $www/postfix/recipient_bcc
fi
postmap $www/postfix/recipient_bcc;

echo "" > $www/postfix/sender_bcc

if ! [ "{$sendersd[*]}" = "$empty" ];
then

len=${#domain[*]}
i=0
while [ $i -lt $len ];
do
	[[ ! -z ${sendersd[$i]} ]] && printf "\n${senders[$i]}@${domain[$i]}\t${sendersd[$i]}"
	let i++
done | sort -u | grep -v "^$" > $tmp/sender_bcc.tmp && mv $tmp/sender_bcc.tmp $www/postfix/sender_bcc;
else
    echo "" > $tmp/sender_bcc.tmp && mv $tmp/sender_bcc.tmp $www/postfix/sender_bcc; 
fi
postmap $www/postfix/sender_bcc;
# lockfile-remove $tmp/virtual_alias;

test -f /etc/postfix/virtual_custom && postmap /etc/postfix/virtual_custom
test -f /etc/postfix/client_ips_custom && postmap /etc/postfix/client_ips_custom

# update amavis
# lockfile-create $tmp/amavis
cat $template/$Spamassassin/20-debian_defaults | sed "s/xREPORT_SPAMx/$report_spam_reg/g" | sed -e "s/xREPORT_VIRUSx/$report_virus_reg/g" > $tmp/20-debian_defaults.tmp
sed -i -e "s#.*loadplugin Mail::SpamAssassin::Plugin::AWL#\#loadplugin Mail::SpamAssassin::Plugin::AWL#" /etc/spamassassin/v310.pre
sed -i -e "s#.*loadplugin Mail::SpamAssassin::Plugin::SpamCop#\#loadplugin Mail::SpamAssassin::Plugin::SpamCop#" /etc/spamassassin/v310.pre
cp $template/$Spamassassin/20_mspike.cf /etc/spamassassin/
cp $template/$Spamassassin/20_new_domains.cf /etc/spamassassin/

# Disable SPF whitelist for Amazon
sed -i -e "s/^\(def_whitelist_from_spf.*amazon.*\)$/# \1/g" /var/lib/spamassassin/*/updates_spamassassin_org/60_whitelist_spf.cf

filetype=`cat $template/$Header_and_attachments_filter/filetype`
(cat $tmp/20-debian_defaults.tmp | awk '/^use strict/,/^xFILETYPEx/' && echo "$filetype") > $tmp/20-debian_defaults.p1
cat $tmp/20-debian_defaults.tmp | awk '/^xFILETYPEx/,/eof/' > $tmp/20-debian_defaults.p2

test -f $www/amavis/conf.d/20-maps && mv $www/amavis/conf.d/20-maps $www/amavis/conf.d/23-maps;
test -d /var/www/disclaimer || mkdir -p /var/www/disclaimer;
# test -f /var/www/disclaimer/default.txt || printf "Mail protected by Scrollout\n" > /var/www/disclaimer/default.txt;
test -f /var/www/disclaimer/default.txt || touch /var/www/disclaimer/default.txt;
test -f /var/www/disclaimer/default.html || touch /var/www/disclaimer/default.html;

mydomains=`grep "domain=" /var/www/traffic.cfg | sed -e "s/domain=/@local_domains_maps = /" -e "s/' /', /g" -e "s/(/[/" -e "s/)/,]/" `

printf "
use strict;
$mydomains

# ------------ Disclaimer Setting ---------------
\$allow_disclaimers = 1;
\$defang_maps_by_ccat{+CC_CATCHALL} = [ 'disclaimer' ];
# Program used to signing disclaimer in outgoing mails.
\$altermime = '/usr/bin/altermime';

# Disclaimer in plain text formart.
@altermime_args_disclaimer = qw(--multipart-insert --disclaimer=/var/www/disclaimer/_OPTION_.txt --disclaimer-html=/var/www/disclaimer/_OPTION_.html --force-for-bad-html);
" > $tmp/23-maps.tmp$uid;



printf "
@disclaimer_options_bysender_maps = (
	{
" >> $tmp/23-maps.tmp$uid;

len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	# test -f /var/www/disclaimer/${domain[$i]}.txt || printf "Mail protected by Scrollout\n" > /var/www/disclaimer/${domain[$i]}.txt;
	test -f /var/www/disclaimer/${domain[$i]}.txt || touch /var/www/disclaimer/${domain[$i]}.txt;
	test -f /var/www/disclaimer/${domain[$i]}.html || touch /var/www/disclaimer/${domain[$i]}.html;
	disclaimer=;
	disclaimer=`cat /var/www/disclaimer/${domain[$i]}.txt`
	if [ "$disclaimer" != "" ]; then
	printf "'${domain[$i]}' => '${domain[$i]}',\n"
	fi
let i++;
done >> $tmp/23-maps.tmp$uid;

cat <<END>> $tmp/23-maps.tmp$uid;
 '.' => 'default',
	},
	);
# ------------ End Disclaimer Setting ---------------

END



printf "

@forward_method_maps = (
	{
" >> $tmp/23-maps.tmp$uid;

len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ ! -z "${srsto[$i]}" ] && printf "'.${domain[$i]}' => 'smtp:[127.0.0.1]:10030',\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

printf "
'.' => \$forward_method,
}
);
"  >> $tmp/23-maps.tmp$uid;



printf "

@spam_subject_tag2_maps = (
	{
" >> $tmp/23-maps.tmp$uid;

len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${sbj[$i]}" != "" ] && printf "'.${domain[$i]}' => '${sbj[$i]} (_REQD_) _SCORE_: ',\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

printf "
'.' => \$sa_spam_subject_tag,
}
);
"  >> $tmp/23-maps.tmp$uid;



printf "

@spam_tag2_level_maps = (
	{
" >> $tmp/23-maps.tmp$uid;

len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${tag[$i]}" != "" ] && printf "'.${domain[$i]}' => ${tag[$i]},\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

printf "},
\$sa_tag2_level_deflt,   # catchall default,
	);"  >> $tmp/23-maps.tmp$uid;


printf "

@spam_kill_level_maps = (
	{
" >> $tmp/23-maps.tmp$uid;

len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${block[$i]}" != "" ] && printf "'.${domain[$i]}' => ${block[$i]},\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

printf "},
\$sa_kill_level_deflt,   # catchall default,
	);"  >> $tmp/23-maps.tmp$uid;




printf "

@spam_quarantine_cutoff_level_maps = (
	{
" >> $tmp/23-maps.tmp$uid;

len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${cutoff[$i]}" != "" ] && printf "'.${domain[$i]}' => ${cutoff[$i]},\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

printf "},
\$sa_quarantine_cutoff_level,   # catchall default,
	);
	
	@spam_dsn_cutoff_level_bysender_maps = (\@spam_quarantine_cutoff_level_maps);
	
	"  >> $tmp/23-maps.tmp$uid;





printf "

@spam_notifyadmin_cutoff_level_maps = (
	{
" >> $tmp/23-maps.tmp$uid;

len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${cutoff[$i]}" != "" ] && printf "'.${domain[$i]}' => ${cutoff[$i]},\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

printf "},
\$sa_quarantine_cutoff_level,   # catchall default,
	);"  >> $tmp/23-maps.tmp$uid;






printf "

@spam_quarantine_to_maps = (
	{
" >> $tmp/23-maps.tmp$uid;

len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${quarantine[$i]}" != "" -a "${spam[$i]}" == "" ] && printf "'.${domain[$i]}'=>'${quarantine[$i]}',\n";
	[ "${spam[$i]}" == "checked" ] && printf "'.${domain[$i]}'=>'',\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

[ -z "$spamc" ] && printf "'.' => \$spam_quarantine_to, # a catchall default 
	},
\$spam_quarantine_to,
	);"  >> $tmp/23-maps.tmp$uid;

[ "$spamc" == "1" ] && printf "'.' => '', # a catchall default 
	},
'',
	);

	@spam_quarantine_bysender_to_maps = (\@spam_quarantine_to_maps);
	
	"  >> $tmp/23-maps.tmp$uid;



	
printf "

@virus_quarantine_to_maps = (
	{
" >> $tmp/23-maps.tmp$uid;
len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${quarantine[$i]}" != "" -a "${virus[$i]}" == "" ] && printf "'.${domain[$i]}'=>'${quarantine[$i]}',\n";
	[ "${virus[$i]}" == "checked" ] && printf "'.${domain[$i]}'=>'',\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

[ -z "$virusc" ] && printf "'.' => \$virus_quarantine_to, # a catchall default 
	},
\$virus_quarantine_to,
	);"  >> $tmp/23-maps.tmp$uid;
	
[ "$virusc" == "1" ] && printf "'.' => '', # a catchall default 
	},
'',
	);"  >> $tmp/23-maps.tmp$uid;


printf "

@banned_quarantine_to_maps = (
	{
" >> $tmp/23-maps.tmp$uid;
len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${quarantine[$i]}" != "" -a "${ban[$i]}" == "" ] && printf "'.${domain[$i]}'=>'${quarantine[$i]}',\n";
	[ "${ban[$i]}" == "checked" ] && printf "'.${domain[$i]}'=>'',\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

[ -z "$banc" ] && printf "'.' => \$banned_quarantine_to, # a catchall default 
	},
\$banned_quarantine_to,
	);"  >> $tmp/23-maps.tmp$uid;

[ "$banc" == "1" ] && printf "'.' => '', # a catchall default 
	},
'',
	);"  >> $tmp/23-maps.tmp$uid;

printf "

@spam_admin_maps = (
	{
" >> $tmp/23-maps.tmp$uid;
len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${quarantine[$i]}" != "" -a "${spam[$i]}" == "" -a "${report[$i]}" == "" ] && printf "'.${domain[$i]}'=>'${quarantine[$i]}',\n";
	[ "${spam[$i]}" == "checked" -o "${report[$i]}" == "checked" ] && printf "'.${domain[$i]}'=>'',\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

if [ ! "$spamc" -o ! "$reportc" ]; then printf "'.' => \$spam_admin, # a catchall default 
	},
\$spam_admin,
	);"  >> $tmp/23-maps.tmp$uid;

elif [ "$spamc" -o "$reportc" ]; then printf "'.' => '', # a catchall default 
	},
'',
	);"  >> $tmp/23-maps.tmp$uid;
fi


printf "

@virus_admin_maps = (
	{
" >> $tmp/23-maps.tmp$uid;
len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${quarantine[$i]}" != "" -a "${virus[$i]}" == "" -a "${report[$i]}" == "" ] && printf "'.${domain[$i]}'=>'${quarantine[$i]}',\n";
	[ "${virus[$i]}" == "checked" -o "${report[$i]}" == "checked" ] && printf "'.${domain[$i]}'=>'',\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

if [ ! "$virusc" -o ! "$reportc" ]; then printf "'.' => \$virus_admin, # a catchall default 
	},
\$virus_admin,
	);"  >> $tmp/23-maps.tmp$uid;
	
elif [ "$virusc" -o "$reportc" ]; then printf "'.' => '', # a catchall default 
	},
'',
	);"  >> $tmp/23-maps.tmp$uid;
fi


printf "
@banned_admin_maps = (
	{
" >> $tmp/23-maps.tmp$uid;
len=${#domain[@]}
i=0
while [ $i -lt $len ];
do
	[ "${quarantine[$i]}" != "" -a "${ban[$i]}" == "" -a "${report[$i]}" == "" ] && printf "'.${domain[$i]}'=>'${quarantine[$i]}',\n";
	[ "${ban[$i]}" == "checked" -o "${report[$i]}" == "checked" ] && printf "'.${domain[$i]}'=>'',\n";
let i++;
done >> $tmp/23-maps.tmp$uid;

if [ ! "$banc" -o ! "$reportc" ]; then printf "'.' => \$banned_admin, # a catchall default 
	},
\$banned_admin,
	);
1;  # ensure a defined return	
"  >> $tmp/23-maps.tmp$uid;

elif [ "$banc" -o "$reportc" ]; then printf "'.' => '', # a catchall default 
	},
'',
	);
	
1;  # ensure a defined return
"  >> $tmp/23-maps.tmp$uid;
fi

test -f $tmp/23-maps.tmp$uid && mv $tmp/23-maps.tmp$uid /etc/amavis/conf.d/23-maps;
find {$tmp/23-maps.tmp*,/etc/amavis/conf.d/23-maps.tmp*} -type f -mtime +1 -delete > /dev/null 2>&1;

cat $tmp/20-debian_defaults.p1 $tmp/20-debian_defaults.p2 | grep -v "xFILETYPEx" > $www/amavis/conf.d/20-debian_defaults && rm $tmp/20-debian_defaults*;

cat $template/$Header_and_attachments_filter/21-ubuntu_defaults | sed "s/xREPORT_SPAMx/$report_spam_reg/g" | sed -e "s/xREPORT_VIRUSx/$report_virus_reg/g" > $www/amavis/conf.d/21-ubuntu_defaults
cat $template/$Spamassassin/05-node_id | sed "s/xHOSTNAMEx/$hostname/g" | sed "s/xDOMAINx/$domain/g" > $www/amavis/conf.d/05-node_id
cp $template/$Header_and_attachments_filter/15-content_filter_mode $www/amavis/conf.d
cp $template/$Header_and_attachments_filter/01-debian $www/amavis/conf.d
cp $template/$Body_filter/15-av_scanners  $www/amavis/conf.d
cp $template/$Connection_filter/esmtp_access /etc/postfix/esmtp_access;
# cp $template/$IPSec_encryption/racoon.conf /etc/racoon/;
cp $template/$Spam_trap_score/bayes_redis.cf /etc/spamassassin/

awk '/^Debian/ { exit $3 >= 8 ? 0 : 1 }' /etc/issue;
[ $? -eq 0 ] && cp $template/$Average_reputation/40-redis /etc/amavis/conf.d || rm -fr /etc/amavis/conf.d/40-redis;

echo "" > /etc/postfix/blocked_mx
[[ $Connection_filter -le 6 ]] &&  echo "`hostname -f`		DUNNO" | grep -v "^$" > /etc/postfix/blocked_mx
[[ $Connection_filter -le 5 ]] &&  echo "$(host `hostname -f` | head -1 | grep "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | awk '{print $NF"\tDUNNO"}')" | grep -v "^$" >> /etc/postfix/blocked_mx
cat $template/$Connection_filter/blocked_mx >> /etc/postfix/blocked_mx && postmap /etc/postfix/blocked_mx;

let mc_size_size=`free -k | grep "^Mem" | awk -F " " '{print $2}'`/25

let disksize=`df | awk '/\/$/ {print $2}'`/1024/4;
sed -i -e "s/.*auth_worker_max_count = .*/auth_worker_max_count = 300/" /etc/dovecot/conf.d/10-auth.conf;

sed "s/max_servers/\$max_servers = $max_servers;/" $template/$Header_and_attachments_filter/50-user > $www/amavis/conf.d/50-user

test -f /etc/postfix/esmtp_access && rm /etc/postfix/esmtp_access;

esmtp=`for ((m=0;m<${#mynets[*]};m++)); do
[[ ${mynets[$m]} != "" ]] && echo "${mynets[$m]}" | sed 's/,\| \|$/\t\tsilent-discard\n/g'
done | sort -u`

(echo "$esmtp" && cat $template/$Connection_filter/esmtp_access) | grep -v '^ \|^$\|^!\|^silent-discard' >> /etc/postfix/esmtp_access;


# lockfile-remove $tmp/amavis

# create spam trap file
if ! [[ -z $satrap ]];
then
printf "<!-- COPY & PASTE the following spam traps somewhere in the source of your web site -->\n" > $tmp/spamtraps.tmp
		echo "$satrap" | parallel --gnu 'printf "<a href=\"mailto:{}\">{}</a>\n"' | sort -u >> $tmp/spamtraps.tmp && mv $tmp/spamtraps.tmp $www/spamtraps.csv;
else
	printf "No spamtraps specified\n" > $tmp/spamtraps.tmp && mv $tmp/spamtraps.tmp $www/spamtraps.csv;
fi

if [ $Body_filter -ge 7 ]
then

sed -i "/pyzor_options\|pyzor_timeout/d" /etc/spamassassin/local.cf; 

cat <<EOF  >> /etc/spamassassin/local.cf;

pyzor_options --homedir /var/lib/amavis/.pyzor/ -r 2 -w 0 -t 10
pyzor_timeout 10

EOF


cat <<END> /var/lib/.pyzor/config
[server]
Engine = redis
DigestDB = localhost,6379,,10

[client]
ReportThreshold = 2
WhitelistThreshold = 0

END

cat <<END> /var/lib/amavis/.pyzor/config
[client]
ReportThreshold = 2
WhitelistThreshold = 0

END

elif [ $Body_filter -le 6 ] && ! [ $Body_filter -le 3 ]
then

sed -i "/pyzor_options\|pyzor_timeout/d" /etc/spamassassin/local.cf; 

cat <<EOF  >> /etc/spamassassin/local.cf;

pyzor_options --homedir /var/lib/amavis/.pyzor/ -r 1 -w 1 -t 10
pyzor_timeout 10

EOF

cat <<END> /var/lib/.pyzor/config
[server]
Engine = redis
DigestDB = localhost,6379,,10

[client]
ReportThreshold = 1
WhitelistThreshold = 1

END

cat <<END> /var/lib/amavis/.pyzor/config
[client]
ReportThreshold = 1
WhitelistThreshold = 1

END

elif [ $Body_filter -le 3 ]
then

sed -i "/pyzor_options\|pyzor_timeout/d" /etc/spamassassin/local.cf; 

cat <<EOF  >> /etc/spamassassin/local.cf;

pyzor_options --homedir /var/lib/amavis/.pyzor/ -r 0 -w 2 -t 10
pyzor_timeout 10

EOF

cat <<END> /var/lib/.pyzor/config
[server]
Engine = redis
DigestDB = localhost,6379,,10

[client]
ReportThreshold = 0
WhitelistThreshold = 2

END

cat <<END> /var/lib/amavis/.pyzor/config
[client]
ReportThreshold = 0
WhitelistThreshold = 2

END

fi

mynets=(`echo "${mynets[*]}" | sed 's/\( *\|^\)\(!?192\|10\|172\)\.[0-9]*\.[0-9]*\.[0-9]*\/[0-9]*\( \|$\)/ /g' | sed 's/  \|,/ /g' | tr ' ' '\n' | grep -vi "[a-z]" | sort -ur | tr '\n' ' '`);

histchars=
if [ $Hostname_filter -ge 7 ]
then
	(grep -vE "internal_networks|trusted_networks|rbl_timeout|clear_trusted_networks|clear_internal_networks" $sp_library/local.cf && \
	printf "

clear_trusted_networks
clear_internal_networks

internal_networks [fc00::]/7 192.168.0.0/16 172.16.0.0/12 !$gateway/32 ${mynets[*]}
trusted_networks [fc00::]/7 192.168.0.0/16 172.16.0.0/12 !$gateway/32 ${mynets[*]}

rbl_timeout 30

") | sed "N;/^\n$/d;P;D"  >> $tmp/local.cf$$.tmp
	 mv $tmp/local.cf$$.tmp $sp_library/local.cf
	 
printf "

header		LOCAL_AUTH_RCVD		Received =~ /\s+\(Authenticated sender:\s+.*\@.*\)\s+by\s+`hostname -f | sed "s/\./\\\\\./g"`\s+\(Postfix\)/
describe	LOCAL_AUTH_RCVD		From a MSA host
score		LOCAL_AUTH_RCVD		-$Hostname_filter

header		WITH_TLS_PFS		Received =~ /\(using TLSv.* with cipher .* by `hostname -f | sed "s/\./\\\\\./g"` \(Postfix\)/
describe	WITH_TLS_PFS		Spam bots don't usually use TLS encryption
score		WITH_TLS_PFS		-2.$Hostname_filter

header		WITH_SSL_PFS		Received =~ /\(using SSLv.* by `hostname -f | sed "s/\./\\\\\./g"` \(Postfix\)/
describe	WITH_SSL_PFS		Possibly unmaintained mail server using SSL, instead TLS
score		WITH_SSL_PFS		0.$((10-$Hostname_filter))

meta		SO_MKT3				(WITH_TLS_PFS && (!LOCAL_AUTH_RCVD || !trusted_networks || !internal_networks) && (T_DKIM_INVALID || DKIM_ADSP_CUSTOM_MED || DKIM_ADSP_DISCARD || SPF_FAIL || SPF_SOFTFAIL || SO_FK_FREEMAIL || FREEMAIL_FROM) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (PYZOR_CHECK || RAZOR2_CHECK || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (!BAYES_00 && !BAYES_05 && !BAYES_20) && _EXTERNAL_CONTENT)
describe	SO_MKT3				Suspect marketer or not compliant
score		SO_MKT3				0.$((10-$Hostname_filter))

meta		SO_WEAK_HOST		!WITH_TLS_PFS && (!LOCAL_AUTH_RCVD || !trusted_networks || !internal_networks) && (!DKIM_VALID && !DKIM_VALID_AU) && (!SPF_HELO_PASS && !SPF_PASS) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE || DYN_RDNS_AND_INLINE_IMAGE) && _EXTERNAL_CONTENT
describe	SO_WEAK_HOST		Unreliable host (no TLS, SPF, DKIM, RDNS), but external content
score		SO_WEAK_HOST		0.$((10-$Hostname_filter))

header		__SO_EXT_IP			X-Spam-Relays-External =~ /^\s*\[ ip=(!(?!(?:10|127|169\.254|172\.(?:1[6-9]|2[0-9]|3[01])|192\.168)\.)| )/
describe	__SO_EXT_IP			External IP detected in header
score		__SO_EXT_IP			0.001

meta		SO_INT_PROXY		__SO_EXT_IP && (LOCAL_AUTH_RCVD || trusted_networks || internal_networks) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && SO_FROM_RP
describe	SO_INT_PROXY		External msg. delivered via Intranet server
score		SO_INT_PROXY		0.0$((10-$Hostname_filter))

meta			SO_HOSTED_SPF		(!LOCAL_AUTH_RCVD || !trusted_networks || !internal_networks) && (!DKIM_VALID && !DKIM_VALID_AU) && (!SPF_HELO_PASS && !SPF_PASS) && (SPF_FAIL || SPF_SOFTFAIL) && (SO_LOCAL_FROM || SO_LOCAL_RETURN_PATH)
describe		SO_HOSTED_SPF		SPF failed for hosted (forged) domain.
score			SO_HOSTED_SPF		0.0$((10-$Hostname_filter))

meta		SO_LIGHT_DKIM_SPF		(SO_HOSTED_SPF && SPF_SOFTFAIL && T_DKIM_INVALID)
describe	SO_LIGHT_DKIM_SPF		Forged sender violating DKIM and SPF
score		SO_LIGHT_DKIM_SPF		0.$((10-$Hostname_filter))

score		SPF_SOFTFAIL		1.$((10-$Hostname_filter))
score		T_DKIM_INVALID		0.$((10-$Hostname_filter))

meta		CMPS_DOS_X_TO_MX	(DOS_OE_TO_MX || DOS_OUTLOOK_TO_MX) && LOCAL_AUTH_RCVD && SO_FROM_RP
describe	CMPS_DOS_X_TO_MX	Compensate DOS_OE_TO_MX DOS_OUTLOOK_TO_MX Rules
score		CMPS_DOS_X_TO_MX	-2.$Hostname_filter

score		ALL_TRUSTED		-1.$Hostname_filter -1.$Hostname_filter -2.$Hostname_filter -2.$Hostname_filter
score 		RCVD_IN_PBL		1.335
score		DOS_OE_TO_MX	0.523

score		RCVD_IN_DNSWL_LOW		0 -0.5 0 -0.5
score		RCVD_IN_DNSWL_MED		0 -2.0 0 -2.0
score		RCVD_IN_DNSWL_HI		0 -4 0 -4
score		RCVD_IN_DNSWL_BLOCKED 	0 0.001 0 0.001

score		PYZOR_CHECK				0 $((11-$Body_filter)).$((10-$Body_filter)) 0 $((10-$Body_filter)).$((10-$Body_filter))	# n=0 n=2

meta		SO_BAYPYZ				PYZOR_CHECK && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999)
describe	SO_BAYPYZ				Message from invalid RDNS seen in Pyzor and Bayes
score		SO_BAYPYZ				1.$((10-$Hostname_filter))

meta		SO_BAYPYZ2				PYZOR_CHECK && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (T_REMOTE_IMAGE || _EXTERNAL_CONTENT)
describe	SO_BAYPYZ2				Suspect message with external image and/or external content
score		SO_BAYPYZ2				1.$((10-$Hostname_filter))
tflags		SO_BAYPYZ2				autolearn_force

meta		SO_MALWARE				(PYZOR_CHECK || RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE || FREEMAIL_FROM) && (T_OBFU_HTML_ATTACH || T_OBFU_DOC_ATTACH || OBFU_DOC_ATTACH)
describe	SO_MALWARE				Message often seen as sending malware in MS files
score		SO_MALWARE				1.$((10-$Header_and_attachments_filter))

mimeheader	FILE_ATTACHED			Content-Type =~ /name=.+\.(?:pdf|eml|doc[xm]?|xl[st][xm]?|dot[xm]?|xml|zip|hm[il]?|s?html?|Z|gz|bz2|zpm|cpio|tar|ip|rar|arc|arj|zoo|ace|ade|adp|app|bas|bat|chm|cmd|com|cpl|crt|exe|fxp|grp|hlp|hta|hm[il]|inf|ins|isp|js|jse|lnk|mda|mdb|mde|mdw|mdt|mdz|msc|msi|msp|mst|ops|pcd|pif|prg|reg|scr|sct|shb|shs|vb|vbe|vbs|wsc|wsf|wsh)/i
describe	FILE_ATTACHED			email contains attachment
score		FILE_ATTACHED			0.$((10-$Header_and_attachments_filter))

meta		REPORTED_ATTACH			(PYZOR_CHECK || RAZOR2_CHECK) && (BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && FILE_ATTACHED
describe	REPORTED_ATTACH			mail contains reported attachment
score		REPORTED_ATTACH			1.$((10-$Header_and_attachments_filter))


" > $sp_library/tls_auth.cf
	 
elif [ $Hostname_filter -le 6 ] && ! [ $Hostname_filter -le 3 ]
then
(grep -vE "internal_networks|trusted_networks|rbl_timeout|clear_internal_networks|clear_trusted_networks" $sp_library/local.cf && \
	printf "

clear_trusted_networks
clear_internal_networks

internal_networks !$gateway/32
trusted_networks !$gateway/32 ${mynets[*]}

rbl_timeout 45

") | sed "N;/^\n$/d;P;D" >> $tmp/local.cf$$.tmp
	 mv $tmp/local.cf$$.tmp $sp_library/local.cf
	 
printf "
header		LOCAL_AUTH_RCVD		Received =~ /\s+\(Authenticated sender:\s+.*\@.*\)\s+by\s+`hostname -f | sed "s/\./\\\\\./g"`\s+\(Postfix\)/
describe	LOCAL_AUTH_RCVD		From a MSA host
score		LOCAL_AUTH_RCVD		-0.$Hostname_filter

header		WITH_TLS_PFS		Received =~ /\(using TLSv.* with cipher .* by `hostname -f | sed "s/\./\\\\\./g"` \(Postfix\)/
describe	WITH_TLS_PFS		Spam bots don't usually use TLS encryption
score		WITH_TLS_PFS		-0.$Hostname_filter

header		WITH_SSL_PFS		Received =~ /\(using SSLv.* by `hostname -f | sed "s/\./\\\\\./g"` \(Postfix\)/
describe	WITH_SSL_PFS		Possibly unmaintained mail server using SSL, instead TLS
score		WITH_SSL_PFS		0.$((10-$Hostname_filter))

meta		SO_MKT3				WITH_TLS_PFS && (T_DKIM_INVALID || DKIM_ADSP_CUSTOM_MED || DKIM_ADSP_DISCARD || SPF_FAIL || SPF_SOFTFAIL || SO_FK_FREEMAIL || FREEMAIL_FROM) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (PYZOR_CHECK || RAZOR2_CHECK || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (!BAYES_00 && !BAYES_05 && !BAYES_20) && _EXTERNAL_CONTENT
describe	SO_MKT3				Suspect marketer or not compliant
score		SO_MKT3				0.$((10-$Hostname_filter))

meta		SO_WEAK_HOST		!WITH_TLS_PFS && (!LOCAL_AUTH_RCVD || !trusted_networks || !internal_networks) && (!DKIM_VALID && !DKIM_VALID_AU) && (!SPF_HELO_PASS && !SPF_PASS) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE || DYN_RDNS_AND_INLINE_IMAGE) && _EXTERNAL_CONTENT
describe	SO_WEAK_HOST		Unreliable host (no TLS, SPF, DKIM, RDNS), but external content
score		SO_WEAK_HOST		0.$((10-$Hostname_filter))

header		__SO_EXT_IP			X-Spam-Relays-External =~ /^\s*\[ ip=(!(?!(?:10|127|169\.254|172\.(?:1[6-9]|2[0-9]|3[01])|192\.168)\.)| )/
describe	__SO_EXT_IP			External IP detected in header
score		__SO_EXT_IP			0.001

meta		SO_INT_PROXY		__SO_EXT_IP && (LOCAL_AUTH_RCVD || trusted_networks || internal_networks) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && SO_FROM_RP
describe	SO_INT_PROXY		External msg. delivered via Intranet server
score		SO_INT_PROXY		0.0$((10-$Hostname_filter))

meta			SO_HOSTED_SPF		(!LOCAL_AUTH_RCVD || !trusted_networks || !internal_networks) && (!DKIM_VALID && !DKIM_VALID_AU) && (!SPF_HELO_PASS && !SPF_PASS) && (SPF_FAIL || SPF_SOFTFAIL) && (SO_LOCAL_FROM || SO_LOCAL_RETURN_PATH)
describe		SO_HOSTED_SPF		SPF failed for hosted (forged) domain.
score			SO_HOSTED_SPF		$((10-$Hostname_filter))

meta		SO_LIGHT_DKIM_SPF		(SO_HOSTED_SPF && SPF_SOFTFAIL && T_DKIM_INVALID)
describe	SO_LIGHT_DKIM_SPF		Forged sender violating DKIM and SPF
score		SO_LIGHT_DKIM_SPF		1.$((10-$Hostname_filter))

score		SPF_SOFTFAIL		1.$((10-$Hostname_filter))
score		T_DKIM_INVALID		0 2.$((10-$Hostname_filter)) 0 1.$((10-$Hostname_filter))

score		ALL_TRUSTED		-0.$Hostname_filter -0.$Hostname_filter -1.$Hostname_filter -1.$Hostname_filter
score 		RCVD_IN_PBL		2.335

meta		CMPS_DOS_X_TO_MX	(DOS_OE_TO_MX || DOS_OUTLOOK_TO_MX) && LOCAL_AUTH_RCVD && SO_FROM_RP
describe	CMPS_DOS_X_TO_MX	Compensate DOS_OE_TO_MX DOS_OUTLOOK_TO_MX Rules
score		CMPS_DOS_X_TO_MX	-1.$Hostname_filter

score		RCVD_IN_DNSWL_LOW		0 -0.25 0 -0.25
score		RCVD_IN_DNSWL_MED		0 -1.5 0 -1.5
score		RCVD_IN_DNSWL_HI		0 -2 0 -2
score		RCVD_IN_DNSWL_BLOCKED 	0 0.1 0 0.1

tflags		RCVD_IN_DNSWL_LOW		nice net noautolearn
tflags		RCVD_IN_DNSWL_MED		nice net noautolearn
tflags		RCVD_IN_DNSWL_HI		nice net noautolearn

tflags		BAYES_00				nice learn 
tflags		BAYES_05				nice learn
tflags		BAYES_20				nice learn
tflags		BAYES_40				nice learn
tflags		BAYES_50				learn
tflags		BAYES_60				learn
tflags		BAYES_80				learn
tflags		BAYES_95				learn
tflags		BAYES_99				learn noautolearn
tflags		BAYES_999				learn noautolearn

tflags		USER_IN_SPF_WHITELIST		autolearn_force
tflags		USER_IN_DKIM_WHITELIST		autolearn_force
tflags		USER_IN_BLACKLIST			autolearn_force

score		RP_MATCHES_RCVD			-0.$Hostname_filter

score		PYZOR_CHECK				0 $((8-$Body_filter)).$((10-$Body_filter)) 0 $((7-$Body_filter)).$((10-$Body_filter))	# n=0 n=2

meta		SO_BAYPYZ				PYZOR_CHECK && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999)
describe	SO_BAYPYZ				Message from invalid RDNS seen in Pyzor and Bayes
score		SO_BAYPYZ				2.$((10-$Hostname_filter))

meta		SO_BAYPYZ2				PYZOR_CHECK && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (T_REMOTE_IMAGE || _EXTERNAL_CONTENT)
describe	SO_BAYPYZ2				Suspect message with external image and/or external content
score		SO_BAYPYZ2				2.$((10-$Hostname_filter))
tflags		SO_BAYPYZ2				autolearn_force

meta		SO_MALWARE				(PYZOR_CHECK || RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE || FREEMAIL_FROM) && (T_OBFU_HTML_ATTACH || T_OBFU_DOC_ATTACH || OBFU_DOC_ATTACH)
describe	SO_MALWARE				Message often seen as sending malware in MS files
score		SO_MALWARE				$((10-$Header_and_attachments_filter))
tflags		SO_MALWARE				autolearn_force

mimeheader	FILE_ATTACHED			Content-Type =~ /name=.+\.(?:pdf|eml|doc[xm]?|xl[st][xm]?|dot[xm]?|xml|zip|hm[il]?|s?html?|Z|gz|bz2|zpm|cpio|tar|ip|rar|arc|arj|zoo|ace|ade|adp|app|bas|bat|chm|cmd|com|cpl|crt|exe|fxp|grp|hlp|hta|hm[il]|inf|ins|isp|js|jse|lnk|mda|mdb|mde|mdw|mdt|mdz|msc|msi|msp|mst|ops|pcd|pif|prg|reg|scr|sct|shb|shs|vb|vbe|vbs|wsc|wsf|wsh)/i
describe	FILE_ATTACHED			email contains attachment
score		FILE_ATTACHED			0.$((10-$Header_and_attachments_filter))

meta		REPORTED_ATTACH			(PYZOR_CHECK || RAZOR2_CHECK) && (BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && FILE_ATTACHED
describe	REPORTED_ATTACH			mail contains reported attachment
score		REPORTED_ATTACH			2.$((10-$Header_and_attachments_filter))

score RCVD_IN_RP_RNBL 0
score RCVD_IN_RP_CERTIFIED 0
score RCVD_IN_RP_SAFE 0

score		FROM_NO_USER			0.001 3.599 1.019 2.798
score		MISSING_SUBJECT			0.001 3.767 2.300 2.799

" > $sp_library/tls_auth.cf

elif [ $Hostname_filter -le 3 ]
then
(grep -vE "internal_networks|trusted_networks|rbl_timeout|clear_trusted_networks|clear_internal_networks" $sp_library/local.cf && \
	printf "

clear_trusted_networks
clear_internal_networks

internal_networks !$gateway/32
trusted_networks !$gateway/32

rbl_timeout 60

") | sed "N;/^\n$/d;P;D" >> $tmp/local.cf$$.tmp
	 mv $tmp/local.cf$$.tmp $sp_library/local.cf
	 
printf "
header		LOCAL_AUTH_RCVD		Received =~ /\s+\(Authenticated sender:\s+.*\@.*\)\s+by\s+`hostname -f | sed "s/\./\\\\\./g"`\s+\(Postfix\)/
describe	LOCAL_AUTH_RCVD		From a MSA host
score		LOCAL_AUTH_RCVD		-0.0$Hostname_filter

header		WITH_TLS_PFS		Received =~ /\(using TLSv.* with cipher .* by `hostname -f | sed "s/\./\\\\\./g"` \(Postfix\)/
describe	WITH_TLS_PFS		Spam bots don't usually use TLS encryption
score		WITH_TLS_PFS		-0.0$Hostname_filter

header		WITH_SSL_PFS		Received =~ /\(using SSLv.* by `hostname -f | sed "s/\./\\\\\./g"` \(Postfix\)/
describe	WITH_SSL_PFS		Possibly unmaintained mail server using SSL, instead TLS
score		WITH_SSL_PFS		1.$((10-$Hostname_filter))

meta		SO_MKT3				WITH_TLS_PFS && (T_DKIM_INVALID || DKIM_ADSP_CUSTOM_MED || DKIM_ADSP_DISCARD || SPF_FAIL || SPF_SOFTFAIL || SO_FK_FREEMAIL || FREEMAIL_FROM) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (PYZOR_CHECK || RAZOR2_CHECK || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (!BAYES_00 && !BAYES_05 && !BAYES_20) && _EXTERNAL_CONTENT
describe	SO_MKT3				Suspect marketer or not compliant
score		SO_MKT3				0.$((10-$Hostname_filter))

meta		SO_WEAK_HOST		!WITH_TLS_PFS && (!LOCAL_AUTH_RCVD || !trusted_networks || !internal_networks) && (!DKIM_VALID && !DKIM_VALID_AU) && (!SPF_HELO_PASS && !SPF_PASS) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE || DYN_RDNS_AND_INLINE_IMAGE) && _EXTERNAL_CONTENT
describe	SO_WEAK_HOST		Unreliable host (no TLS, SPF, DKIM, RDNS), but external content
score		SO_WEAK_HOST		0.$((10-$Hostname_filter))

header		__SO_EXT_IP			X-Spam-Relays-External =~ /^\s*\[ ip=(!(?!(?:10|127|169\.254|172\.(?:1[6-9]|2[0-9]|3[01])|192\.168)\.)| )/
describe	__SO_EXT_IP			External IP detected in header
score		__SO_EXT_IP			0.001

meta		SO_INT_PROXY		__SO_EXT_IP && (LOCAL_AUTH_RCVD || trusted_networks || internal_networks) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && SO_FROM_RP
describe	SO_INT_PROXY		External msg. delivered via Intranet server
score		SO_INT_PROXY		0.0$((10-$Hostname_filter))

meta			SO_HOSTED_SPF		(!LOCAL_AUTH_RCVD || !trusted_networks || !internal_networks) && (!DKIM_VALID && !DKIM_VALID_AU) && (!SPF_HELO_PASS && !SPF_PASS) && (SPF_FAIL || SPF_SOFTFAIL) && (SO_LOCAL_FROM || SO_LOCAL_RETURN_PATH)
describe		SO_HOSTED_SPF		SPF failed for hosted (forged) domain.
score			SO_HOSTED_SPF		$((10-$Hostname_filter-2))

meta		SO_LIGHT_DKIM_SPF		(SO_HOSTED_SPF && SPF_SOFTFAIL && T_DKIM_INVALID)
describe	SO_LIGHT_DKIM_SPF		Forged sender violating DKIM and SPF
score		SO_LIGHT_DKIM_SPF		0.$((10-$Hostname_filter))

score		SPF_SOFTFAIL		1.$((10-$Hostname_filter))
score		T_DKIM_INVALID		$((10-$Hostname_filter)).$((10-$Hostname_filter))

meta		CMPS_DOS_X_TO_MX	(DOS_OE_TO_MX || DOS_OUTLOOK_TO_MX) && LOCAL_AUTH_RCVD && SO_FROM_RP
describe	CMPS_DOS_X_TO_MX	Compensate DOS_OE_TO_MX DOS_OUTLOOK_TO_MX Rules
score		CMPS_DOS_X_TO_MX	-0.$Hostname_filter

score		ALL_TRUSTED		-0.$Hostname_filter
score 		RCVD_IN_PBL		3.335
score		DOS_OE_TO_MX	2.523

score		RCVD_IN_DNSWL_LOW		0 -0.1 0 -0.1
score		RCVD_IN_DNSWL_MED		0 -0.5 0 -0.5
score		RCVD_IN_DNSWL_HI		0 -1 0 -1
score		RCVD_IN_DNSWL_BLOCKED 	0 0.5 0 0.5

tflags		RCVD_IN_DNSWL_LOW		net noautolearn
tflags		RCVD_IN_DNSWL_MED		net noautolearn
tflags		RCVD_IN_DNSWL_HI		net noautolearn

tflags		BAYES_00				nice learn
tflags		BAYES_05				nice learn
tflags		BAYES_20				nice learn
tflags		BAYES_40				nice learn
tflags		BAYES_50				learn
tflags		BAYES_60				learn
tflags		BAYES_80				learn
tflags		BAYES_95				learn
tflags		BAYES_99				learn
tflags		BAYES_999				learn noautolearn

tflags		USER_IN_SPF_WHITELIST		autolearn_force
tflags		USER_IN_DKIM_WHITELIST		autolearn_force
tflags		USER_IN_BLACKLIST			autolearn_force

score		RP_MATCHES_RCVD			-0.$Hostname_filter

score		PYZOR_CHECK				0 $((6-$Body_filter)).$((10-$Body_filter)) 0 $((5-$Body_filter)).$((10-$Body_filter))	# n=0 n=2

meta		SO_BAYPYZ				PYZOR_CHECK && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999)
describe	SO_BAYPYZ				Message from invalid RDNS seen in Pyzor and Bayes
score		SO_BAYPYZ				3.$((10-$Hostname_filter))

meta		SO_BAYPYZ2				PYZOR_CHECK && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE) && (RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (T_REMOTE_IMAGE || _EXTERNAL_CONTENT)
describe	SO_BAYPYZ2				Suspect message with external image and/or external content
score		SO_BAYPYZ2				3.$((10-$Hostname_filter))
tflags		SO_BAYPYZ2				autolearn_force

meta		SO_MALWARE				(PYZOR_CHECK || RAZOR2_CHECK || BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && (RDNS_DYNAMIC || SO_RDNS_UNKNOWN || RDNS_NONE || FREEMAIL_FROM) && (T_OBFU_HTML_ATTACH || T_OBFU_DOC_ATTACH || OBFU_DOC_ATTACH)
describe	SO_MALWARE				Message often seen as sending malware in MS files
score		SO_MALWARE				$((10-$Header_and_attachments_filter))
tflags		SO_MALWARE				autolearn_force

mimeheader	FILE_ATTACHED			Content-Type =~ /name=.+\.(?:pdf|eml|doc[xm]?|xl[st][xm]?|dot[xm]?|xml|zip|hm[il]?|s?html?|Z|gz|bz2|zpm|cpio|tar|ip|rar|arc|arj|zoo|ace|ade|adp|app|bas|bat|chm|cmd|com|cpl|crt|exe|fxp|grp|hlp|hta|hm[il]|inf|ins|isp|js|jse|lnk|mda|mdb|mde|mdw|mdt|mdz|msc|msi|msp|mst|ops|pcd|pif|prg|reg|scr|sct|shb|shs|vb|vbe|vbs|wsc|wsf|wsh)/i
describe	FILE_ATTACHED			email contains attachment
score		FILE_ATTACHED			0.$((10-$Header_and_attachments_filter))

meta		REPORTED_ATTACH			(PYZOR_CHECK || RAZOR2_CHECK) && (BAYES_50 || BAYES_60 || BAYES_80 || BAYES_95 || BAYES_99 || BAYES_999) && FILE_ATTACHED
describe	REPORTED_ATTACH			mail contains reported attachment
score		REPORTED_ATTACH			3.$((10-$Header_and_attachments_filter))

score RCVD_IN_RP_RNBL 0
score RCVD_IN_RP_CERTIFIED 0
score RCVD_IN_RP_SAFE 0

score		FROM_NO_USER			0.001 4.599 2.019 3.798
score		MISSING_SUBJECT			0.001 4.767 3.300 3.799

" > $sp_library/tls_auth.cf

fi

printf "

header		SO_SPAMFLAG		X-Spam-Flag =~ /YES/i
header		SO_XCS60		X-BTI-AntiSpam  =~ /\bscore:6[0-9],/i
header		SO_XCS70		X-BTI-AntiSpam  =~ /\bscore:7[0-9],/i
header		SO_XCS80		X-BTI-AntiSpam  =~ /\bscore:8[0-9],/i
header		SO_XCS90		X-BTI-AntiSpam  =~ /\bscore:9[0-9],/i
header		SO_XCS100		X-BTI-AntiSpam  =~ /\bscore:10[0-9],/i

describe		SO_SPAMFLAG		Message flagged as Spam by other SA gateway
describe		SO_XCS60		Message flagged as Spam by other XCS gateway, score 60
describe		SO_XCS70		Message flagged as Spam by other XCS gateway, score 70
describe		SO_XCS80		Message flagged as Spam by other XCS gateway, score 80
describe		SO_XCS90		Message flagged as Spam by other XCS gateway, score 90
describe		SO_XCS100		Message flagged as Spam by other XCS gateway, score 100

score		SO_SPAMFLAG		$((10-$Header_and_attachments_filter+5))
score		SO_XCS60		$((10-$Header_and_attachments_filter+6))
score		SO_XCS70		$((10-$Header_and_attachments_filter+7))
score		SO_XCS80		$((10-$Header_and_attachments_filter+8))
score		SO_XCS90		$((10-$Header_and_attachments_filter+9))
score		SO_XCS100		$((10-$Header_and_attachments_filter+10))

" > $sp_library/other_gw_headers.cf


printf "

header		SO_MSONLINE_SCL6		X-Message-Delivery =~ /^Vj0xLjE7dXM9MDtsPTA7YT0wO0Q9MjtHRD0yO1NDTD02$/
describe	SO_MSONLINE_SCL6		Microsoft on-line email service SCL6
score		SO_MSONLINE_SCL6		6.$((10-$Hostname_filter))
tflags		SO_MSONLINE_SCL6		autolearn_force

header		SO_MSONLINE_SCL5		X-Message-Delivery =~ /^Vj0xLjE7dXM9MDtsPTA7YT0wO0Q9MjtHRD0yO1NDTD01$/
describe	SO_MSONLINE_SCL5		Microsoft on-line email service SCL5
score		SO_MSONLINE_SCL5		5.$((10-$Hostname_filter))
tflags		SO_MSONLINE_SCL5		autolearn_force

header		SO_MSONLINE_SCL4		X-Message-Delivery =~ /^(?:Vj0xLjE7dXM9MDtsPTE7YT0wO0Q9MjtHRD0yO1NDTD00|Vj0xLjE7dXM9MDtsPTE7YT0xO0Q9MjtHRD0xO1NDTD00)$/
describe	SO_MSONLINE_SCL4		Microsoft on-line email service SCL4
score		SO_MSONLINE_SCL4		4.$((10-$Hostname_filter))

header		SO_MSONLINE_SCL2		X-Message-Delivery =~ /^Vj0xLjE7dXM9MTtsPTE7YT0wO0Q9MTtHRD0xO1NDTD0y$/
describe	SO_MSONLINE_SCL2		Microsoft on-line email service SCL2
score		SO_MSONLINE_SCL2		2.$((10-$Hostname_filter))

header		SO_MSONLINE_SCL1		X-Message-Delivery =~ /^Vj0xLjE7dXM9MDtsPTE7YT0xO0Q9MTtHRD0xO1NDTD0x$/
describe	SO_MSONLINE_SCL1		Microsoft on-line email service SCL1
score		SO_MSONLINE_SCL1		1.$((10-$Hostname_filter))
tflags		SO_MSONLINE_SCL1		nice

header		SO_MSONLINE_SCL0		X-Message-Delivery =~ /^(?:Vj0xLjE7dXM9MDtsPTE7YT0xO0Q9MTtHRD0xO1NDTD0w|Vj0xLjE7dXM9MDtsPTE7YT0wO0Q9MTtTQ0w9MA==)$/
describe	SO_MSONLINE_SCL0		Microsoft on-line email service SCL0
score		SO_MSONLINE_SCL0		-0.$Hostname_filter
tflags		SO_MSONLINE_SCL0		nice

" > $sp_library/msonline.cf

test -f $sp_library/aggressive_port.cf && rm $sp_library/aggressive_port.cf;

unset histchars


case $1 in
	security) . $runcountries tld; . $reload;;
	codes) . $runcountries reload;;
	traffic) . $run_dkim gen
				(test -f /etc/postfix/certs/scrollout.cert && (openssl x509 -text -in /etc/postfix/certs/scrollout.cert | grep -i "public-key" | grep -E "2048|4096" > /dev/null 2>&1)) || \
				(/etc/init.d/postfix stop && \
				openssl req -new -sha384 -newkey rsa:4096 -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -keyout /etc/postfix/certs/scrollout.key -out /etc/postfix/certs/scrollout.cert)
				[[ -f /etc/postfix/certs/scrollout-dsa.cert ]] || (openssl req -new -newkey dsa:<(openssl dsaparam 4096) -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -keyout /etc/postfix/certs/scrollout-dsa.key  -out /etc/postfix/certs/scrollout-dsa.cert && cp /etc/postfix/certs/scrollout-dsa.cert /usr/share/ca-certificates/)
				[[ -f /etc/postfix/certs/scrollout-ecdsa.cert ]] || (openssl req -new -sha384 -newkey ec:<(openssl ecparam -name secp384r1) -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -keyout /etc/postfix/certs/scrollout-ecdsa.key  -out /etc/postfix/certs/scrollout-ecdsa.cert && cp /etc/postfix/certs/scrollout-ecdsa.cert /usr/share/ca-certificates/)
				test -f /etc/postfix/certs/dh_512.pem || openssl dhparam -out /etc/postfix/certs/dh_512.pem 512
				test -f /etc/postfix/certs/dh_1024.pem || openssl dhparam -out /etc/postfix/certs/dh_1024.pem 1024
				test -f /etc/postfix/certs/dh_2048.pem || openssl dhparam -out /etc/postfix/certs/dh_2048.pem 2048
				test -f /etc/postfix/certs/scrollout-ecdsa.cert && chown root.www-data /etc/postfix/certs/scrollout*.{key,cert}
				test -f /etc/postfix/certs/scrollout.key && chmod 664 /etc/postfix/certs/scrollout*.{key,cert}
				# update-ca-certificates
				test -d /etc/dovecot/private || mkdir /etc/dovecot/private
				[[ -f /etc/dovecot/private/dovecot.pem ]] || openssl req -new -sha384 -newkey ec:<(openssl ecparam -name secp384r1) -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -out /etc/dovecot/dovecot.pem -keyout /etc/dovecot/private/dovecot.pem
				[[ -f /etc/dovecot/dovecot.pem ]] || openssl req -new -sha384 -newkey ec:<(openssl ecparam -name secp384r1) -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -out /etc/dovecot/dovecot.pem -keyout /etc/dovecot/private/dovecot.pem
				cp $cfg/{10-auth.conf,10-master.conf,auth-passwdfile.conf.ext,10-ssl.conf} /etc/dovecot/conf.d/

				smtp_port=25; 
				echo "#!/usr/sbin/setkey -f" > /etc/ipsec-tools.conf;
				echo "flush;" >> /etc/ipsec-tools.conf;
				echo "spdflush;" >> /etc/ipsec-tools.conf;
				# echo "" > /etc/racoon/psk.txt;
				for ((i=0; i<${#domain[$i]}; i++)); do
				[ ! -z "${ipsecips[$i]}" ] && ip_ipsec=(`echo ${ipsecips[$i]} | tr "," " "`);
				echo "### IPSec rules for ${domain[$i]}" >> /etc/ipsec-tools.conf;
    				for ((s=0; s<${#ip_ipsec[*]}; s++)); do
            			    [ ! -z "${ip_ipsec[$s]}" -a "${ipsecips[$i]}" ] && (
				    cst_smtp_port=`echo ${ip_ipsec[$s]} | grep ":" | cut -d ":" -f2` && ip_ipsec[$s]=`echo ${ip_ipsec[$s]} | cut -d ":" -f1`;
				    [ ! -z "$cst_smtp_port" ] && smtp_port=$cst_smtp_port;
				    echo "" >> /etc/ipsec-tools.conf;
            			    echo "spdadd 0.0.0.0/0  ${ip_ipsec[$s]}[$smtp_port]     any -P out      ipsec   esp/transport//require;" >> /etc/ipsec-tools.conf
            			    echo "spdadd 0.0.0.0/0  ${ip_ipsec[$s]}[$smtp_port]     any -P in       ipsec   esp/transport//require;" >> /etc/ipsec-tools.conf
            			    echo "spdadd 0.0.0.0/0[$smtp_port]  ${ip_ipsec[$s]}       any -P out      ipsec   esp/transport//require;" >> /etc/ipsec-tools.conf
            			    echo "spdadd 0.0.0.0/0[$smtp_port]  ${ip_ipsec[$s]}       any -P in       ipsec   esp/transport//require;" >> /etc/ipsec-tools.conf
            			    echo "" >> /etc/ipsec-tools.conf;
            			    # echo "${ip_ipsec[$s]}   ${ipseckey[$i]}" >> /etc/racoon/psk.txt
            			    )
    				done
				echo "" >> /etc/ipsec-tools.conf;
				echo "### END of IPSec rules for ${domain[$i]}" >> /etc/ipsec-tools.conf;
				echo "" >> /etc/ipsec-tools.conf;
				done
				for service in dovecot postfix rsyslog amavis postsrsd; do
				echo "$service"
				done | parallel --gnu "service {} restart" > /dev/null 2>&1
				service nginx reload > /dev/null 2>&1
	;;

	collector)
			  (grep -v "^all_spam_to" $sp_library/local.cf | grep -v "^dns_available" && printf "$param_sa") >> $tmp/local.cf$$.tmp
			  mv $tmp/local.cf$$.tmp $sp_library/local.cf
			  . $reload;;
esac;

ps -A | grep fail2ban | awk '{print $1}' | parallel --gnu kill -9 {} > /dev/null 2>&1
			test -f /etc/postfix/blocked_ips && rm /etc/postfix/blocked_ips
			test -f /etc/postfix/blocked_ips || touch /etc/postfix/blocked_ips
			postmap /etc/postfix/blocked_ips && mv /etc/postfix/blocked_ips.db /etc/postfix/blocked_ips.hash.db
			test -f /etc/postfix/allowed_ips && rm /etc/postfix/allowed_ips
			test -f /etc/postfix/allowed_ips || touch /etc/postfix/allowed_ips
			postmap /etc/postfix/allowed_ips && mv /etc/postfix/allowed_ips.db /etc/postfix/allowed_ips.hash.db
rm -f /var/run/fail2ban/fail2ban.sock
/etc/init.d/fail2ban restart > /dev/null 2>&1


rm -f $run/scrollout.pid
