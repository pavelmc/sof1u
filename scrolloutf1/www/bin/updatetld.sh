#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################



test -f $run/updatetld.pid && kill -9 $(cat $run/updatetld.pid) && rm -f $run/updatetld.pid;
echo $$ > $run/updatetld.pid


rm -f $tmp/tldscore*.tmp
rm -f $tmp/dottld*.tmp

echo "" > $dottld;

test -f $tmp/dottld$$.tmp || touch $tmp/dottld$$.tmp;

echo "$URI_TLD" | sed "s/;$//g"  | sort | grep -v "^$" |\
while read record
do
	score=`echo "$record" | cut -d "," -f3`
	if ! [ $score = 0 ]
	then
		if [ $score = 1 ]
		then
		score=$greyscore;
		tld=`echo "$record" | cut -d "," -f2 | sed 's/^ //'`
		country=`echo "$record" | cut -d "," -f1 | sed 's/^ //'`
		printf "\n### $country" >> $tmp/tldscore$$.tmp
		printf "\n$tldtemplate\n" | sed "s/xTLDx/$tld/g" | sed "s/xSCOREx/$score/" |\
		sed "s/xCOUNTRY_NAMEx/$country/" | sed "s/xMESSx/Foreign area/" >> $tmp/tldscore$$.tmp
		else
		score=$blackscore;
		tld=`echo "$record" | cut -d "," -f2 | sed 's/^ //'`
		country=`echo "$record" | cut -d "," -f1 | sed 's/^ //'`
		printf "\n### $country" >> $tmp/tldscore$$.tmp
		printf "\n$tldtemplate\n" | sed "s/xTLDx/$tld/g" | sed "s/xSCOREx/$score/" |\
		sed "s/xCOUNTRY_NAMEx/$country/" | sed "s/xMESSx/Out of area/" >> $tmp/tldscore$$.tmp
		[[ $Geographic_filter -lt 4 ]] && printf "\n### $country" >> $tmp/dottld$$.tmp
		[[ $Geographic_filter -lt 4 ]] && printf "\n/\.$tld\$/\t$dottlds_code\n" >> $tmp/dottld$$.tmp
		fi;
	fi;
done
mv $tmp/dottld$$.tmp $dottld;
printf "\n	add_header all Relay-Country _RELAYCOUNTRY_\n\n\n" >> $tmp/tldscore$$.tmp && mv $tmp/tldscore$$.tmp $tldscore;
load_uri="loadplugin Mail::SpamAssassin::Plugin::URICountry";

test -f $tmp/local.cf$$.tmp && rm -f $tmp/local.cf$$.tmp
printf "\n$load_uri\n" > $tmp/local.cf$$.tmp
cat $tldscore >> $tmp/local.cf$$.tmp && rm -f $tldscore;
cat $localcf >> $tmp/local.cf$$.tmp
printf "\n$param_sa" >> $tmp/local.cf$$.tmp
mv $tmp/local.cf$$.tmp $sp_library/local.cf

rm -f $run/updatetld.pid
