#!/bin/bash

wan_tcp_services_1="22,25,80,443,465,587"
wan_udp_services_1="33434:33534"

lan_tcp_services_1="22,25,80,443,143,993,465,587"
lan_tcp_services_2="8080"

lan_udp_services_1="53,5353,24441"
lan_udp_services_2="53,4500,6277,24441,33434:33534"

lo_tcp_services="10024,10025,10026,10027,10028,8080"
lo_udp_services="53,5353,24441,33434:33534"

ssh="22"

echo "1" > /proc/sys/net/ipv4/tcp_syncookies
echo "0" > /proc/sys/net/ipv4/ip_no_pmtu_disc
echo "0" > /proc/sys/net/ipv4/conf/default/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/all/rp_filter
echo "0" > /proc/sys/net/ipv4/ip_forward
echo "0" > /proc/sys/net/ipv6/conf/all/forwarding
echo "1" > /proc/sys/net/ipv4/conf/all/accept_redirects
echo "1" > /proc/sys/net/ipv6/conf/all/accept_redirects
echo "1" > /proc/sys/net/ipv4/conf/all/send_redirects
echo "1" > /proc/sys/net/ipv4/conf/all/secure_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
echo "0" > /proc/sys/net/ipv6/conf/all/accept_source_route
echo "0" > /proc/sys/net/ipv4/tcp_tw_recycle
echo "0" > /proc/sys/net/ipv4/tcp_tw_reuse
echo "60" > /proc/sys/net/ipv4/tcp_fin_timeout
echo "7200" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "75" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "9" > /proc/sys/net/ipv4/tcp_keepalive_probes



for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo "0" > $i; done

iptables -F
ip6tables -F

iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -N INVALID
iptables -N INVDROP
iptables -N SYNATTACK
iptables -N DDOSDROP

ip6tables -X
ip6tables -t mangle -F
ip6tables -t mangle -X
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

ip6tables -N INVALID
ip6tables -N INVDROP
ip6tables -N SYNATTACK
ip6tables -N DDOSDROP

iptables -A DDOSDROP -j DROP
ip6tables -A DDOSDROP -j DROP


iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP

ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -s ::1/128 ! -i lo -j DROP

iptables -A SYNATTACK -m limit --limit 60/s --limit-burst 120 -j RETURN 
iptables -A SYNATTACK -j DROP

iptables -A INVALID ! -i lo -m conntrack --ctstate INVALID -j INVDROP 
iptables -A INVALID -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j INVDROP 
iptables -A INVALID -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j INVDROP 
iptables -A INVALID -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j INVDROP 
iptables -A INVALID -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j INVDROP 
iptables -A INVALID -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j INVDROP 
iptables -A INVALID -p tcp -m tcp --tcp-flags FIN,ACK FIN -j INVDROP 
iptables -A INVALID -p tcp -m tcp --tcp-flags PSH,ACK PSH -j INVDROP 
iptables -A INVALID -p tcp -m tcp --tcp-flags ACK,URG URG -j INVDROP 
iptables -A INVALID -p tcp -m tcp ! --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j INVDROP 
iptables -A INVDROP -j DROP

iptables -A INPUT ! -i lo -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j SYNATTACK
iptables -A INPUT ! -i lo -p tcp -j INVALID

iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT ! -o lo -p tcp -j INVALID 
iptables -A OUTPUT ! -o lo -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 
iptables -A OUTPUT ! -o lo -p tcp -m conntrack --ctstate NEW -m tcp --dport 0:65000 -j ACCEPT 
iptables -A OUTPUT ! -o lo -p udp -m conntrack --ctstate NEW -m udp --dport 0:65000 -j ACCEPT 
iptables -A OUTPUT ! -o lo -p icmp -m icmp --icmp-type 0 -j ACCEPT 
iptables -A OUTPUT ! -o lo -p icmp -m icmp --icmp-type 8 -j ACCEPT 
iptables -A OUTPUT ! -o lo -p icmp -m icmp --icmp-type 11 -j ACCEPT 
iptables -A OUTPUT ! -o lo -p icmp -m icmp --icmp-type 3 -j ACCEPT 

iptables -A INPUT -p icmp -m iprange --src-range '10.0.0.0-10.255.255.255' -j ACCEPT
iptables -A INPUT -p icmp -m iprange --src-range '192.168.0.0-192.168.255.255' -j ACCEPT
iptables -A INPUT -p icmp -m iprange --src-range '172.16.0.0-172.255.255.255' -j ACCEPT


# Allow localhost traffic. This rule is for all protocols.

ip6tables -A INPUT -s ::1 -d ::1 -j ACCEPT


# Allow some ICMPv6 types in the INPUT chain
# Using ICMPv6 type names to be clear.

ip6tables -A INPUT -p icmpv6 --icmpv6-type destination-unreachable -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type packet-too-big -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type time-exceeded -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type parameter-problem -j ACCEPT


# Allow some other types in the INPUT chain, but rate limit.
ip6tables -A INPUT -p icmpv6 --icmpv6-type echo-request -m limit --limit 900/min -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type echo-reply -m limit --limit 900/min -j ACCEPT


# Allow others ICMPv6 types but only if the hop limit field is 255.

ip6tables -A INPUT -p icmpv6 --icmpv6-type router-advertisement -m hl --hl-eq 255 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type neighbor-solicitation -m hl --hl-eq 255 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type neighbor-advertisement -m hl --hl-eq 255 -j ACCEPT
ip6tables -A INPUT -p icmpv6 --icmpv6-type redirect -m hl --hl-eq 255 -j ACCEPT


# When there isn't a match, the default policy (DROP) will be applied.
# To be sure, drop all other ICMPv6 types.
# We're dropping enough icmpv6 types to break RFC compliance.

ip6tables -A INPUT -p icmpv6 -j LOG --log-prefix "dropped ICMPv6"
ip6tables -A INPUT -p icmpv6 -j DROP



# Allow ICMPv6 types that should be sent through the Internet.

ip6tables -A OUTPUT -p icmpv6 --icmpv6-type destination-unreachable -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 --icmpv6-type packet-too-big -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 --icmpv6-type time-exceeded -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 --icmpv6-type parameter-problem -j ACCEPT


# Limit most NDP messages to the local network.

ip6tables -A OUTPUT -p icmpv6 --icmpv6-type neighbour-solicitation -m hl --hl-eq 255 -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 --icmpv6-type neighbour-advertisement -m hl --hl-eq 255 -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 --icmpv6-type router-solicitation -m hl --hl-eq 255 -j ACCEPT


# If we're acting like a router, this could be a sign of problems.

ip6tables -A OUTPUT -p icmpv6 --icmpv6-type router-advertisement -j LOG --log-prefix "ra ICMPv6 type"
ip6tables -A OUTPUT -p icmpv6 --icmpv6-type redirect -j LOG --log-prefix "redirect ICMPv6 type"
ip6tables -A OUTPUT -p icmpv6 --icmpv6-type router-advertisement -j REJECT
ip6tables -A OUTPUT -p icmpv6 --icmpv6-type redirect -j REJECT


# Accept all other ICMPv6 types in the OUTPUT chain.

ip6tables -A OUTPUT -p icmpv6 -j ACCEPT


# Reject in the FORWARD chain. This rule is probably not needed 
# due to the FORWARD policy.

ip6tables -A FORWARD -p icmpv6 -j REJECT


# Stateful matching to allow requested traffic in.
iptables -A OUTPUT -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

ip6tables -A OUTPUT -j ACCEPT
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


# Drop NEW,INVALID probably not needed due to the default drop policy.

ip6tables -A INPUT -m state --state NEW,INVALID -j DROP


# REJECT everything in the FORWARD chain.

ip6tables -A FORWARD -p tcp -j REJECT
ip6tables -A FORWARD -p udp -j REJECT

iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -A OUTPUT -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

ipaddr=`ip -o addr show | grep "global" | awk '/inet/ {print $4}' | cut -d "/" -f1 | grep -v "^127\.0\.0" | head -n1`
. /var/www/traffic.cfg



iptables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_1 -m iprange --src-range '127.0.0.0-127.255.255.255' -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_1 -m iprange --src-range '10.0.0.0-10.255.255.255' -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_1 -m iprange --src-range '192.168.0.0-192.168.255.255' -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_1 -m iprange --src-range '172.16.0.0-172.255.255.255' -j ACCEPT

iptables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_2 -m iprange --src-range '127.0.0.0-127.255.255.255' -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_2 -m iprange --src-range '10.0.0.0-10.255.255.255' -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_2 -m iprange --src-range '192.168.0.0-192.168.255.255' -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_2 -m iprange --src-range '172.16.0.0-172.255.255.255' -j ACCEPT

ip6tables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_1 -s fc00::/7 -j ACCEPT
ip6tables -A INPUT -p tcp -m multiport --dports $lan_tcp_services_2 -s fc00::/7 -j ACCEPT

iptables -A INPUT -p udp -m multiport --dports $lan_udp_services_1 -m iprange --src-range '127.0.0.0-127.255.255.255' -j ACCEPT
iptables -A INPUT -p udp -m multiport --dports $lan_udp_services_1 -m iprange --src-range '10.0.0.0-10.255.255.255' -j ACCEPT
iptables -A INPUT -p udp -m multiport --dports $lan_udp_services_1 -m iprange --src-range '192.168.0.0-192.168.255.255' -j ACCEPT
iptables -A INPUT -p udp -m multiport --dports $lan_udp_services_1 -m iprange --src-range '172.16.0.0-172.255.255.255' -j ACCEPT
ip6tables -A INPUT -p udp -m multiport --dports $lan_udp_services_1 -s fc00::/7 -j ACCEPT

iptables -A INPUT -p udp -m multiport --dports $lan_udp_services_2 -m iprange --src-range '127.0.0.0-127.255.255.255' -j ACCEPT
iptables -A INPUT -p udp -m multiport --dports $lan_udp_services_2 -m iprange --src-range '10.0.0.0-10.255.255.255' -j ACCEPT
iptables -A INPUT -p udp -m multiport --dports $lan_udp_services_2 -m iprange --src-range '192.168.0.0-192.168.255.255' -j ACCEPT
iptables -A INPUT -p udp -m multiport --dports $lan_udp_services_2 -m iprange --src-range '172.16.0.0-172.255.255.255' -j ACCEPT
ip6tables -A INPUT -p udp -m multiport --dports $lan_udp_services_2 -s fc00::/7 -j ACCEPT

iptables -A INPUT  -p 50 -j ACCEPT
iptables -A OUTPUT -p 50 -j ACCEPT
iptables -A INPUT  -p udp --sport 500 --dport 500 -j ACCEPT
iptables -A OUTPUT -p udp --sport 500 --dport 500 -j ACCEPT
iptables -A INPUT -p udp --sport 4500 --dport 4500 -j ACCEPT
iptables -A OUTPUT -p udp --sport 4500 --dport 4500 -j ACCEPT

ip6tables -A INPUT  -p udp --sport 500 --dport 500 -j ACCEPT
ip6tables -A OUTPUT -p udp --sport 500 --dport 500 -j ACCEPT
ip6tables -A INPUT -p udp --sport 4500 --dport 4500 -j ACCEPT
ip6tables -A OUTPUT -p udp --sport 4500 --dport 4500 -j ACCEPT

mynets=(`echo "${mynets[*]}" | sed 's/\( *\|^\)\(!?192\|10\|172\)\.[0-9]*\.[0-9]*\.[0-9]*\/[0-9]*\( \|$\)/ /g' | sed 's/  \|,/ /g' | tr ' ' '\n' | grep -vi "[a-z]" | sort -ur | tr '\n' ' '`);
for trustedip in ${mynets[*]}; do
	[[ $trustedip != \![0-9]* ]] && (
	
iptables -A INPUT -p tcp -s $trustedip -m multiport --dports $lan_tcp_services_1 ! -i lo -m conntrack --ctstate NEW -m limit --limit 50/second --limit-burst 100 -j ACCEPT;
iptables -A INPUT -p tcp -s $trustedip -m multiport --dports $lan_tcp_services_2 ! -i lo -m conntrack --ctstate NEW -m limit --limit 50/second --limit-burst 100 -j ACCEPT;

iptables -A INPUT -p udp -s $trustedip ! -i lo -m multiport --dports $lan_udp_services_1 -m conntrack --ctstate NEW -m limit --limit 2500/second --limit-burst 3000 -j ACCEPT;

)
done

iptables -A INPUT -p tcp -m multiport --dports $lo_tcp_services ! -i lo -j DROP

### Total connections allowed per IP Network MASKs (Global)

iptables -A INPUT -p tcp --dport $ssh -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport $ssh -m conntrack --ctstate NEW -m recent --update --seconds 600 --hitcount 5 -j DROP

iptables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 50 --connlimit-mask 32 -j DDOSDROP
iptables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 100 --connlimit-mask 24 -j DDOSDROP
iptables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 250 --connlimit-mask 16 -j DDOSDROP
iptables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 500 --connlimit-mask 8 -j DDOSDROP

ip6tables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 50 --connlimit-mask 128 -j DDOSDROP
ip6tables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 50 --connlimit-mask 64 -j DDOSDROP
ip6tables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 250 --connlimit-mask 32 -j DDOSDROP
ip6tables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 250 --connlimit-mask 24 -j DDOSDROP
ip6tables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 500 --connlimit-mask 16 -j DDOSDROP
ip6tables -A INPUT ! -i lo -m conntrack --ctstate NEW -m connlimit --connlimit-above 500 --connlimit-mask 8 -j DDOSDROP


### Limits for allowed local services (per each Source)


### Limits for allowed local services (Global)

iptables -A INPUT -p tcp -m multiport --dports $wan_tcp_services_1 ! -i lo -m conntrack --ctstate NEW -m limit --limit 250/second --limit-burst 1000 -j ACCEPT
ip6tables -A INPUT -p tcp -m multiport --dports $wan_tcp_services_1 ! -i lo -m conntrack --ctstate NEW -m limit --limit 250/second --limit-burst 1000 -j ACCEPT

iptables -A INPUT -p udp ! -i lo -m multiport --dports $wan_udp_services_1 -m conntrack --ctstate NEW -m limit --limit 250/second --limit-burst 1000 -j ACCEPT
ip6tables -A INPUT -p udp ! -i lo -m multiport --dports $wan_udp_services_1 -m conntrack --ctstate NEW -m limit --limit 250/second --limit-burst 1000 -j ACCEPT

iptables -A INPUT -p icmp -m icmp --icmp-type 8 -m limit --limit 45/min --limit-burst 60 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 0 -m limit --limit 45/min --limit-burst 60 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 11 -m limit --limit 45/min --limit-burst 60 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 3 -m limit --limit 45/min --limit-burst 60 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 3/4 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 3/3 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 3/1 -j ACCEPT

### Allow any RELATED or ESTABLISHED connection except ICMP
iptables -A INPUT ! -p icmp -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A INPUT ! -p icmp -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT


### ICMP Protocol only

iptables -A OUTPUT -p icmp --icmp-type 3/4 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 3/4 -j ACCEPT

iptables -A FORWARD -p icmp --icmp-type 3/3 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 3/3 -j ACCEPT

iptables -A FORWARD -p icmp --icmp-type 3/1 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 3/1 -j ACCEPT

test -f /var/www/connection.cfg && . /var/www/connection.cfg && ports=`echo "$port" | sed "s/\-/\:/g"`
( ! [ "$ports" = "" ] && ! [ "$ports" = "25" ] ) && iptables -t nat -A PREROUTING -p tcp ! -i lo -m multiport --dports 25,$ports  -j REDIRECT --to 25

iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# The signature of this host is a TTL=100 in ping response (minus number of nodes/routers in between)
# iptables -t mangle -A POSTROUTING -p icmp -j TTL --ttl-set 100
echo "100" > /proc/sys/net/ipv4/ip_default_ttl

iptables -t mangle -A POSTROUTING -p tcp -s 127.0.0.0/8 --sport 10024 -j TTL --ttl-set 3
iptables -t mangle -A POSTROUTING -p tcp -s 127.0.0.0/8 --sport 10025 -j TTL --ttl-set 3
iptables -t mangle -A POSTROUTING -p tcp -s 127.0.0.0/8 --sport 10026 -j TTL --ttl-set 3
iptables -t mangle -A POSTROUTING -p tcp -s 127.0.0.0/8 --sport 10027 -j TTL --ttl-set 3
iptables -t mangle -A POSTROUTING -p tcp -s 127.0.0.0/8 --sport 10028 -j TTL --ttl-set 3
iptables -t mangle -A POSTROUTING -p tcp ! -s 127.0.0.0/8 --sport 8080 -j TTL --ttl-set 30
iptables -t mangle -A POSTROUTING -p tcp ! -s 127.0.0.0/8 -d $ipaddr -m multiport --dports 25,465,587 -j TTL --ttl-set 30
iptables -t mangle -A POSTROUTING -p tcp ! -s 127.0.0.0/8 -d $ipaddr -m multiport --dports 22,80,443,143,993,389 -j TTL --ttl-set 20

iptables -t mangle -A POSTROUTING ! -s 127.0.0.0/8 -p tcp ! --sport 25 -m iprange --dst-range '10.0.0.0-10.255.255.255' -j TTL --ttl-set 30
iptables -t mangle -A POSTROUTING ! -s 127.0.0.0/8 -p tcp ! --sport 25 -m iprange --dst-range '192.168.0.0-192.168.255.255' -j TTL --ttl-set 30
iptables -t mangle -A POSTROUTING ! -s 127.0.0.0/8 -p tcp ! --sport 25 -m iprange --dst-range '172.16.0.0-172.255.255.255' -j TTL --ttl-set 30

iptables -t mangle -A PREROUTING -p udp -m udp --sport 16384:32768 -j DSCP --set-dscp-class EF
iptables -t mangle -A PREROUTING -p udp -m udp --sport 5060 -j DSCP --set-dscp-class CS3
iptables -t mangle -A PREROUTING -p tcp --sport 5060 -j DSCP --set-dscp-class CS3
iptables -t mangle -A PREROUTING -p tcp --sport 5061 -j DSCP --set-dscp-class CS3

iptables -t mangle -A PREROUTING -p tcp -m multiport --sports 22,5060,5061 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp -m multiport --dports 22,5060,5061 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p udp -m multiport --sports 5060 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p udp -m multiport --dports 5060 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp -m multiport --sports 25,465,587,143,993 -j TOS --set-tos Normal-Service
iptables -t mangle -A PREROUTING -p tcp -m multiport --dports 25,465,587,143,993 -j TOS --set-tos Normal-Service
iptables -t mangle -A PREROUTING -p tcp --sport 53 -j TOS --set-tos Maximize-Reliability
iptables -t mangle -A PREROUTING -p tcp --dport 53 -j TOS --set-tos Maximize-Reliability
iptables -t mangle -A PREROUTING -p udp --sport 53 -j TOS --set-tos Maximize-Reliability
iptables -t mangle -A PREROUTING -p udp --dport 53 -j TOS --set-tos Maximize-Reliability
iptables -t mangle -A PREROUTING -p tcp --sport 389 -j TOS --set-tos Maximize-Reliability
iptables -t mangle -A PREROUTING -p tcp --dport 389 -j TOS --set-tos Maximize-Reliability
iptables -t mangle -A PREROUTING -p tcp --sport 80 -j TOS --set-tos Maximize-Throughput
iptables -t mangle -A PREROUTING -p tcp --dport 80 -j TOS --set-tos Maximize-Throughput
iptables -t mangle -A PREROUTING -p tcp --sport 443 -j TOS --set-tos Maximize-Throughput
iptables -t mangle -A PREROUTING -p tcp --dport 443 -j TOS --set-tos Maximize-Throughput
iptables -t mangle -A PREROUTING -p tcp --sport 8080 -j TOS --set-tos Minimize-Cost
iptables -t mangle -A PREROUTING -p tcp --dport 8080 -j TOS --set-tos Minimize-Cost

iptables -t mangle -A PREROUTING -p tcp -m multiport --sports 22,5060,5061 -j DSCP --set-dscp-class CS3
iptables -t mangle -A PREROUTING -p tcp -m multiport --dports 22,5060,5061 -j DSCP --set-dscp-class CS3
iptables -t mangle -A PREROUTING -p udp -m multiport --sports 5060 -j DSCP --set-dscp-class CS3
iptables -t mangle -A PREROUTING -p udp -m multiport --dports 5060 -j DSCP --set-dscp-class CS3
iptables -t mangle -A PREROUTING -p tcp -m multiport --sports 25,465,587,143,993 -j DSCP --set-dscp-class BE
iptables -t mangle -A PREROUTING -p tcp -m multiport --dports 25,465,587,143,993 -j DSCP --set-dscp-class BE
iptables -t mangle -A PREROUTING -p tcp --sport 53 -j DSCP --set-dscp-class AF42
iptables -t mangle -A PREROUTING -p tcp --dport 53 -j DSCP --set-dscp-class AF42
iptables -t mangle -A PREROUTING -p udp --sport 53 -j DSCP --set-dscp-class AF42
iptables -t mangle -A PREROUTING -p udp --dport 53 -j DSCP --set-dscp-class AF42
iptables -t mangle -A PREROUTING -p tcp --sport 389 -j DSCP --set-dscp-class AF42
iptables -t mangle -A PREROUTING -p tcp --dport 389 -j DSCP --set-dscp-class AF42
iptables -t mangle -A PREROUTING -p tcp --sport 80 -j DSCP --set-dscp-class AF32
iptables -t mangle -A PREROUTING -p tcp --dport 80 -j DSCP --set-dscp-class AF32
iptables -t mangle -A PREROUTING -p tcp --sport 443 -j DSCP --set-dscp-class AF32
iptables -t mangle -A PREROUTING -p tcp --dport 443 -j DSCP --set-dscp-class AF32
iptables -t mangle -A PREROUTING -p tcp --sport 8080 -j DSCP --set-dscp-class AF12
iptables -t mangle -A PREROUTING -p tcp --dport 8080 -j DSCP --set-dscp-class AF12

ip6tables -t mangle -A PREROUTING -p tcp -m multiport --sports 22,5060,5061 -j TOS --set-tos Minimize-Delay
ip6tables -t mangle -A PREROUTING -p tcp -m multiport --dports 22,5060,5061 -j TOS --set-tos Minimize-Delay
ip6tables -t mangle -A PREROUTING -p udp -m multiport --sports 5060 -j TOS --set-tos Minimize-Delay
ip6tables -t mangle -A PREROUTING -p udp -m multiport --dports 5060 -j TOS --set-tos Minimize-Delay
ip6tables -t mangle -A PREROUTING -p tcp -m multiport --sports 25,465,587,143,993 -j TOS --set-tos Normal-Service
ip6tables -t mangle -A PREROUTING -p tcp -m multiport --dports 25,465,587,143,993 -j TOS --set-tos Normal-Service
ip6tables -t mangle -A PREROUTING -p tcp --sport 53 -j TOS --set-tos Maximize-Reliability
ip6tables -t mangle -A PREROUTING -p tcp --dport 53 -j TOS --set-tos Maximize-Reliability
ip6tables -t mangle -A PREROUTING -p udp --sport 53 -j TOS --set-tos Maximize-Reliability
ip6tables -t mangle -A PREROUTING -p udp --dport 53 -j TOS --set-tos Maximize-Reliability
ip6tables -t mangle -A PREROUTING -p tcp --sport 389 -j TOS --set-tos Maximize-Reliability
ip6tables -t mangle -A PREROUTING -p tcp --dport 389 -j TOS --set-tos Maximize-Reliability
ip6tables -t mangle -A PREROUTING -p tcp --sport 80 -j TOS --set-tos Maximize-Throughput
ip6tables -t mangle -A PREROUTING -p tcp --dport 80 -j TOS --set-tos Maximize-Throughput
ip6tables -t mangle -A PREROUTING -p tcp --sport 443 -j TOS --set-tos Maximize-Throughput
ip6tables -t mangle -A PREROUTING -p tcp --dport 443 -j TOS --set-tos Maximize-Throughput
ip6tables -t mangle -A PREROUTING -p tcp --sport 8080 -j TOS --set-tos Minimize-Cost
ip6tables -t mangle -A PREROUTING -p tcp --dport 8080 -j TOS --set-tos Minimize-Cost


ip6tables -t mangle -A PREROUTING -p tcp -m multiport --sports 22,5060,5061 -j DSCP --set-dscp-class CS3
ip6tables -t mangle -A PREROUTING -p tcp -m multiport --dports 22,5060,5061 -j DSCP --set-dscp-class CS3
ip6tables -t mangle -A PREROUTING -p udp -m multiport --sports 5060 -j DSCP --set-dscp-class CS3
ip6tables -t mangle -A PREROUTING -p udp -m multiport --dports 5060 -j DSCP --set-dscp-class CS3
ip6tables -t mangle -A PREROUTING -p tcp -m multiport --sports 25,465,587,143,993 -j DSCP --set-dscp-class BE
ip6tables -t mangle -A PREROUTING -p tcp -m multiport --dports 25,465,587,143,993 -j DSCP --set-dscp-class BE
ip6tables -t mangle -A PREROUTING -p tcp --sport 53 -j DSCP --set-dscp-class AF42
ip6tables -t mangle -A PREROUTING -p tcp --dport 53 -j DSCP --set-dscp-class AF42
ip6tables -t mangle -A PREROUTING -p udp --sport 53 -j DSCP --set-dscp-class AF42
ip6tables -t mangle -A PREROUTING -p udp --dport 53 -j DSCP --set-dscp-class AF42
ip6tables -t mangle -A PREROUTING -p tcp --sport 389 -j DSCP --set-dscp-class AF42
ip6tables -t mangle -A PREROUTING -p tcp --dport 389 -j DSCP --set-dscp-class AF42
ip6tables -t mangle -A PREROUTING -p tcp --sport 80 -j DSCP --set-dscp-class AF32
ip6tables -t mangle -A PREROUTING -p tcp --dport 80 -j DSCP --set-dscp-class AF32
ip6tables -t mangle -A PREROUTING -p tcp --sport 443 -j DSCP --set-dscp-class AF32
ip6tables -t mangle -A PREROUTING -p tcp --dport 443 -j DSCP --set-dscp-class AF32
ip6tables -t mangle -A PREROUTING -p tcp --sport 8080 -j DSCP --set-dscp-class AF12
ip6tables -t mangle -A PREROUTING -p tcp --dport 8080 -j DSCP --set-dscp-class AF12

iptables-save > /var/www/cfg/iptables.up.rule

printf "#!/bin/sh
iptables-restore < /var/www/cfg/iptables.up.rule
" > /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables

ps -A | grep fail2ban | awk '{print $1}' | parallel --gnu kill -9 {} > /dev/null 2>&1
rm -f /var/run/fail2ban/fail2ban.sock
/etc/init.d/fail2ban restart > /dev/null 2>&1
service bind9 restart