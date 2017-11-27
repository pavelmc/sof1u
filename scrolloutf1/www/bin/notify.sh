#!/bin/bash

empty=;
path=/var/www;
. $path/collector.cfg;
tmp=/tmp;
log_dir=/var/log;
log=$tmp/mail_log.zip;
test -e $log && rm -f $log;
today=`date +%Y-%m-%d`;

cd $log_dir;
zip -9 $log mail.log.1;

(echo "Subject: Backup mail log $today" && printf "\
\n\
Save & archive the attached log file before deleting this email!\n\
" && uuencode $log $today.zip) |\
sendmail -F "Scrollout F1 e-mail firewall" -f $mailbox $mailbox

/etc/init.d/incron restart;

exit 0;
