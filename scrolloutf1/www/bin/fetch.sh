#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

run=/var/run/scrollout;
WRITELOG="logger -t collector -i -p mail.info"

case $1 in

queue )

#####
##### cleanup queue and learn from bounced spam
#####

postqueue -p | awk '/!/' | while read line;
        do
		if ! [[ -z $line ]]; then
        [[ ! -z "$line" ]] && id=`echo "$line" | awk -F '!' '/!/ {print $1}'`
        [[ ! -z "$id" ]] && postsuper -d $id > /dev/null 2>&1
		fi
        done;

postqueue -p | awk '!/ 5xx / { line = $0 } / 5xx / { print line }' | awk '!/!/' | while read line;
        do
		if ! [[ -z $line ]]; then
		[[ ! -z "$line" ]] && id=`echo "$line" | awk '{print $1}'`
        [[ ! -z "$id" ]] && postsuper -h $id > /dev/null 2>&1
		fi
		done

postqueue -p | awk '!/ spam / { line = $0 } / spam / { print line }' | awk '!/!/' | while read line;
        do
		if ! [[ -z $line ]]; then
        [[ ! -z "$line" ]] && id=`echo "$line" | awk '{print $1}'`
        [[ ! -z "$id" ]] && spam_msg=`postcat -q $id | awk '/^Received:/,/^\*\*\*/ {print}' | grep -v "^\*\*\*"` 
		[[ ! -z "$spam_msg" ]] && echo "$spam_msg" | su - amavis -c "sa-learn --no-sync --showdots --spam"
		[[ ! -z "$spam_msg" ]] && echo "$spam_msg" | pyzor report;
        [[ ! -z "$id" ]] && postsuper -h $id > /dev/null 2>&1
		fi
		done

exit 0
;;
esac


. /var/www/collector.cfg;

extract=/var/www/bin/extract.sh;
fetch=/var/www/fetch;
empty=

test "$imapserver" = "$empty" && exit 0;
test "$username" = "$empty" && exit 0;
test "$password" = "$empty" && exit 0;
test "$spamfolder" = "$empty" && exit 0;
test "$legitimatefolder" = "$empty" && exit 0;
test "$mailbox" = "$empty" && exit 0;


test -d $run || mkdir -p $run;
find $run/fetch*.pid -mtime +1 -delete > /dev/null 2>&1
[[ `find $run/fetch.pid -mmin +300 > /dev/null 2>&1` ]] && disown $(head -1 $run/fetch.pid) && kill -9 $(head -1 $run/fetch.pid) > /dev/null 2>&1;
test -f $run/fetch.pid && echo "another instance is already fetching" && exit 0;
echo $! > $run/fetch.pid

test -d $fetch || mkdir -p $fetch;
test -d $fetch/good || mkdir -p $fetch/good;
test -d $fetch/bad || mkdir -p $fetch/bad;
test -d $fetch/inbox || mkdir -p $fetch/inbox;

test -d $fetch/good/cur || mkdir -p $fetch/good/cur;
test -d $fetch/good/new || mkdir -p $fetch/good/new;
test -d $fetch/good/tmp || mkdir -p $fetch/good/tmp;

test -d $fetch/bad/cur || mkdir -p $fetch/bad/cur;
test -d $fetch/bad/new || mkdir -p $fetch/bad/new;
test -d $fetch/bad/tmp || mkdir -p $fetch/bad/tmp;

test -d $fetch/inbox/cur || mkdir -p $fetch/inbox/cur;
test -d $fetch/inbox/new || mkdir -p $fetch/inbox/new;
test -d $fetch/inbox/tmp || mkdir -p $fetch/inbox/tmp;

chmod 777 -R $fetch
# chown amavis:amavis -R $fetch

find $fetch/good/cur/ -type f -mtime +1 -delete;
find $fetch/good/new/ -type f -mtime +1 -delete;
find $fetch/good/tmp/ -type f -mtime +1 -delete;

find $fetch/bad/cur/ -type f -mtime +1 -delete;
find $fetch/bad/new/ -type f -mtime +1 -delete;
find $fetch/bad/tmp/ -type f -mtime +1 -delete;

find $fetch/inbox/cur/ -type f -delete;
find $fetch/inbox/new/ -type f -delete;
find $fetch/inbox/tmp/ -type f -delete;

ssl=$ssl;
if [ "$ssl" = "1" ];
then
xTYPEx="SimpleIMAPSSLRetriever";
xPORTx="993";
else
xTYPEx="SimpleIMAPRetriever";
xPORTx="143";
fi

xSERVERx="$imapserver";
xUSERx="$username";
xPASSWORDx="$password";
xSPAMFOLDERx="$spamfolder";
xHAMFOLDERx="$legitimatefolder";

case $1 in
inbox )

#####
##### cleanup INBOX
#####
test -f $run/fetch_inbox.pid && exit 1;
echo $$ > $run/fetch_inbox.pid
cat <<END > $fetch/inbox/collector.rc
[retriever]
type = $xTYPEx
server = $xSERVERx
port = $xPORTx
username = $xUSERx
password = $xPASSWORDx
mailboxes = ("Inbox",)

[destination]
type = Maildir
path = $fetch/inbox/

[options]
read_all = false
use_peek = false
delete = false
delete_after = 7
END
	chown amavis:amavis $fetch/inbox/collector.rc
	chmod +x $fetch/inbox/collector.rc
	# create collector script
	su - amavis -c "getmail --getmaildir=$fetch/inbox -r collector.rc"
	rm -f $fetch/inbox/collector.rc
	test -f $run/fetch.pid && rm -fr $run/fetch.pid;
	test -f $run/fetch_inbox.pid && rm $run/fetch_inbox.pid;
exit 0
;;


* )

#####
##### fetch and learn SPAM
#####
test -f $run/fetch_spam.pid && exit 1;
echo $$ > $run/fetch_spam.pid
cat << END > $fetch/bad/collector.rc
[retriever]
type = $xTYPEx
server = $xSERVERx
port = $xPORTx
username = $xUSERx
password = $xPASSWORDx
mailboxes = ("$xSPAMFOLDERx",)

[destination]
type = Maildir
path = $fetch/bad/

[options]
read_all = false
use_peek = false
delete = false
delete_after = 1
END
	chown amavis:amavis $fetch/bad/collector.rc
	chmod +x $fetch/bad/collector.rc
	
	# create collector script
	su - amavis -c "getmail --getmaildir=$fetch/bad -r collector.rc"
	rm -f $fetch/bad/collector.rc
	test -f $run/fetch_spam.pid && rm $run/fetch_spam.pid;
		# learn SPAM
		learn=spam;
		find $fetch/bad/new -type f |\
		while read file
		do
		if [ -e $file ]
	then
	test -f $run/fetch_learn.pid && exit 1;
	echo $$ > $run/fetch_learn.pid
		test -f $file && (su - amavis -c "sa-learn --no-sync --showdots --spam $file")
		test -f $file && (su - amavis -c "spamassassin -R < $file > /dev/null 2>&1" )
		test -f $file && (su - amavis -c "spamassassin -r < $file > /dev/null 2>&1")
		# [ -f $file -a "$rspam" == "1" ] && (spamassassin -tp /var/www/cfg/report.spam < $file > /dev/null 2>&1)
		test -f $file && . $extract;
		[ "$from_domain" != "$empty" ] && (su - amavis -c "spamassassin --remove-addr-from-whitelist=*@$from_domain")
		[ "$from_domain0" != "$empty" ] && (su - amavis -c "spamassassin --remove-addr-from-whitelist=*@$from_domain0")
		[ "$from" != "$empty" ] && (su - amavis -c "spamassassin --remove-addr-from-whitelist=$from")
		[ "$from0" != "$empty" ] && (su - amavis -c "spamassassin --remove-addr-from-whitelist=$from0")
		[ "$from" != "$empty" ] && (su - amavis -c "spamassassin --add-addr-to-blacklist=$from")
		[ "$from0" != "$empty" ] && (su - amavis -c "spamassassin --add-addr-to-blacklist=$from0")
		test -f $file && rm -f $file
		test -f $run/fetch_learn.pid && rm $run/fetch_learn.pid;
		fi
		done;


#####
##### fetch and learn HAM
#####
test -f $run/fetch_ham.pid && exit 1;
echo $$ > $run/fetch_ham.pid
cat << END > $fetch/good/collector.rc
[retriever]
type = $xTYPEx
server = $xSERVERx
port = $xPORTx
username = $xUSERx
password = $xPASSWORDx
mailboxes = ("$xHAMFOLDERx",)
[destination]
type = Maildir
path = $fetch/good/

[options]
read_all = false
use_peek = false
delete = false
delete_after = 1
END
	chown amavis:amavis $fetch/good/collector.rc
	chmod +x $fetch/good/collector.rc

	# create collector script
	su - amavis -c "getmail --getmaildir=$fetch/good -r collector.rc"
	rm -f $fetch/good/collector.rc
	test -f $run/fetch_ham.pid && rm $run/fetch_ham.pid;
	# learn HAM
	learn=ham;
	find $fetch/good/new -type f |\
	while read file
	do
	if [ -e $file ]
	then
		resend=$resend;
		if [ "$resend" = "1" ];
		then
			test -f $file && (sendmail -f `grep -m1 "From: " $file | awk -F " " '{print $NF}' | sed "s/<\|>//g"` -t < $file)
		fi
		test -f $run/fetch_learn.pid && exit 1;
		echo $$ > $run/fetch_learn.pid;
	test -f $file && (su - amavis -c "sa-learn --no-sync --showdots --ham $file")
	test -f $file && (su - amavis -c "spamassassin -W < $file > /dev/null 2>&1")
	test -f $file && (su - amavis -c "spamassassin -k < $file > /dev/null 2>&1")
	# [ -f $file -a "$rspam" == "1" ] && (spamassassin -tp /var/www/cfg/report.ham < $file > /dev/null 2>&1)
	test -f $file && . $extract;
	[ "$from_domain" != "$empty" ] && (su - amavis -c "spamassassin --remove-addr-from-whitelist=*@$from_domain")
	[ "$from_domain0" != "$empty" ] && (su - amavis -c "spamassassin --remove-addr-from-whitelist=*@$from_domain0")
	[ "$from_domain" != "$empty" ] && (su - amavis -c "spamassassin --add-addr-to-whitelist=*@$from_domain")
	[ "$from_domain0" != "$empty" ] && (su - amavis -c "spamassassin --add-addr-to-whitelist=*@$from_domain0")
	test -f $file && rm -f $file
	test -f $run/fetch_learn.pid && rm $run/fetch_learn.pid;
	fi
	done;


	su - amavis -c "sa-learn --sync"
	test -f $run/fetch.pid && rm -fr $run/fetch.pid;
	
. /var/www/bin/signatures.sh
. /var/www/bin/iptrap.sh

;;
esac
	test -f $run/fetch.pid && rm -fr $run/fetch.pid;
exit 0;
