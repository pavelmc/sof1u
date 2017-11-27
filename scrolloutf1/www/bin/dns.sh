#!/bin/bash

. /var/www/connection.cfg

case $1 in
pools )
eth=`ip link show | awk -F ": " '/^[0-9]*: .*: <BROADCAST,MULTICAST/ {print $2;exit;}'`;
forwaders=`echo "${dns1[*]}" | sed "s/127\.0\.0\.1.\|::1.//g" | sed "s/ /; /g"`
. /var/www/traffic.cfg

cat <<END > /etc/bind/named.conf.options

acl "trusted" {
	localhost;
	127.0.0.1;
	::1;
	10.0.0.0/8;
	192.168.0.0/16;
	172.16.0.0/12;
};

options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        //dnssec-validation auto;
		
			min-cache-ttl 300;
			min-ncache-ttl 60;
			max-cache-ttl 3600;
			max-ncache-ttl 300;


        auth-nxdomain no;    # conform to RFC1035
       // listen-on-v6 { any; };

    listen-on port 53 { any; };
    listen-on-v6 port 53 { any; };
        // forwarders { $forwaders; };
        allow-query     { trusted; };
        allow-query-cache { trusted; };
        allow-recursion { trusted; };
        allow-recursion-on { trusted; };
        recursion yes;
        version "[unknown]";

    dnssec-enable yes;
    dnssec-validation no;
    dnssec-lookaside auto;
	
};

include "/etc/bind/named.conf.scrolloutf1.local";

END

cat <<END > /etc/bind/ip.pools
\$ORIGIN ip.pools.
\$TTL    3600
@       IN      SOA     ip.pools. root.ip.pools. (
								2			; Serial
								3600		; Refresh
								600			; Retry
								2419200		; Expire
								30 )		; Negative Cache TTL
;
@       IN      NS      ip.pools.
@       IN      A       127.0.0.1
@       IN      AAAA    ::1

END


cat <<END > /etc/bind/named.conf.scrolloutf1.local

zone "scrolloutf1.local" {
   type forward;
   forward only;
   forwarders {127.0.0.1 port 5353; ::1 port 5353;};
};

zone "ip.pools" {
        type master;
        file "/etc/bind/ip.pools";
};

END

default_destination_recipient_limit=60;
for ((d=0;d<${#domain[*]};d++));do

    [[ ${assips[$d]} != "" ]] && pool=(`echo ${assips[$d]} | sed "s/,/ /g"`)

## if #1
    if [[ ${assips[$d]} != "" ]]; then
	    for ((p=0;p<${#pool[$a]};p++)); do


	# if #2
	if [[ ${pool[$p]} != "" ]]; then
		    cat <<END >> /etc/bind/ip.pools
${domain[$d]}	60	IN	A	${pool[$p]}
END
rhelo=`host ${pool[$p]} 2> /dev/null | grep -m1 "arpa domain name pointer" | sed "s/^.*arpa domain name pointer \(.*\)\.$/\1/"`
trans[$p]="from_${domain[$d]}_${pool[$p]}"


	# if #3
        if [ "$rhelo" != "" ]; then
        cat <<END >> $tmp/master_pipe.tmp$uid
${trans[$p]}   unix -        -       -       -       $(($Rate_limits_out*5))         smtp
        -o smtp_bind_address=${pool[$p]}
        -o smtp_helo_name=$rhelo
        # -o syslog_name=${trans[$p]}
	-o smtp_initial_destination_concurrency=$((($Rate_limits_out+1)/2))
	-o smtp_destination_rate_delay=$((60/$default_destination_recipient_limit))s
	-o smtp_destination_recipient_limit=$(($Rate_limits_out*4))
	-o smtp_destination_concurrency_limit=$(($Rate_limits_out*2))
	-o smtp_destination_concurrency_failed_cohort_limit=$((($Rate_limits_out+1)/2))
	
END

        else # if #3
        cat <<END >> $tmp/master_pipe.tmp$uid

${trans[$p]}   unix -        -       -       -       $(($Rate_limits_out*5))         smtp
        -o smtp_bind_address=${pool[$p]}
        # -o smtp_helo_name=$rhelo
        # -o syslog_name=${trans[$p]}
	-o smtp_initial_destination_concurrency=$((($Rate_limits_out+1)/2))
	-o smtp_destination_rate_delay=$((60/$default_destination_recipient_limit))s
	-o smtp_destination_recipient_limit=$(($Rate_limits_out*4))
	-o smtp_destination_concurrency_limit=$(($Rate_limits_out*2))
	-o smtp_destination_concurrency_failed_cohort_limit=$((($Rate_limits_out+1)/2))

END


        fi
	# if #3
		allips=(`echo "${allips[*]} ${pool[$p]}"`)

	fi
	# if #2


	    done

	else

	assips_maps=`cat <<END
$assips_maps
@${domain[$d]}	from_${domain[$d]}:${hrelays[$d]}
END
`

	trans[$p]="from_${domain[$d]}"
        cat <<END >> $tmp/master_pipe.tmp$uid

${trans[$p]}   unix -        -       -       -       $(($Rate_limits_out*10))         smtp
        # -o syslog_name=${trans[$p]}
	-o smtp_initial_destination_concurrency=$((($Rate_limits_out+1)/2))
	-o smtp_destination_rate_delay=$((60/$default_destination_recipient_limit))s
	-o smtp_destination_recipient_limit=$(($Rate_limits_out*4))
	-o smtp_destination_concurrency_limit=$(($Rate_limits_out*2))
	-o smtp_destination_concurrency_failed_cohort_limit=$((($Rate_limits_out+1)/2))

END


	fi
	# if #1
	fallback[$d]=`echo "${transport[$d]}" | grep "," | cut -d "," -f2-`

        cat <<END >> $tmp/master_smtp.tmp$uid

to_${domain[$d]}   unix -        -       -       -       $(($Rate_limits_out*5))         smtp
	-o smtp_send_xforward_command=yes
	-o smtp_initial_destination_concurrency=$((($Rate_limits_out+3)/2))
	-o smtp_destination_rate_delay=0s
	-o smtp_destination_recipient_limit=$(($Rate_limits_out*10))
	-o smtp_destination_concurrency_limit=$(($Rate_limits_out*5))
	-o smtp_destination_concurrency_failed_cohort_limit=$(($Rate_limits_out*5))
	# -o smtp_address_verify_target=data # On Postfix >= 3.0
	# -o syslog_name=to_${domain[$d]}
	-o smtp_reply_filter=pcre:/etc/postfix/smtp_reply_filter/${domain[$d]}_reply_filter
	`[[ ! -z ${fallback[$d]} ]] && echo "-o smtp_fallback_relay=${fallback[$d]}"`
	`[[ ! -z ${encrypt[$d]} ]] && echo "-o smtp_tls_security_level=encrypt"`
	`[[ ! -z ${encrypt[$d]} ]] && echo "-o smtp_tls_mandatory_ciphers=medium"`
	`[[ ! -z ${pool[$p]} ]] && echo "-o smtp_bind_address=${pool[$p]}"`
	`[[ ! -z ${rhelo} ]] && echo "-o smtp_helo_name=${rhelo}"`

END

done

allips=(`echo "${allips[*]}" | tr " " "\n" | sort -u | tr "\n" " "`)

sed -i -e "/^down\|^up/d" /etc/network/interfaces

echo "down	ip addr flush $eth" >> /etc/network/interfaces
echo "down	ip -6 addr flush $eth" >> /etc/network/interfaces
for ((i=0;i<${#allips[*]};i++)); do
echo "down	ip addr del ${allips[$i]}/24 dev $eth" >> /etc/network/interfaces
echo "up	ip addr add ${allips[$i]}/24 dev $eth label $eth:$i" >> /etc/network/interfaces
if [ $i -eq 0 ]; then
	ip link set $eth up
	ip addr add ${allips[$i]}/24 dev $eth label $eth:$i
	else
	ip addr add ${allips[$i]}/24 dev $eth label $eth:$i
fi
done

echo "$assips_maps" | grep -v "^$" | sort -u +0 -0 > $tmp/assips_maps.tmp && mv $tmp/assips_maps.tmp $www/postfix/assips_maps

service bind9 reload > /dev/null 2>&1;
;;


* )
eth=`ip link show | awk -F ": " '/^[0-9]*: .*: <BROADCAST,MULTICAST/ {print $2}'`;

today=`date +%u`
currhour=`date +%H`

[[ -z $caching ]] && sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf && exit 0;

hour=(0 00 01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23);

case $today in
$monday )
# hour=(0 2 4 6 8 10 12 14 16 18 20 22);
hour=(0 00 01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
[[ " ${hour[*]} " = *" $currhour "* ]] && ( 
sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf; sed -i "1inameserver 127.0.0.1" /etc/resolv.conf; if [[ ! -z $ipv6 ]]; then sed -i "2inameserver ::1" /etc/resolv.conf; fi 
) || sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf;
;;
$tuesday )
# hour=(0 2 4 6 8 10 13 16 18 20 22);
hour=(0 00 01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
[[ " ${hour[*]} " = *" $currhour "* ]] && ( 
sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf; sed -i "1inameserver 127.0.0.1" /etc/resolv.conf; if [[ ! -z $ipv6 ]]; then sed -i "2inameserver ::1" /etc/resolv.conf; fi 
) || sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf;
;;
$wednesday )
# hour=(0 2 4 6 8 10 12 14 16 18 20 22);
hour=(0 00 01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
[[ " ${hour[*]} " = *" $currhour "* ]] && (
sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf; sed -i "1inameserver 127.0.0.1" /etc/resolv.conf; if [[ ! -z $ipv6 ]]; then sed -i "2inameserver ::1" /etc/resolv.conf; fi 
) || sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf;
;;
$thursday )
# hour=(0 2 4 6 8 10 13 16 18 20 22);
hour=(0 00 01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
[[ " ${hour[*]} " = *" $currhour "* ]] && (
sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf; sed -i "1inameserver 127.0.0.1" /etc/resolv.conf; if [[ ! -z $ipv6 ]]; then sed -i "2inameserver ::1" /etc/resolv.conf; fi 
) || sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf;
;;
$friday )
# hour=(0 2 4 6 8 10 13 16 18 20 22);
hour=(0 00 01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
[[ " ${hour[*]} " = *" $currhour "* ]] && (
sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf; sed -i "1inameserver 127.0.0.1" /etc/resolv.conf; if [[ ! -z $ipv6 ]]; then sed -i "2inameserver ::1" /etc/resolv.conf; fi 
) || sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf;
;;
$saturday ) 
# hour=(0 3 6 9 12 15 18 21);
hour=(0 00 01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
[[ " ${hour[*]} " = *" $currhour "* ]] && (
sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf; sed -i "1inameserver 127.0.0.1" /etc/resolv.conf; if [[ ! -z $ipv6 ]]; then sed -i "2inameserver ::1" /etc/resolv.conf; fi 
) || sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf;
;;
$sunday ) 
# hour=(0 3 6 9 12 15 18 21);
hour=(0 00 01 1 02 2 03 3 04 4 05 5 06 6 07 7 08 8 09 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
[[ " ${hour[*]} " = *" $currhour "* ]] && ( 
sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf; sed -i "1inameserver 127.0.0.1" /etc/resolv.conf; if [[ ! -z $ipv6 ]]; then sed -i "2inameserver ::1" /etc/resolv.conf; fi 
) || sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf;
;;
* ) sed -i "/127.0.0.1\|::1/d" /etc/resolv.conf;;
esac
;;
esac

