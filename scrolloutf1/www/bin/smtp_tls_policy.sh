#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

WRITELOG="logger -t postfix/smtp_tls_policy -i -p mail.info"
action="200 MAY";

while read line; do

if ! [[ -z $line ]]; then
		left=`echo "$line"	| awk '/^get / {print tolower($1)}'`
		right=`echo "$line"	| awk '/^get / {print tolower($2)}'`

	if [[ "$left" == "get" && ! -z $right ]]; then
		destination="$right";

get_data=$(cat <<END
get "stls:${destination}"
END
)

get_db=`cat <<END | redis-cli -n 5 | awk -F '>' '{print tolower($NF)}'
${get_data}
END`

		starttls=; starttls=`echo "${get_db}" | awk 'NR == 1'`
		[[ ${starttls} -eq 1 ]] && action="200 ENCRYPT"
		echo "$action"

	else

		echo "$action"

	fi


else
		action="200 MAY";
		echo "$action"
		exit $?
fi

done

exit $?

