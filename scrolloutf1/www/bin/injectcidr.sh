#!/bin/bash


#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################


test -f $run/injectcidr.pid && kill -9 $(cat $run/inejectcidr.pid) && rm -f $run/inejectcidr.pid;
echo $$ > $run/injectcidr.pid
echo "" > $clientcidr;

rm -f $tmp/clientcidr*.tmp
test -f $tmp/clientcidr$$.tmp || touch $tmp/clientcidr$$.tmp;

if [ $Geographic_filter -le 5 ]
then

echo "$IP_TLD" | cut -d "," -f3,4 | sed "s/;//g" | sort | grep -vE "^$|^0|^1" |\

while read line
do
permission=`echo "$line" | awk  -F "," '{print $1}' | sed "s/^2/$cidr_client_code/"`
# permission=`echo "$line" | awk  -F "," '{print $1}' | sed "s/^0\|^1/OK/" | sed "s/^2/$cidr_client_code/"`
country=`echo "$line" | awk -F "," '{print $2}'`

	# Create 1 unique cidr file
	printf "\n\n###			 $country				$permission\n" >> $tmp/clientcidr$$.tmp;
	cat $cidr/$country | grep -viE "[a-z]|^$" | grep "\/[0-9]\{2\}$" |\
		while read cidraddress
		do
		printf "\n$cidraddress		  $permission" >> $tmp/clientcidr$$.tmp;
		done;
done;

	mv $tmp/clientcidr$$.tmp $clientcidr;

else

	mv $tmp/clientcidr$$.tmp $clientcidr;

fi;

rm -f $run/injectcidr.pid

