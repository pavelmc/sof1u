#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

while getopts ":t:s:r:h:l:" opt; do
  case "$opt" in
	  s) sender=$OPTARG;;
	  r) receiver=$OPTARG ;;
	  t) timestamp=$OPTARG ;;
	  l) logtype=$OPTARG ;;
	  *) echo -e "
stat	-t seconds n
	-s sender
	-r receiver
	-t timestamp
	-l log type: [a]ll default, [d]elivery, [b]ounces, [j]unk, [v]irus, [R]ealtime Blocklist
" && exit;
	  ;;
	esac
done

(test "$logtype" = "" || test "$logtype" = "all") && logtype="dhsbjv";
test "$sender" = "" && sender="@";
test "$receiver" = "" && receiver="@";
test "$timestamp" = "" && echo "Please input time in seconds (stat -t <seconds>)" && exit 1;

files=`ls -l --full-time /var/log/mail.log* | grep -v "\.gz" | gawk -v starttime=$timestamp '{FS=" "; secago = strftime("%Y-%m-%d %H:%M:%S", systime() - starttime); if (substr($6" "$7,0,19) >= secago ) print $NF} ';`
[ "$files" != "" ] && gawk -v starttime=$timestamp '{FS=" "; secago = strftime("%b %e %H:%M:%S", systime() - starttime); if ( substr($0,1,15) >= secago ) print $0}' $files |\
gawk  -v filter=$logtype '
BEGIN {FS=" "; del=", "; countd=countr=countj=countv=countrbl="0"; IGNORECASE=1; secago = strftime("%b %e %H:%M:%S", systime() - starttime)}

filter=="R" && / postfix\/smtp.* .* to=<.*'"$receiver"'.*>, .* status=bounced .* http/{
	match($0, /^(.*) .* postfix\/smtp.* .* to=<.*@(.*\..*)>.* (http[a-zA-Z0-9\:\/\.\-\_\?\=\&]*) /, rbllog)
	rbltime=rbllog[1]
	rblrcpt=rbllog[2]
	rblurl=rbllog[3]
	rbl[rblrcpt,del,rblurl]++
	rbltype="Realtime Block List"
	countrbl++;
}

filter~"d" && / postfix\/smtp.* to=<.*'"$receiver"'.*>, .*, .*, dsn=2.[0-9].[0-9], status=sent/{
	match($0, /^(.*) .* postfix\/smtp.* to=<(.*@.*\..*)>, relay=/, deliv)
	timed=deliv[1]
	drcpt=tolower(deliv[2])
	deliveredrcpt[drcpt]++
	typed="delivered";
	countd++;
}

filter~"j" && / amavis.* SPAM.* <.*'"$sender"'.*> -> <.*'"$receiver"'.*>, .* Message-ID/{
	match($0, /^(.*) .* amavis.* SPAM.* <(.*@.*\..*)> -> <(.*@.*\..*)>, .* Message-ID/, junk)
	timej=junk[1]
	jsndr=tolower(junk[2])
	jrcpt=tolower(junk[3])
	j[jsndr,del,jrcpt]++
	typej="SPAM";
	countj++;
}

filter~"v" && / amavis.* .* (INFECT|BAN).* <.*'"$sender"'.*> -> <.*'"$receiver"'.*>, .* Message-ID/{
	match($0, /^(.*) .* amavis.* .* <(.*@.*\..*)> -> <(.*@.*\..*)>, .* Message-ID/, virus)
	timev=virus[1]
	vsndr=tolower(virus[2])
	vrcpt=tolower(virus[3])
	v[vsndr,del,vrcpt]++
	typev="VIRUS-BAN";
	countv++;
}

filter~"b" && / postfix\/smtpd.* NOQUEUE: reject: .* from=<.*'"$sender"'.*> to=<.*'"$receiver"'.*> proto/{
	match($0, /^(.*) .* postfix\/smtpd.* NOQUEUE: reject: .* from=<(.*@.*\..*)> to=<(.*@.*\..*)> proto/, reject)
	rtime=reject[1]
	rsndr=tolower(reject[2])
	rrcpt=tolower(reject[3])
	rej[rsndr,del,rrcpt]++
	rtype="rejected";
	countr++;
}


END { 

if (countr > 0){
for (rvar in rej)
print rtype del rvar del rej[rvar]
}

if (countrbl > 0){
for (rblvar in rbl)
print rbltype del rblvar del rbl[rblvar]
}

if (countd > 0){
for (dvar in deliveredrcpt)
print typed del dvar del deliveredrcpt[dvar]
}

if (countj > 0){
for (jvar in j)
print typej del jvar del j[jvar]
}

if (countv > 0){
for (vvar in v)
print typev del vvar del v[vvar]
}

if (countrbl == 0 && (countd >= 0 || countr >= 0 || countj >= 0 || countv >= 0)) {
printf "#"
printf " Deliveries:" countd "(" "%.0f",(countd/(countd+countr+countj+countv)*100); printf "%);"
printf " Rejected:" countr "(" "%.0f",(countr/(countd+countr+countj+countv)*100); printf "%);"
printf " Spam:" countj "(" "%.0f",(countj/(countd+countr+countj+countv)*100); printf "%);"
printf " Virus:" countv "(" "%.0f",(countv/(countd+countr+countj+countv)*100); printf "%);"
}
}

' | gawk '{gsub(/[[:cntrl:]]/,""); print}' 2> /dev/null;

exit 0;
