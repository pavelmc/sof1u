#!/bin/bash

# generate POSTSRSD file 

for ((dom=0; dom<=${#domain[*]}; dom++))
do
	# test if a srs exception exists and increment
	[ ! -z ${srs[$dom]} ] && SRS_EXCLUDE_DOMAINS="$SRS_EXCLUDE_DOMAINS ${domain[$dom]}"
done

SRS_EXCLUDE_DOMAINS=$(echo $SRS_EXCLUDE_DOMAINS | sed s"/ /,/g")


cat << END > /etc/default/postsrsd
SRS_DOMAIN=$(postconf -h mydomain)
$( [ ! -z $SRS_EXCLUDE_DOMAINS ] && echo "SRS_EXCLUDE_DOMAINS=$SRS_EXCLUDE_DOMAINS" || echo "# SRS_EXCLUDE_DOMAINS=$SRS_EXCLUDE_DOMAINS" )
#SRS_SEPARATOR==
SRS_SECRET=/etc/postsrsd.secret
SRS_FORWARD_PORT=10001
SRS_REVERSE_PORT=10002
RUN_AS=nobody
CHROOT=/usr/lib/postsrsd
END
