#!/bin/bash
list=(bl wl reputation);
type=(ns domain ip ip6);
reputation=(0 10 20 30 40 50 60 70 80 90 100);
lurl="scrolloutf1.local"
purl="rbl.scrolloutf1.com"
rbldns_path=/var/www/rbldns
sa_path=/etc/spamassassin
sa_report=/var/www/cfg
test -d $rbldns_path || mkdir -p $rbldns_path

case $1 in
create)
test -f $sa_path/04_scrolloutf1_dkim.cf && rm $sa_path/04_scrolloutf1_dkim.cf
test -f $sa_path/05_scrolloutf1_rbl.cf && rm $sa_path/05_scrolloutf1_rbl.cf
test -f $sa_path/06_scrolloutf1_uribl.cf && rm $sa_path/06_scrolloutf1_uribl.cf
test -f $sa_report/report_ham.cf && rm $sa_report/report_ham.cf
test -f $sa_report/report_spam.cf && rm $sa_report/report_spam.cf
for ((l=0;$l<${#list[*]};l++)); do
	for ((t=0;$t<${#type[*]};t++)); do
	    for ((r=0;$r<${#reputation[*]};r++)); do

		file_name=`echo "${list[$l]}-${type[$t]}-${reputation[$r]}"`

		if [ "${type[$t]}" == "ns" ]; then
		    dataset="dnset"
		    exclusion=`cat <<END
# Exclusions:
!127.0.0.1
!1.0.0.127
!localhost
!.localdomain
!.local
!.168.192.in-addr.arpa
!.127.in-addr.arpa
!.10.in-addr.arpa
!.16.172.in-addr.arpa
!.254.169.in-addr.arpa
test	TESTENTRY for Name Servers
# Examples:
# ns1.example.com
# ns2.example.com
# .example.com
# *.example.com
# ADD YOUR ENTRIES BELOW:
END
`
			uri_local="SO_LOCAL_URIBL_NS"
			uri_public="SO_PUB_URIBL_NS"
			uri_type="urifullnsrhssub"
			uri_eval="check_uridnsbl"
			uri_flag="ns"
			
			[[ ${reputation[$r]} -le 50 ]] && uri_flag="ns"
			[[ ${reputation[$r]} -le 20 ]] && uri_flag="ns autolearn_force"
			[[ ${reputation[$r]} -gt 50 ]] && uri_flag="ns nice"
			[[ ${reputation[$r]} -ge 80 ]] && uri_flag="ns nice autolearn_force"

			sndr_local=""
			sndr_public=""
			sndr_type=""
			sndr_eval=""
			sndr_flag=""
			
		elif [ "${type[$t]}" == "domain" ]; then
		    dataset="dnset"
		    exclusion=`cat <<END
# Exclusions:
!127.0.0.1
!1.0.0.127
!localhost
!.localdomain
!.local
!.168.192.in-addr.arpa
!.127.in-addr.arpa
!.10.in-addr.arpa
!.16.172.in-addr.arpa
!.254.169.in-addr.arpa
test	TESTENTRY for Domain Names
# Examples:
# example.com
# www.example.com
# .example.com
# *.example.com
# ADD YOUR ENTRIES BELOW:
END
`
		    uri_local="SO_LOCAL_URIBL_DOMAIN"
			uri_public="SO_PUB_URIBL_DOMAIN"
			uri_type="urirhssub"
			uri_eval="check_uridnsbl"
			uri_flag="domains_only"
			
			sndr_local="SO_LOCAL_SNDR_DOMAIN"
			sndr_public="SO_PUB_SNDR_DOMAIN"
			sndr_type="header"
			sndr_eval="check_rbl_sub"
			[[ ${reputation[$r]} -le 50 ]] && sndr_flag=""
			[[ ${reputation[$r]} -le 20 ]] && sndr_flag="autolearn_force"
			[[ ${reputation[$r]} -gt 50 ]] && sndr_flag="nice"
			[[ ${reputation[$r]} -ge 80 ]] && sndr_flag="nice autolearn_force"
			
		elif [ "${type[$t]}" == "ip" ]; then
		    dataset="ip4set"
		    exclusion=`cat <<END
# Exclusions:
!127.0.0.1
!10.0.0.0-10.255.255.255
!172.16.0.0-172.31.255.255
!192.168.0.0-192.168.255.255
!169.254.0.0-169.254.255.255
# Examples:
# 192.168.99.1
# 192.168.99.0-192.168.99.255
# 192.168.99.0/24
# ADD YOUR ENTRIES BELOW:
END
`
		    uri_local="SO_LOCAL_URIBL_IP"
			uri_public="SO_PUB_URIBL_IP"
			uri_type="uridnssub"
			uri_eval="check_uridnsbl"
			uri_flag="a"
			
			sndr_local="SO_LOCAL_SNDR_IP"
			sndr_public="SO_PUB_SNDR_IP"
			sndr_type="header"
			sndr_eval="check_rbl_sub"
			[[ ${reputation[$r]} -le 50 ]] && sndr_flag="a" && tail="lastexternal"
			[[ ${reputation[$r]} -le 20 ]] && sndr_flag="a autolearn_force"
			[[ ${reputation[$r]} -gt 50 ]] && sndr_flag="a nice" && tail="firsttrusted"
			[[ ${reputation[$r]} -ge 80 ]] && sndr_flag="a nice autolearn_force"
			
		elif [ "${type[$t]}" == "ip6" ]; then
		    dataset="ip6trie"
			uri_local="SO_LOCAL_URIBL_IP6"
			uri_public="SO_PUB_URIBL_IP6"
			sndr_local="SO_LOCAL_SNDR_IP6"
			sndr_public="SO_PUB_SNDR_IP6"
		    exclusion=`cat <<END
# Exclusions:
!::1
!fc00::/7
# Examples (from man page):
# A listing, note that trailing :0s can be omitted
# 2001:21ab:c000/36

# /64 range with non-default A and TXT values
# 2001:21ab:def7:4242 :127.0.1.3: This one smells funny

# compressed notation
# 2605:6001:42::/52
# ::1                   # localhost
# !2605:6001:42::bead   # exclusion

# ADD YOUR ENTRIES BELOW:
END
`
		fi

	    if [ "${list[$l]}" == "reputation" ]; then
		if [ "${reputation[$r]}" == "0" ]; then
		    file_header=`cat <<END
\\$DATASET $dataset @ bl-${type[$t]} ${list[$l]}-${type[$t]} ${list[$l]}-${type[$t]}-${reputation[$r]}
\\$TTL 30
\\$1 www.$lurl
\\$2 bl-${type[$t]}.$lurl
\\$3 The ${type[$t]} address
\\$4 Reputation: ${reputation[$r]}.
:127.$t.${reputation[$r]}.2:\\$3 \\$ is listed in \\$2. \\$4 More details: http://\\$2/${list[$l]}-${type[$t]}=\\$
# 127.$t.${reputation[$r]}.2 Return code for ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
# 2.${reputation[$r]}.$t.127 Return code for ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
$exclusion
END`

		    uri_rule=; uri_rule=`cat <<END
			
$uri_type	${uri_local}_BL		${list[$l]}-${type[$t]}.$lurl A 127.$t.${reputation[$r]}.2
body		${uri_local}_BL		eval:$uri_eval('${uri_local}_BL')
describe	${uri_local}_BL		URL's ${type[$t]} address is listed in bl-${type[$t]}.$lurl
tflags		${uri_local}_BL		net $uri_flag
score		${uri_local}_BL		0 $((5-$r)).001 0 $((5-$r)).001

$uri_type	${uri_public}_BL	${list[$l]}-${type[$t]}.$purl A 127.$t.${reputation[$r]}.2
body		${uri_public}_BL	eval:$uri_eval('${uri_public}_BL')
describe	${uri_public}_BL	URL's ${type[$t]} address is listed in bl-${type[$t]}.$purl
tflags		${uri_public}_BL	net $uri_flag
score		${uri_public}_BL	0 $((5-$r)).001 0 $((5-$r)).001

END`
		    sndr_rule=; dkim_rule=;
			if [ "${type[$t]}" != "ns" -a "${type[$t]}" != "domain" -a "${type[$t]}" != "ip6" ]; then
			sndr_rule=`cat <<END

header		__${sndr_local}_BAD		eval:check_rbl('sof1-${list[$l]}-${type[$t]}-local-lastexternal', '${list[$l]}-${type[$t]}.$lurl')
header		__${sndr_local}_GOOD	eval:check_rbl('sof1-${list[$l]}-${type[$t]}-local-firsttrusted', '${list[$l]}-${type[$t]}.$lurl')

header		${sndr_local}_BL	eval:check_rbl_sub('sof1-${list[$l]}-${type[$t]}-local-$tail', '^127\\.[23]\\.${reputation[$r]}\\.2\$')
describe	${sndr_local}_BL	Sender's ${type[$t]} address is listed in bl-${type[$t]}.$lurl
score		${sndr_local}_BL	0 $((5-$r)).001 0 $((5-$r)).001
tflags		${sndr_local}_BL	net $sndr_flag
reuse		${sndr_local}_BL

header		__${sndr_public}_BAD	eval:check_rbl('sof1-${list[$l]}-${type[$t]}-public-lastexternal', '${list[$l]}-${type[$t]}.$purl')
header		__${sndr_public}_GOOD	eval:check_rbl('sof1-${list[$l]}-${type[$t]}-public-firsttrusted', '${list[$l]}-${type[$t]}.$purl')

header		${sndr_public}_BL	eval:check_rbl_sub('sof1-${list[$l]}-${type[$t]}-public-$tail', '^127\\.[23]\\.${reputation[$r]}\\.2\$')
describe	${sndr_public}_BL	Sender's ${type[$t]} address is listed in bl-${type[$t]}.$purl
score		${sndr_public}_BL	0 $((5-$r)).001 0 $((5-$r)).001
tflags		${sndr_public}_BL	net $sndr_flag
reuse		${sndr_public}_BL

END`
			elif [ "${type[$t]}" == "domain" ]; then
			dkim_rule=`cat <<END

ifplugin Mail::SpamAssassin::Plugin::AskDNS
	
askdns		${sndr_local}_DKIM_BL		_DKIMDOMAIN_.${list[$l]}-${type[$t]}.$lurl A 127.$t.${reputation[$r]}.2
describe	${sndr_local}_DKIM_BL		Sender's ${type[$t]} DKIM is listed in bl-${type[$t]}.$lurl
tflags		${sndr_local}_DKIM_BL		net $sndr_flag
score		${sndr_local}_DKIM_BL		0 $((5-$r)).001 0 $((5-$r)).001

askdns		${sndr_public}_DKIM_BL		_DKIMDOMAIN_.UnsafeSenders.$purl A 127.$t.${reputation[$r]}.2
describe	${sndr_public}_DKIM_BL		Sender's ${type[$t]} DKIM is listed in UnsafeSenders.$purl
tflags		${sndr_public}_DKIM_BL		net $sndr_flag
score		${sndr_public}_DKIM_BL		0 $((5-$r)).001 0 $((5-$r)).001

END`
			fi

		elif [ "${reputation[$r]}" == "100" ]; then
		    file_header=`cat <<END
\\$DATASET $dataset @ wl-${type[$t]} ${list[$l]}-${type[$t]} ${list[$l]}-${type[$t]}-${reputation[$r]}
\\$TTL 30
\\$1 www.$lurl
\\$2 wl-${type[$t]}.$lurl
\\$3 The ${type[$t]} address
\\$4 Reputation: ${reputation[$r]}.
:127.$t.${reputation[$r]}.2:\\$3 \\$ is listed in \\$2. \\$4 More details: http://\\$2/${list[$l]}-${type[$t]}=\\$
# 127.$t.${reputation[$r]}.2 Return code for ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
# 2.${reputation[$r]}.$t.127 Return code for ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
END`
		    uri_rule=;

		    sndr_rule=; dkim_rule=;
			if [ "${type[$t]}" != "ns" -a "${type[$t]}" != "domain" -a "${type[$t]}" != "ip6" ]; then
			sndr_rule=`cat <<END

header		${sndr_local}_WL	eval:check_rbl_sub('sof1-${list[$l]}-${type[$t]}-local-$tail', '^127\\.[23]\\.${reputation[$r]}\\.2\$')
describe	${sndr_local}_WL	Sender's ${type[$t]} address is listed in wl-${type[$t]}.$lurl
score		${sndr_local}_WL	0 $((5-$r)).001 0 $((5-$r)).001
tflags		${sndr_local}_WL	net $sndr_flag
reuse		${sndr_local}_WL

header		${sndr_public}_WL	eval:check_rbl_sub('sof1-${list[$l]}-${type[$t]}-public-$tail', '^127\\.[23]\\.${reputation[$r]}\\.2\$')
describe	${sndr_public}_WL	Sender's ${type[$t]} address is listed in wl-${type[$t]}.$purl
score		${sndr_public}_WL	0 $((5-$r)).001 0 $((5-$r)).001
tflags		${sndr_public}_WL	net $sndr_flag
reuse		${sndr_public}_WL

END`
			elif [ "${type[$t]}" == "domain" ]; then
			dkim_rule=`cat <<END
			
askdns		${sndr_local}_DKIM_WL		_DKIMDOMAIN_.${list[$l]}-${type[$t]}.$lurl A 127.$t.${reputation[$r]}.2
describe	${sndr_local}_DKIM_WL		Sender's ${type[$t]} DKIM is listed in wl-${type[$t]}.$lurl
tflags		${sndr_local}_DKIM_WL		net $sndr_flag
score		${sndr_local}_DKIM_WL		0 $((5-$r)).001 0 $((5-$r)).001

askdns		${sndr_public}_DKIM_WL		_DKIMDOMAIN_.SafeSenders.$purl A 127.$t.${reputation[$r]}.2
describe	${sndr_public}_DKIM_WL		Sender's ${type[$t]} DKIM is listed in SafeSenders.$purl
tflags		${sndr_public}_DKIM_WL		net $sndr_flag
score		${sndr_public}_DKIM_WL		0 $((5-$r)).001 0 $((5-$r)).001

endif

END`
			fi

		else
		    file_header=`cat <<END
\\$DATASET $dataset @ ${list[$l]}-${type[$t]} ${list[$l]}-${type[$t]}-${reputation[$r]}
\\$TTL 30
\\$1 www.$lurl
\\$2 ${list[$l]}-${type[$t]}.$lurl
\\$3 The ${type[$t]} address
\\$4 Reputation: ${reputation[$r]}.
:127.$t.${reputation[$r]}.2:\\$3 \\$ is listed in \\$2. \\$4 More details: http://\\$2/${list[$l]}-${type[$t]}=\\$
# 127.$t.${reputation[$r]}.2 Return code for ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
# 2.${reputation[$r]}.$t.127 Return code for ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
$exclusion
END`
		    uri_rule=; [ ${reputation[$r]} -le 50 ] && uri_rule=`cat <<END

$uri_type	${uri_local}_${reputation[$r]}		${list[$l]}-${type[$t]}.$lurl A 127.$t.${reputation[$r]}.2
body		${uri_local}_${reputation[$r]}		eval:$uri_eval('${uri_local}_${reputation[$r]}')
describe	${uri_local}_${reputation[$r]}		URL's ${type[$t]} address is listed in ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
tflags		${uri_local}_${reputation[$r]}		net $uri_flag
score		${uri_local}_${reputation[$r]}		0 $((5-$r)).001 0 $((5-$r)).001

$uri_type	${uri_public}_${reputation[$r]}		${list[$l]}-${type[$t]}.$purl A 127.$t.${reputation[$r]}.2
body		${uri_public}_${reputation[$r]}		eval:$uri_eval('${uri_public}_${reputation[$r]}')
describe	${uri_public}_${reputation[$r]}		URL's ${type[$t]} address is listed in ${list[$l]}-${type[$t]}-${reputation[$r]}.$purl
tflags		${uri_public}_${reputation[$r]}		net $uri_flag
score		${uri_public}_${reputation[$r]}		0 $((5-$r)).001 0 $((5-$r)).001

END`
		    sndr_rule=; dkim_rule=;
			if [ "${type[$t]}" != "ns" -a "${type[$t]}" != "domain" -a "${type[$t]}" != "ip6" ]; then
			sndr_rule=`cat <<END

header		${sndr_local}_${reputation[$r]}	eval:check_rbl_sub('sof1-${list[$l]}-${type[$t]}-local-$tail', '^127\\.[23]\\.${reputation[$r]}\\.2\$')
describe	${sndr_local}_${reputation[$r]}	Sender's ${type[$t]} address is listed in ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
score		${sndr_local}_${reputation[$r]}	0 $((5-$r)).001 0 $((5-$r)).001
tflags		${sndr_local}_${reputation[$r]}	net $sndr_flag
reuse		${sndr_local}_${reputation[$r]}

header		${sndr_public}_${reputation[$r]}	eval:check_rbl_sub('sof1-${list[$l]}-${type[$t]}-public-$tail', '^127\\.[23]\\.${reputation[$r]}\\.2\$')
describe	${sndr_public}_${reputation[$r]}	Sender's ${type[$t]} address is listed in ${list[$l]}-${type[$t]}-${reputation[$r]}.$purl
score		${sndr_public}_${reputation[$r]}	0 $((5-$r)).001 0 $((5-$r)).001
tflags		${sndr_public}_${reputation[$r]}	net $sndr_flag
reuse		${sndr_public}_${reputation[$r]}

END`
			elif [ "${type[$t]}" == "domain" ]; then
			dkim_rule=`cat <<END
			
askdns		${sndr_local}_DKIM_${reputation[$r]}		_DKIMDOMAIN_.${list[$l]}-${type[$t]}.$lurl A 127.$t.${reputation[$r]}.2
describe	${sndr_local}_DKIM_${reputation[$r]}		Sender's ${type[$t]} DKIM is listed in ${list[$l]}-${type[$t]}-${reputation[$r]}.$lurl
tflags		${sndr_local}_DKIM_${reputation[$r]}		net $sndr_flag
score		${sndr_local}_DKIM_${reputation[$r]}		0 $((5-$r)).001 0 $((5-$r)).001

askdns		${sndr_public}_DKIM_${reputation[$r]}		_DKIMDOMAIN_.${list[$l]}-Sender.$purl A 127.$t.${reputation[$r]}.2
describe	${sndr_public}_DKIM_${reputation[$r]}		Sender's ${type[$t]} DKIM is listed in ${list[$l]}-Sender-${reputation[$r]}.$purl
tflags		${sndr_public}_DKIM_${reputation[$r]}		net $sndr_flag
score		${sndr_public}_DKIM_${reputation[$r]}		0 $((5-$r)).001 0 $((5-$r)).001

END`
			fi

		fi
		test -f $rbldns_path/$file_name || echo "$file_header" > $rbldns_path/$file_name
		[ ! -z "$uri_rule" ] && echo "$uri_rule" >> $sa_path/06_scrolloutf1_uribl.cf
		[ ! -z "$sndr_rule" ] && echo "$sndr_rule" >> $sa_path/05_scrolloutf1_rbl.cf
		[ ! -z "$dkim_rule" ] && echo "$dkim_rule" >> $sa_path/04_scrolloutf1_dkim.cf
	    fi
	    done
	done
done

cat <<END > $rbldns_path/generic
\$SOA 86400 ns1.scrolloutf1.local abuse.scrolloutf1.local 0 3600 600 2419200 30
\$NS 3600 ns1.scrolloutf1.local

\$DATASET generic @
@ A 127.0.0.1
NS1 A 127.0.0.1
www A 127.0.0.1
mx1 A 127.0.0.1
@ MX 10 mx1.scrolloutf1.local
@ TXT v=spf1 a mx -all

END

chown -R rbldns $rbldns_path
awk '{ exit $3 >= 8 ? 0 : 1 }' /etc/issue;
if [ $? -eq 0 ]; then

cat <<END > /etc/default/rbldnsd
RBLDNSD="localhost -u rbldns -c 1m -f -a -e -v -r /var/www/rbldns -w / \\
-b 127.0.0.1/5353 \\
-b ::1/5353 \\
scrolloutf1.local:combined:generic \\
scrolloutf1.local:combined:reputation-ip-0,reputation-ip-10,reputation-ip-20,reputation-ip-30,reputation-ip-40,reputation-ip-50,reputation-ip-60,reputation-ip-70,reputation-ip-80,reputation-ip-90,reputation-ip-100 \\
scrolloutf1.local:combined:reputation-ip6-0,reputation-ip6-10,reputation-ip6-20,reputation-ip6-30,reputation-ip6-40,reputation-ip6-50,reputation-ip6-60,reputation-ip6-70,reputation-ip6-80,reputation-ip6-90,reputation-ip6-100 \\
scrolloutf1.local:combined:reputation-domain-0,reputation-domain-10,reputation-domain-20,reputation-domain-30,reputation-domain-40,reputation-domain-50,reputation-domain-60,reputation-domain-70,reputation-domain-80,reputation-domain-90,reputation-domain-100 \\
scrolloutf1.local:combined:reputation-ns-0,reputation-ns-10,reputation-ns-20,reputation-ns-30,reputation-ns-40,reputation-ns-50,reputation-ns-60,reputation-ns-70,reputation-ns-80,reputation-ns-90,reputation-ns-100"

END

else

cat <<END > /etc/default/rbldnsd
RBLDNSD="localhost -u rbldns -c 1m -f -a -e -v -r /var/www/rbldns -w / \\
-b 127.0.0.1/5353 \\
-b ::1/5353 \\
scrolloutf1.local:combined:generic \\
scrolloutf1.local:combined:reputation-ip-0,reputation-ip-10,reputation-ip-20,reputation-ip-30,reputation-ip-40,reputation-ip-50,reputation-ip-60,reputation-ip-70,reputation-ip-80,reputation-ip-90,reputation-ip-100 \\
scrolloutf1.local:combined:reputation-domain-0,reputation-domain-10,reputation-domain-20,reputation-domain-30,reputation-domain-40,reputation-domain-50,reputation-domain-60,reputation-domain-70,reputation-domain-80,reputation-domain-90,reputation-domain-100 \\
scrolloutf1.local:combined:reputation-ns-0,reputation-ns-10,reputation-ns-20,reputation-ns-30,reputation-ns-40,reputation-ns-50,reputation-ns-60,reputation-ns-70,reputation-ns-80,reputation-ns-90,reputation-ns-100"

END

fi

;;
esac
