#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################



. /var/www/bin/config.sh

test -f $run/runcountries.pid && kill -9 $(cat $run/runcountries.pid) && rm -f $run/runcountries.pid;
echo $$ > $run/runcountries.pid

. $bin/merge_countries.sh

case $1 in
	tld)
	test -f $run/updatetld.pid && kill -9 $(cat $run/updatetld.pid) && rm -f $run/updatetld.pid
	. $bin/updatetld.sh
	test -f $run/injectcidr.pid && kill -9 $(cat $run/injectcidr.pid) && rm -f $run/inejectcidr.pid
	. $bin/injectcidr.sh
	;;

	reload)
	test -f $run/updatetld.pid && kill -9 $(cat $run/updatetld.pid) && rm -f $run/updatetld.pid
	. $bin/updatetld.sh
	test -f $run/injectcidr.pid && kill -9 $(cat $run/injectcidr.pid) && rm -f $run/inejectcidr.pid
	. $bin/injectcidr.sh
	;;
esac;

rm -f $run/runcountries.pid

. $reload;
