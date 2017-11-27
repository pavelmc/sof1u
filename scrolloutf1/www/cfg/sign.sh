#!/bin/bash

pwd=/var/spool/filter
disclaimers=/var/spool/disclaimers
url="http://`hostname -f`/report.php"

test -d $pwd || mkdir -p $pwd
test -d $disclaimers || mkdir -p $disclaimers
umask 077

encrypt="/var/www/bin/crypt.sh encrypt"
decrypt="/var/www/bin/crypt.sh decrypt"
encode="/var/www/bin/crypt.sh encode"
decode="/var/www/bin/crypt.sh decode"

SENDMAIL="/usr/sbin/sendmail -G -i"


# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

# Clean up when done or when aborting.
function cleanup() {
test -f $pwd/$id.$$ && rm -f $pwd/$id.$$
}

trap cleanup 0 1 2 3 15

# Start processing.
cd $pwd || (
echo $pwd does not exist; exit $EX_TEMPFAIL; )

sender=`echo $@ | awk -F " " '{print tolower($2)}'`
s_domain=`echo "$sender" | cut -d "@" -f2`;

recipient=`echo $@ | awk -F " " '{print tolower($4)}'`
r_domain=`echo "$recipient" | cut -d "@" -f2`;

id=`echo "$sender--$recipient" | sed "s/[[:punct:]]/_/g"``echo $RANDOM``echo $RANDOM`

cat >$pwd/$id.$$ || ( 
echo "Cannot save mail to file $pre_filter/$id.$$"; exit $EX_TEMPFAIL; 
)

cat <<END >$disclaimers/$id.$$.txt

Report concern: $url
END

cat <<END >$disclaimers/$id.$$.html

<!-- report concern --> <br><br><div style="font-family: Arial,Verdana,Helvetica,Calibri,sans-serif; font-size: 8pt;">
<!-- report concern --> <br><br>
<!-- report concern --> <a href="$url" style="text-decoration: none;">Report concern<a>
<!-- report concern --> </div><br><br>

END

if echo $recipient | grep -q "marius"; then
/usr/bin/altermime --multipart-insert \
		    --input=$pwd/$id.$$ \
		    --disclaimer=$disclaimers/$id.$$.txt \
		    --xheader=X-Report-Abuse:" $url" \
		    --disclaimer-html=$disclaimers/$id.$$.html \
		    --force-for-bad-html && rm $disclaimers/$id.$$.* || \
                     ( echo Message content rejected; exit $EX_UNAVAILABLE; )
fi				 
					 
$SENDMAIL "$@" < $pwd/$id.$$ || (
    echo "Cannot read $pwd/$$id.$$ file"; exit $EM_TEMPFAIL;)
	
test -f $pwd/$id.$$ && rm -f $pwd/$id.$$

exit $?

