#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

while read line; do

	if [[ `echo "$line" | grep -i "^get .*\@.*\..*"` ]]; then
	    domain=`echo "$line" | cut -d "@" -f2`
	    transport=`host $domain.ip.pools. localhost | awk '/has address/ {print "220 from_'"$domain"'_"$NF":";exit;}'`
	    [[ $transport != "" ]] && echo "$transport" || echo "220 smtp:"
	else
		echo "220 smtp:"
	fi
done
exit
