#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

empty=;

case $1 in
force ) rm -f /var/www/ver;
;;
esac

apt-get install sharutils  -y
dt=`date +%F.%R`;
target=/tmp/scrollout;
test -d $target || mkdir $target;
curver=/var/www/ver;
test -f $curver || echo "" > $curver;
lastver=`grep -m1 "-" $curver`;
test "$lastver"
# proceed with backup first
test -d /backup || mkdir /backup;
find /backup/scrolloutf1* -mtime +180 -delete;
find $target -type f -name "scrolloutf1.tar" -mmin +3 -delete;
if ! [ -f $target/scrolloutf1.tar ]; then
ver="http://sourceforge.net/projects/scrollout/files/update/version.txt/download";
link="http://sourceforge.net/projects/scrollout/files/update/scrolloutf1.tar/download";

# Backup link. Uncomment the next line
# link="http://www.scrolloutf1.com/download/scrolloutf1.tar";

wget "$ver" -O $target/ver;
newver=`grep -m1 "-" $target/ver`;
test "$newver" = "$empty" && exit 0;
test "$lastver" = "$newver" && exit 0;
rm -f $target/scrolloutf1.tar*;
wget "$link" -O $target/scrolloutf1.tar;
else
        echo "A package already exists and will be used instead of the on-line version: $target/scrolloutf1.tar"
fi

test -f $target/scrolloutf1.tar && tar -xvf $target/scrolloutf1.tar --directory=$target || exit;
tar --exclude="/var/www/log" --exclude="/var/www/mail.log" --exclude="/var/www/mail.log.1" -zcvhf /backup/scrolloutf1.$dt.tar.gz /var/www --exclude="/var/www/fetch";
chmod 755 $target/scrolloutf1/www/bin/*

test -f $target/scrolloutf1/www/bin/roll.sh && $target/scrolloutf1/www/bin/roll.sh;
rm -f $target/scrolloutf1.tar;
