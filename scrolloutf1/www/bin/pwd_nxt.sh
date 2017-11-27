#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

. /var/www/traffic.cfg

test -d /var/www/postfix/pwd || mkdir /var/www/postfix/pwd;

case $1 in
create)
    i=0;
    grep "@" /etc/{shadow*,pass*,group*} > /dev/null >&1 && (sed -i -e "/@/d" /etc/{shadow*,pass*,group*});
	test -f /etc/dovecot/users && rm /etc/dovecot/users;
	test -f /etc/dovecot/users || touch /etc/dovecot/users;
    for ((i=0; i<${#domain[*]}; i++));do
    if [ ! -f /var/www/postfix/pwd/${domain[$i]}.pwd ]; then

	user=`echo "${domain[$i]}" | sed "s/[[:punct:]]//g"`
	# pass=`tr -cd "a-zA-Z0-9\-=_" < /dev/urandom | fold -w30 | head -n1`
	pass=$(openssl rand -base64 50 | fold -w30 | head -n1)
	test -f /var/www/postfix/pwd/${domain[$i]}.pwd || echo "$user@${domain[$i]},$pass" > /var/www/postfix/pwd/${domain[$i]}.pwd;
	test -f /var/www/postfix/pwd/${domain[$i]}.pwd && cat /var/www/postfix/pwd/${domain[$i]}.pwd |\

	    while read cred; do
	    user=`echo "$cred" | cut -d "@" -f1`
	    pass=`echo "$cred" | cut -d "," -f2`
	    test -f /etc/dovecot/users || touch /etc/dovecot/users;
	    if ! grep -q "${domain[$i]}" /etc/dovecot/users; then
		htpasswd -sb /etc/dovecot/users $user@${domain[$i]} $pass > /dev/null 2>&1;
		fi
	    done
else
	    test -f /var/www/postfix/pwd/${domain[$i]}.pwd && cat /var/www/postfix/pwd/${domain[$i]}.pwd |\
	    while read line; do
	    user=`echo "$line" | cut -d "@" -f1`
	    pass=`echo "$line" | cut -d "," -f2`
	    if ! grep -q "${domain[$i]}" /etc/dovecot/users; then
		htpasswd -sb /etc/dovecot/users $user@${domain[$i]} $pass > /dev/null 2>&1;
		fi
	    done
    fi;
    done
	
chmod 644 /var/www/postfix/pwd/*
chmod 644 /etc/dovecot/users

primary_user=`test -f /etc/postfix/pwd/${domain[0]}.pwd && awk 'BEGIN{FS="[,@]"} /@'${domain[0]}'/ {print $1"@"$2}' /etc/postfix/pwd/${domain[0]}.pwd`
awk 'BEGIN{FS="[,@]"}; /@/ {
if ($1"@"$2 != "'$primary_user'") {print "@"$2"\t"$1"@"$2", '$primary_user'"}
if ($1"@"$2 == "'$primary_user'") {print "@"$2"\t"$1"@"$2}
}' /etc/postfix/pwd/*.pwd > /etc/postfix/login_maps && postmap /etc/postfix/login_maps

exit
;;

list)
	test -f /var/www/postfix/pwd/$2.pwd && cat /var/www/postfix/pwd/$2.pwd |\
	    while read line; do
	    user=`echo "$line" | cut -d "," -f1`
	    pass=`echo "$line" | cut -d "," -f2`
	    echo '<div class="row"><div class="col-lg-12 col-md-12 col-sm-12 col-xs-12" style="font-size:18px;">User:</div><div class="col-lg-10 col-md-12 col-sm-12 col-xs-12">'
	    echo "<input class="form-control" name="$user"  id="$user" type="text" value="$user" readonly=\"readonly\" /></div></div>"
	    echo '<div class="row"><div class="col-lg-12 col-md-12 col-sm-12 col-xs-12" style="margin-top: 20px;font-size:18px;">Password:</div><div class="col-lg-10 col-md-12 col-sm-12 col-xs-12" style="margin-bottom: 20px;">'
	    echo "<input class="form-control" name="$pass"  id="$pass" type="text" value="$pass" readonly=\"readonly\" /></div></div>"
	    done
exit
;;
esac

exit

