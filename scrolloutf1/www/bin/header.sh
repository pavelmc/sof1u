#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

case $1 in
mem)

memory=`free -m`

mem_used=`echo "$memory" | awk '/^Mem/ {print $3}'`
mem_free=`echo "$memory" | awk '/^Mem/ {print $4}'`
mem_total=`echo "$memory" | awk '/^Mem/ {print $2}'`
mem_used_p=`awk 'BEGIN{printf "%.0f\n",('"$mem_used"'/'"$mem_total"'*100)}'`

sw_used=`echo "$memory" | awk '/^Swap/ {print $3}'`
sw_free=`echo "$memory" | awk '/^Swap/ {print $4}'`
sw_total=`echo "$memory" | awk '/^Swap/ {print $2}'`
sw_used_p=`awk 'BEGIN{printf "%.0f\n",('"$sw_used"'/'"$sw_total"'*100)}'`

echo -e "<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
echo "<tr>"
    echo "<td width=\"20%\" class=\"styleh\" align=\"right\">"
    echo "<a id=\"text_hron\"><b>RAM:</b> $mem_used"M"/$mem_total"M" $mem_used_p% &nbsp;</a>"
    echo "</td>"

[[ $mem_used_p -ge 90 ]] && wmem=1 || wmem=0;


echo "<td width=\"80%\" class=\"styleh\">"
    echo "<hr id=\"hron\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: $wmem"px"; border: 0; width: $mem_used_p%;\"/>"
    echo "<hr id=\"hroff\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: 0px; border: 0; width: $((100-$mem_used_p))%;\"/>"
echo "</td>"
echo "</tr>"

echo "<tr>"
    echo "<td width=\"20%\" class=\"styleh\" align=\"right\">"
    echo "<a href=\"?service=swap\" id=\"text_hron\" title=\"Clear swap space\"><b>SWAP:</b> $sw_used"M"/$sw_total"M" $sw_used_p% &nbsp;</a>"
    echo "</td>"

[[ $sw_used_p -ge 75 ]] && wsw=1 || wsw=0;


echo "<td width=\"80%\" class=\"styleh\">"
    echo "<hr id=\"hron\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: $wsw"px"; border: 0; width: $sw_used_p%;\"/>"
    echo "<hr id=\"hroff\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: 0px; border: 0; width: $((100-$sw_used_p))%;\"/>"
echo "</td>"
echo "</tr>"

echo -e "</table>"

;;


cpu)
cpu=`/var/www/bin/cpu.sh`

echo -e "<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
echo "<tr>"
    echo "<td width=\"20%\" class=\"styleh\" align=\"right\">"
    echo "<a title=\"`awk -F " *: *" '/^model name\s+/ {print $NF}' /proc/cpuinfo`\" id=\"text_hron\"><b>`grep "^cpu[0-9]\{1,\} " /proc/stat |wc -l` x CPU:</b> $cpu% &nbsp;</a>"
    echo "</td>"

[[ $cpu -ge 90 ]] && wcpu=1 || wcpu=0;


echo "<td width=\"15%\" class=\"styleh\">"
    echo "<a id=\"text_hron\">`uptime | awk '{print toupper($0)}'` &nbsp;</a>"
echo "</td>"
echo "<td class=\"styleh\">"
    echo "<hr id=\"hron\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: $wcpu"px"; border: 0; width: $cpu%;\"/>"
    echo "<hr id=\"hroff\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: 0px; border: 0; width: $((100-$cpu))% ;\"/>"
echo "</td>"
echo "</tr>"
echo -e "</table>"
;;


disk)

disk="`df -h /`"
disksize=`echo "$disk" | awk '/\/$/ {print $2}' | head -n1`;
diskuse=`echo "$disk" | awk '/\/$/ {print $3}' | head -n1`;
diskuse_p=`echo "$disk" | awk '/\/$/ {print $5}' | head -n1`;
dstats=`iostat -dkx 1 2 | awk '/^[a-z]*da[a-z0-9]?* /' | tail -n1`

rps=`echo "$dstats" |awk '/^[a-z]*da[a-z0-9]?* / {printf $4}' | tail -n1`
wps=`echo "$dstats" |awk '/^[a-z]*da[a-z0-9]?* / {printf $5}' | tail -n1`
usage=`echo "$dstats" | awk '/^[a-z]*[a-z0-9]?* / {printf "%.0f\n",((($4+$5)*($11/1000))*100)}' | tail -n1`

echo -e "<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
echo "<tr>"
    echo "<td width=\"20%\" class=\"styleh\" align=\"right\">"
    echo "<a id=\"text_hron\"><b>DISK:</b> Used $diskuse/$disksize $diskuse_p &nbsp;</a>"
    echo "</td>"

[[ `echo $diskuse_p | cut -d "%" -f1` -ge 90 ]] && wdisk=1 || wdisk=0;

echo "<td width=\"80%\" class=\"styleh\">"
    echo "<hr id=\"hron\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: $wdisk"px"; border: 0; width: $diskuse_p;\"/>"
    echo "<hr id=\"hroff\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: 0px; border: 0; width: $((100-`echo $diskuse_p | cut -d "%" -f1`))%;\"/>"
echo "</td>"
echo "</tr>"

echo "<tr>"
    echo "<td width=\"20%\" class=\"styleh\" align=\"right\">"
    echo "<a id=\"text_hron\"><b></b> R:$rps/s W:$wps/s Stress: $usage &nbsp;</a>"
    echo "</td>"

[[ $usage -ge 90 && $usage -le 100 ]] && wusage=1 || wusage=0;
[[ $usage -ge 101 ]] && wusage=2;

echo "<td width=\"80%\" class=\"styleh\">"
    echo "<hr id=\"hron\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: $wusage"px"; border: 0; width: $usage"%";\"/>"
    echo "<hr id=\"hroff\" style=\"vertical-align: middle; display: inline-block; background-color: #fff; height: 0px; border: 0; width: $((100-$usage))%;\"/>"
echo "</td>"
echo "</tr>"


echo -e "</table>"
;;

services)
services=`netstat -natp`
procs=`ps -A`
(echo "$services" | grep -E "master|smtpd" > /dev/null 2>&1) && postfix=text_off || postfix=text_on;
(echo "$services" | grep "amavis" > /dev/null 2>&1) && amavis=text_off || amavis=text_on;
(echo "$procs" | grep "clamd" > /dev/null 2>&1) && clam=text_off || clam=text_on;
(echo "$procs"  | grep "incron" > /dev/null 2>&1) && incron=text_off || incron=text_on;
(echo "$procs"  | grep "cron$" > /dev/null 2>&1) && cron=text_off || cron=text_on;
(echo "$procs"  | grep "dovecot$" > /dev/null 2>&1) && dovecot=text_off || dovecot=text_on;
(iptables -nL | grep -m1 "^DROP" > /dev/null 2>&1) && firewall=text_off || firewall=text_on;
# (echo "$services" | grep ":8080.*apache" > /dev/null 2>&1) && cache=text_off || cache=text_on;
cache=text_off;

if [ $postfix  = "text_off" -a $amavis = "text_off" -a $clam = "text_off" -a $incron = "text_off" -a $cron = "text_off" -a $cache = "text_off" -a $firewall = "text_off" -a $dovecot = "text_off" ]; 
then
    system="HEALTHY"; 
    sysid="text_off";
    else
    system="ALERT"
    sysid="text_on"; 
fi


echo -e "<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
echo "<tr>"
    echo "<td width=\"20%\" class=\"styleh\" align=\"right\">"
    echo "<span id=\"$sysid\"><b>$system</b> &nbsp;</span>"
    echo "</td>"
    
    echo "<td width=\"80%\" class=\"styleh\">"

		echo "<a href="?service=postfix" id=\"$postfix\" title=\"Start or Stop Postfix\">POSTFIX &nbsp;</a>"
		echo "<a href="?service=amavis" id=\"$amavis\" title=\"Start or Stop Amavis. Update Spamassassin.\">&nbsp; AMAVIS &nbsp;</a>"
		echo "<a href="?service=cache" id=\"$cache\" title=\"Clear cache\"> CACHE </a>"
		echo "<a href="?service=clamav" id=\"$clam\" title=\"Start or Stop Clamav. Last update: `freshclam -V`\">&nbsp; CLAMAV  &nbsp;</a>"     
		echo "<a href="?service=dovecot" id=\"$dovecot\" title=\"Start or Stop Dovecot\">&nbsp; DOVECOT &nbsp;</a>"
		echo "<a href="?service=incron" id=\"$incron\" title=\"Start or Stop Incron\">&nbsp; INCRON &nbsp;</a>"
		echo "<a href="?service=cron" id=\"$cron\" title=\"Start or Stop Cron scheduler\">&nbsp; CRON &nbsp;</a>"
		echo "<a href="?service=firewall" id=\"$firewall\" title=\"Start or Stop Firewall\">&nbsp; FIREWALL &nbsp;</a>"
		echo "<a href="?service=reboot" id=\"text_off\" title=\"Reboot the machine\" onclick=\"return confirm('Are you sure you want to RESTART?')\">&nbsp; REBOOT </a>"

    echo "</td>"
echo "</tr>"
echo -e "</table>"
;;

network)

netstat=`netstat -natu`

conns=`echo "$netstat" | grep "ESTABLISHED" | wc -l`
syn_in=`echo "$netstat" | grep "SYN_RECV" | wc -l`
syn_out=`echo "$netstat" | grep "SYN_SENT" | wc -l`
con_wait=`echo "$netstat" | grep "TIME_WAIT" | wc -l`

rx1=`cat /sys/class/net/*e*[0-9]*/statistics/rx_bytes | head -1`
tx1=`cat /sys/class/net/*e*[0-9]*/statistics/tx_bytes | head -1`
kbr1=$(($rx1/1024));
kbt1=$(($tx1/1024));

sleep 1;

rx2=`cat /sys/class/net/*e*[0-9]*/statistics/rx_bytes | head -1`
tx2=`cat /sys/class/net/*e*[0-9]*/statistics/tx_bytes | head -1`
kbr2=$(($rx2/1024));
kbt2=$(($tx2/1024));

if [ $(($kbr2-$kbr1)) -le 1024 ]
then
    kbr="$(($kbr2-$kbr1))KB/s";
    kbpsr="$((($kbr2-$kbr1)*8))kbps";
else
    kbr="$((($kbr2-$kbr1)/1204))MB/s"
    kbpsr="$(((($kbr2-$kbr1)/1204)*8))mbps"
fi


if [ $(($kbt2-$kbt1)) -le 1024 ]
then
    kbt="$(($kbt2-$kbt1))KB/s";
    kbpst="$((($kbt2-$kbt1)*8))kbps";
else
    kbt="$((($kbt2-$kbt1)/1204))MB/s"
    kbpst="$(((($kbt2-$kbt1)/1204)*8))mbps"
fi


mbr="$(($kbr2/1024))MB";
mbt="$(($kbt2/1024))MB";


echo -e "<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
echo "<tr>"
    echo "<td width=\"20%\" class=\"styleh\" align=\"right\">"
    echo "<a title=\"`lspci | awk -F 'Ethernet controller: ' '/Ethernet controller/ {print $NF}'`\" id=\"text_hron\"><b>NETWORK</b> &nbsp;</a>"
    echo "</td>"
    
    echo "<td width=\"80%\" class=\"styleh\">"

        echo "<a id=\"text_hron\">Traffic in/out: $mbr/$mbt&nbsp;</a>"

        echo "<a id=\"text_hron\">Downlink: $kbr($kbpsr)&nbsp;</a>"
        echo "<a id=\"text_hron\">Uplink: $kbt($kbpst)&nbsp;</a>"

        echo "<a id=\"text_hron\">Connections: $conns&nbsp;</a>"
        echo "<a id=\"text_hron\">Wait: $con_wait&nbsp;</a>"
        echo "<a id=\"text_hron\">Syn in/out: $syn_in/$syn_out&nbsp;</a>"

    echo "</td>"
echo "</tr>"
echo -e "</table>"
;;

esac