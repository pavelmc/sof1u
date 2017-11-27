#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################


empty=
test -d /tmp/scrollout || mkdir /tmp/scrollout;
test -d /var/run/scrollout || mkdir /var/run/scrollout;
test -d /var/www/dkim || mkdir /var/www/dkim;
test -f /var/www/ver || date +%F > /var/www/ver;
test -f /etc/spamassassin/20_wb.cf || touch /etc/spamassassin/20_wb.cf;
test -f /etc/amavis/sndr || touch /etc/amavis/sndr;
test -f /etc/postfix/sndr || touch /etc/postfix/sndr;
test -f /etc/postfix/login_maps || touch /etc/postfix/login_maps && postmap /etc/postfix/login_maps;
test -f /etc/postfix/assips_maps || touch /etc/postfix/assips_maps && postmap /etc/postfix/assips_maps;
test -f /etc/postfix/recipient_access || touch /etc/postfix/recipient_access && postmap /etc/postfix/recipient_access;
test -f /etc/postfix/relayhost_maps || touch /etc/postfix/relayhost_maps && postmap /etc/postfix/relayhost_maps;
test -f /etc/postfix/relay_recipients || touch /etc/postfix/relay_recipients && postmap /etc/postfix/relay_recipients;
test -f /etc/postfix/sasl_passwd || touch /etc/postfix/sasl_passwd && postmap /etc/postfix/sasl_passwd;
test -f /etc/postfix/sender || touch /etc/postfix/sender && postmap /etc/postfix/sender;
test -f /etc/postfix/sender_access || touch /etc/postfix/sender_access && postmap /etc/postfix/sender_access;
test -f /etc/postfix/check_local_domain_spf || touch /etc/postfix/check_local_domain_spf && postmap /etc/postfix/check_local_domain_spf;
test -f /etc/postfix/transport || touch /etc/postfix/transport && postmap /etc/postfix/transport;
test -f /etc/postfix/transport_custom || touch /etc/postfix/transport_custom && postmap /etc/postfix/transport_custom;
test -f /etc/postfix/virtual || touch /etc/postfix/virtual && postmap /etc/postfix/virtual;
test -f /etc/postfix/virtual_custom || touch /etc/postfix/virtual_custom && postmap /etc/postfix/virtual_custom;
test -f /var/www/expressions.cfg || touch /var/www/expressions.cfg;
test -d /etc/postfix/certs || mkdir /etc/postfix/certs;
test -d /etc/postfix/ldaps || mkdir /etc/postfix/ldaps;
test -d /etc/postfix/pwd || mkdir /etc/postfix/pwd;
test -f /etc/postfix/postscreen_access.cidr || touch /etc/postfix/postscreen_access.cidr;
test -f /etc/postfix/postscreen_access_custom.cidr || touch /etc/postfix/postscreen_access_custom.cidr;
test -f /etc/postfix/sender_bcc || touch /etc/postfix/sender_bcc && postmap /etc/postfix/sender_bcc;
test -f /etc/postfix/recipient_bcc || touch /etc/postfix/recipient_bcc && postmap /etc/postfix/recipient_bcc;
test -f /etc/postfix/sender_bcc_custom.pcre || touch /etc/postfix/sender_bcc_custom.pcre;
test -f /etc/postfix/recipient_bcc_custom.pcre || touch /etc/postfix/recipient_bcc_custom.pcre;
test -f /etc/postfix/header_custom || touch /etc/postfix/header_custom && postmap /etc/postfix/header_custom;
test -f /etc/postfix/body_custom || touch /etc/postfix/body_custom && postmap /etc/postfix/body_custom;
test -f /etc/postfix/header_smtp || echo '/^X-Spam-Status: \S.*\d+\stests=(.*)/ warn $1' > /etc/postfix/header_smtp;
test -d /etc/postfix/smtp_reply_filter || mkdir /etc/postfix/smtp_reply_filter;
test -f /etc/postfix/header_post_filter || touch /etc/postfix/header_post_filter;
test -f /etc/postfix/blocked_mx || touch /etc/postfix/blocked_mx && postmap /etc/postfix/blocked_mx
test -f /etc/postfix/blocked_ns || touch /etc/postfix/blocked_ns && postmap /etc/postfix/blocked_ns
test -f /etc/postfix/blocked_ns.pcre || touch /etc/postfix/blocked_ns.pcre
test -f /etc/postfix/blocked_ns.cidr || touch /etc/postfix/blocked_ns.cidr
test -f /etc/postfix/client_ips_custom || touch /etc/postfix/client_ips_custom && postmap /etc/postfix/client_ips_custom
test -f /etc/postfix/client_ips_custom.cidr || touch /etc/postfix/client_ips_custom.cidr
test -f /etc/postfix/tls_policy_custom || touch /etc/postfix/tls_policy_custom && postmap /etc/postfix/tls_policy_custom;
test -f /etc/postfix/recipient_access_custom || touch /etc/postfix/recipient_access_custom && postmap /etc/postfix/recipient_access_custom;
test -f /etc/postfix/recipient_reject-only_custom || touch /etc/postfix/recipient_reject-only_custom && postmap /etc/postfix/recipient_reject-only_custom;
test -f /etc/postfix/sender_replace.pcre || touch /etc/postfix/sender_replace.pcre;
test -f /etc/postfix/recipient_replace.pcre || touch /etc/postfix/recipient_replace.pcre;
test -f /var/www/bin/policy.sh || chown nobody /var/www/bin/policy.sh;
test -f /var/spool/disclaimers || mkdir -p /var/spool/disclaimers;
test -f /var/spool/filter || mkdir -p /var/spool/filter;
test -f /var/log/mail.log.1 && ln -sf /var/log/mail.log.1 /var/www/mail.log.1
test -d /var/lib/amavis/tmp || mkdir -p /var/lib/amavis/tmp && chown amavis.amavis /var/lib/amavis/tmp;
test -d /usr/lib/postsrsd || mkdir -p /usr/lib/postsrsd;
rbldns_path=/var/www/rbldns
test -d $rbldns_path || mkdir -p $rbldns_path

[ ! `sysctl vm.overcommit_memory | cut -d "=" -f2` -eq 1 ] && sysctl -w vm.overcommit_memory=1

# Flush an old incompatible db structure
# [ "`redis-cli hget ScrolloutF1 version`" != "$(cat /var/www/version)" ] && redis-cli flushall && redis-cli hset ScrolloutF1 version $(cat /var/www/version);


uid=`echo $(cat /dev/urandom | LC_CTYPE=C tr -dc "a-zA-Z0-9" | head -c ${2:-7})`

chown nobody /var/spool/disclaimers
chown nobody /var/spool/filter
test -f /var/www/bin/sign.sh && chown nobody /var/www/bin/sign.sh
chown www-data /var/www
chown www-data.www-data /var/www/*.cfg
chown www-data.root /etc/amavis/sndr
chown amavis.amavis /var/www/bin/pyzor.sh
chown www-data.root /etc/spamassassin/20_wb.cf
test -d /etc/postfix/ldaps && chmod 755 /etc/postfix/ldaps > /dev/null 2>&1;
test -d /etc/postfix/ldaps && chmod 644 /etc/postfix/ldaps/* > /dev/null 2>&1;
test -d /etc/postfix/pwd && chmod 755 /etc/postfix/pwd > /dev/null 2>&1;
test -d /etc/postfix/pwd && chmod 644 /etc/postfix/pwd/* > /dev/null 2>&1;
test -f /etc/dovecot/users && chmod 644 /etc/dovecot/users > /dev/null 2>&1;

test -f /etc/apt/apt.conf.d/20auto-upgrades || cat << END > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";

END

tmp=/tmp/scrollout;
run=/var/run/scrollout;

test -d $tmp || mkdir $tmp;
test -d $run || mkdir $run;

www=/var/www;
cfg=/var/www/cfg;
geo=$cfg/geo;
alltlds=$geo/alltlds;
countries=$geo/countries;
countries_codes=$geo/countries_codes;
setup=$www/countries.cfg;
bin=$www/bin
reload=$bin/reload.sh;
updatetld=$bin/updatetld.sh;
runcountries=$bin/runcountries.sh;
run_dkim=$bin/dkim.sh;
run_rbl=$bin/rbldnsd.sh;
run_dns=$bin/dns.sh;
run_srs=$bin/srs.sh;
run_jitsi=$bin/jitsi-meet.sh;
net=$bin/net.sh;
range=$geo/range;
cidr=$geo/cidr;
clientcidr=/etc/postfix/client.cidr;
test -f /etc/postfix/client.cidr || touch /etc/postfix/client.cidr;
test -f /etc/postfix/esmtp_access || \
printf "0.0.0.0/0		   silent-discard, dsn\n\
::/0				silent-discard, dsn\n" > /etc/postfix/esmtp_access

release=`grep -m1 "^[0-9]\{4\}\-[0-9]\{1,2\}\-[0-9]\{1,2\}$" /var/www/ver`;
release2=`grep -m1 "^[0-9]\{4\}\-[0-9]\{1,2\}\-[0-9]\{1,2\}$" /var/www/version`;


# config files
connection=$www/connection.cfg;
test -f $connection || touch $connection;

security=$www/security.cfg;
test -f $security || touch $security;

collector=$www/collector.cfg;
test -f $collector || touch $collector;

traffic=$www/traffic.cfg;
test -f $traffic || touch $traffic;

return_codes=$www/codes.cfg;
test -f $return_codes || touch $return_codes;

ldp=$www/ldp.cfg;
test -f $ldp || touch $ldp;

chown www-data $www/*.cfg;

. $return_codes;
. $connection;
. $security;
. $collector;
. $traffic;
. $ldp;

[ -z "$IPSec_encryption" ] && IPSec_encryption=6;
[ -z "$Body_filter" ] && Body_filter=6;
[ -z "$Connection_filter" ] && Connection_filter=6;
[ -z "$Geographic_filter" ] && Geographic_filter=6;
[ -z "$Header_and_attachments_filter" ] && Header_and_attachments_filter=6;
[ -z "$Hostname_filter" ] && Hostname_filter=6;
[ -z "$Picture_filter" ] && Picture_filter=6;
[ -z "$Spam_trap_score" ] && Spam_trap_score=6;
[ -z "$Spamassassin" ] && Spamassassin=5;
[ -z "$URL_filter" ] && URL_filter=6;
[ -z "$Lite_DLP_score" ] && Lite_DLP_score=10;
[ -z "$Web_cache" ] && Web_cache=6;
[ -z "$Rate_limits_in" ] && Rate_limits_in=6;
[ -z "$Rate_limits_out" ] && Rate_limits_out=6;
[ -z "$Auto_defense" ] && Auto_defense=10;
[ -z "$IPSec_encryption" ] && IPSec_encryption=6;


if [ $Header_and_attachments_filter -le 3 ]
then
header_code="REJECT Attachment file type, Header or Subject not allowed.";
else
header_code=$mailbox;
fi

body_code=$mailbox;
report_spam=$mailbox;
report_virus=$mailbox;

sed -i "s/.*short_open_tag .*/short_open_tag = On/" /etc/php5/fpm/php.ini
sed -i "s/.*max_input_vars .*/max_input_vars = 25000/" /etc/php5/fpm/php.ini
sed -i "s/.*max_execution_time .*/max_execution_time = 300/" /etc/php5/fpm/php.ini
sed -i "s/.*memory_limit .*/memory_limit = 128M/" /etc/php5/fpm/php.ini
sed -i "s/.*suhosin.post.max_vars .*/suhosin.post.max_vars = 25000/" /etc/php5/fpm/php.ini
sed -i "s/.*suhosin.request.max_vars .*/suhosin.request.max_vars = 25000/" /etc/php5/fpm/php.ini

mynetworks=`echo "${transport[*]}" | sed "s/  *$//g" |  sed "s/\:[0-9]*//g" | sed -e "s/\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)\] \{0,1\}/\1\/32 /g" | sed -e "s/\[//g" | sed -e "s/ $//g" | sed 's/  \|,/ /g' | tr ' ' '\n' | grep -vi "[a-z]" | sort -u | tr '\n' ' '`

left=`echo "${spamtraps[*]}"  | sed "s/  *$//g" | sed "s/ /|/g"`;
right_c=`echo "${domain[*]}" | sed "s/  *$//g" | sed -e 's/\([[:punct:]]\)/\\\\\\\\\1/g' | sed "s/ /|/g"`;
mailbox_reg=`echo "$mailbox" | sed -e 's/\([[:punct:]]\)/\\\\\\\\\1/g'`
report_spam_reg=`echo "$report_spam" | sed -e 's/\([[:punct:]]\)/\\\\\\\\\1/g'`
report_virus_reg=`echo "$report_virus" | sed -e 's/\([[:punct:]]\)/\\\\\\\\\1/g'`

domain_reg=(`echo "${domain[*]}" | sed "s/  *$//g" | sed -e 's/\([[:punct:]]\)/\\\\\\\\\1/g'`)
transport_reg=(`echo "${transport[*]}" | sed "s/  *$//g" | sed -e 's/\([[:punct:]]\)/\\\\\\\\\1/g'`)
sptr=(`echo $spamtraps`);
template=$cfg/agresivity


sp_library=/etc/mail/spamassassin;
tldtemplate=`cat $geo/tldtemplate`;
localcf=$template/$Spamassassin/local.cf;
tld_scores=$template/$Geographic_filter/tld_scores;
tldscore=/tmp/tldscore;

satrap=$(
for ((i=0; i<${#domain[$i]}; i++)); do
[ ! -z "${spamtraps[$i]}" ] && sptr=(`echo ${spamtraps[$i]} | tr "," " "`);

        for ((s=0; s<${#sptr[*]}; s++)); do
                [ ! -z "${sptr[$s]}" -a "${spamtraps[$i]}" ] && printf "${sptr[$s]}@${domain[$i]}\n"
        done
done
)

bucket=$(printf "$satrap\n$mailbox\n" | sed "s/\([[:punct:]]\)/\\\\\\\\\1/g" | sort -u | tr '\n' '|' | sed "s/|$//");
[ ! -z "$satrap" ] && strap=$(cat $template/$Spam_trap_score/strap | sed "s/xMAILBOXx/$bucket/g");

. $tld_scores;

		if [ $Connection_filter -le 2 ]
		then
		printf "\n### blacklist_from hosted domains ###\n" >> $tmp/st.tmp
		lend=${#domain[*]}
		d=0;
		while [ $d -lt $lend ];
		do
		printf "blacklist_from\t*@${domain[$d]}\n"
		let d++
		done | sort -u >> $tmp/st.tmp
		fi

if ! [[ -z "${spamtraps[*]}" ]]
then
printf "\n### learn from spam traps\n" >> $tmp/st.tmp
printf "\n$strap\n" >> $tmp/st.tmp
# printf "### blacklist_to spam traps ###\n" >> $tmp/st.tmp
# echo "$satrap" | parallel --gnu 'printf "blacklist_to\t{}\n"' | sort -u >> $tmp/st.tmp
else
	printf "### No spam traps defined ###\n" >> $tmp/st.tmp;
fi

mv $tmp/st.tmp $sp_library/10_traps.cf;
rm -f $tmp/st.tmp;



# postfix, postgrey, clamav, sa, amavis etc.
blocked_ips=$cfg/blocked_ips;
test -f $blocked_ips || touch $blocked_ips;
test -f /etc/postfix/blocked_ips.hash.db || postmap /etc/postfix/blocked_ips
test -f /etc/postfix/blocked_ips.db && mv /etc/postfix/blocked_ips.db /etc/postfix/blocked_ips.hash.db


allowed_ips=$cfg/allowed_ips;
test -f $allowed_ips || touch $allowed_ips;
test -f /etc/postfix/allowed_ips.hash.db || postmap /etc/postfix/allowed_ips
test -f /etc/postfix/allowed_ips.db && mv /etc/postfix/allowed_ips.db /etc/postfix/allowed_ips.hash.db

client=$cfg/client;
test -f $client || touch $client;

sender=$cfg/sender;
test -f $sender || touch $sender;

recipients=$cfg/recipients;
test -f $recipients || touch $recipients;

cidr_client=$cfg/client.cidr;
test -f $cidr_client || touch $cidr_client;

dottlds=$cfg/dottlds;
test -f $dottlds || touch $dottlds;

header=$cfg/header;
test -f $header || touch $header;

body=$cfg/body;
test -f $body || touch $body;

dottld=$www/postfix/dottld;
test -f $dottld || touch $dottld;

virtual=$cfg/virtual;
test -f $virtual || touch $virtual;

reley_rec=$cfg/relay_recipients;
test -f $reley_rec || touch $reley_rec;

# transport=$cfg/transport;
main=$cfg/main.cf;
master=$cfg/master.cf;
mailname=/etc/mailname;


# networking
host=/etc/hostname;
hosts=/etc/hosts;
lan=/etc/network/interfaces;
dns=/etc/resolv.conf;

# services
postfix=/etc/init.d/postfix;
$postfix status | grep "not running" && $postfix start;

amavis=/etc/init.d/amavis;
$amavis status | grep "not running" && $amavis start;

clamav=/etc/init.d/clamav-daemon;
$clamav status | grep "not running" && $clamav start;

#postgrey=/etc/init.d/postgrey;
#$postgrey status | grep "not running" && $postgrey start;
sa=/etc/init.d/spamassassin;
networking=/etc/init.d/networking;
reload=$bin/reload.sh;
# others
param_sa=`echo -e "\ndns_available yes\nall_spam_to $report_spam\n"`

cat $template/$Hostname_filter/host.cf | sed "s/xDOMAINx/$right_c/" > /etc/mail/spamassassin/host.cf


test -z $hostname && hostname=`hostname | head -1`;
tnets=(`echo "${mynets[*]}" | sed 's/  \|,/ /g' | tr ' ' '\n' | sort -ur | tr '\n' ' '`);
mynets=(`echo "${mynets[*]}" | sed 's/\( *\|^\)\(!?192\|!?10\|!?172\)\.[0-9]*\.[0-9]*\.[0-9]*\/[0-9]*\( \|$\)/ /g' | sed 's/  \|,/ /g' | tr ' ' '\n' | sort -ur | tr '\n' ' '`);

if [[ `grep "Ubuntu " /etc/issue` ]];
then
chmod 644 /var/log/mail.log
chown syslog.adm /var/log/mail.log
else
chmod 644 /var/log/mail.log
chown www-data.adm /var/log/mail.log
fi
