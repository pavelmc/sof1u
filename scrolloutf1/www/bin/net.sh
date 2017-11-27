#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################


. /var/www/bin/config.sh
. /var/www/traffic.cfg

sysctl -w net.ipv4.tcp_tw_recycle=1 > /dev/null 2>&1
sysctl -w net.ipv4.tcp_tw_reuse=1 > /dev/null 2>&1
sysctl -w net.ipv4.tcp_fin_timeout=30 > /dev/null 2>&1

eth=`ifconfig -a | grep -v "^dummy[0-9]" | grep -m1 "^[a-z]*[0-9]* *Link encap" | awk -F " " '{print $1}'`;

hostname $hostname;

lockfile-create $tmp/hostname
echo "$hostname" > $tmp/hostname.tmp && mv $tmp/hostname.tmp /etc/hostname;

lockfile-remove $tmp/hostname


lockfile-create $tmp/hosts
if ! [ "$dnssuffix" = "$empty" ]
then
cat $cfg/hosts | sed "s/xFQDNx/$hostname.$dnssuffix/g" | sed "s/xHOSTNAMEx/$hostname/g" > $tmp/hosts.tmp && mv $tmp/hosts.tmp $hosts
else
cat $cfg/hosts | sed "s/xFQDNx/$hostname.$domain/g" | sed "s/xHOSTNAMEx/$hostname/g" > $tmp/hosts.tmp && mv $tmp/hosts.tmp $hosts
fi
lockfile-remove $tmp/hosts


lockfile-create $tmp/lan
lockfile-create $tmp/dns


if [ "$network" = 1 ];
then
kill -9 `ps -A | awk '/dhclient/ {print $1}'` > /dev/null 2>&1
dnsv4="`echo "${dns1[*]}" | sed -e "s/[0-9a-z]*:\{1,\}[0-9a-z]*//g" -e "s/  */ /g"`"
dnsv6="`echo "${dns1[*]}" | sed -e "s/[0-9]*\.[0-9]*//g" -e "s/  \|^ //g"`"

cat <<END > $tmp/lan.tmp
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto $eth
iface $eth inet static
	mtu 1492
	address $ip
	netmask $mask
	gateway $gateway
	`[[ ! -z $dnsv4 ]] && echo "dns-nameservers $dnsv4"`
	
END

if [ ! -z "$ipv6" -a ! -z "$gateway6" -a ! -z "$mask6" ]; then
cat <<END >> $tmp/lan.tmp
# IPv6 address
iface $eth inet6 static
	mtu 1492
	address $ipv6
	netmask $mask6
	gateway $gateway6
	autoconf 0
	`[[ ! -z $dnsv6 ]] && echo "dns-nameservers $dnsv6"`
	
END
fi



	if [ "$dnssuffix" = "$empty" ] 
	then
		len=${#dns1[*]}
		i=0
	while [ $i -lt $len ];
		do
		printf "\
nameserver ${dns1[$i]}\n"
			let i++
		done 
		len=${#domain[*]}
		i=0
	while [ $i -lt $len ];
		do
		printf "\
# search ${domain[$i]}\n\
# domain ${domain[$i]}\n"
			let i++
		done
	else
		len=${#dns1[*]}
		i=0
	while [ $i -lt $len ];
		do
		printf "\
nameserver ${dns1[$i]}\n"
			let i++
		done 
		len=${#dnssuffix[*]}
		i=0
	while [ $i -lt $len ];
		do
		printf "\
search ${dnssuffix[$i]}\n\
domain ${dnssuffix[$i]}\n"
		let i++
		done
	fi > $tmp/dns.tmp;
else

cat <<END > $tmp/lan.tmp
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto $eth
iface $eth inet dhcp
	mtu 1492

iface $eth inet6 dhcp
	mtu 1492
	
END

fi;

sed -i "/^options/d" $tmp/dns.tmp; echo "options edns0" >> $tmp/dns.tmp

mv $tmp/lan.tmp $lan
mv $tmp/dns.tmp $dns

lockfile-remove $tmp/lan
lockfile-remove $tmp/dns

. /var/www/bin/dns.sh

lockfile-create $tmp/restartnet
ifdown $eth && ifup $eth || ($networking force-reload || $networking restart || (lockfile-remove $tmp/restartnet reboot));
lockfile-remove $tmp/restartnet

. /var/www/bin/scrollout.sh traffic

. /var/www/bin/reset_iptables.sh

