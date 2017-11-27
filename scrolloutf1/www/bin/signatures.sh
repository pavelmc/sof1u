#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

. /var/www/ldp.cfg;



fileserver=$file_server;
share=$share;
domain=$user_domain;
username=$folder_username;
password=$folder_password;


cifs_path=//$fileserver/$share;

empty=
test "$fileserver" = "$empty" && exit 0;
test "$username" = "$empty" && exit 0;
test "$password" = "$empty" && exit 0;
test "$share" = "$empty" && exit 0;
test "$cifs_path" = "$empty" && exit 0;

lockfile-check /tmp/signatures.lock && exit 0 || lockfile-create /tmp/signatures.lock;




test -d /tmp/so-signatures || mkdir /tmp/so-signatures;
test -d /tmp/so-mount || mkdir /tmp/so-mount;
test -d /tmp/so-clamsig || mkdir /tmp/so-clamsig;


mpoint=/tmp/so-mount;
sig_files=/tmp/so-signatures;
clam_sig=/tmp/so-clamsig;
	rm -fR $sig_files/*;
	rm -fR $clam_sig/*;




umount $mpoint
mount -t cifs $cifs_path $mpoint/ -o username="$domain/$username",password="$password";

lock_folder="$mpoint/lock"
legit_folder="$mpoint/unlock"
expr_folder="$mpoint/expressions"
read_me="$mpoint/README.txt"
expr="/var/www/expressions.cfg"


test -d $lock_folder || mkdir $lock_folder;
test -d $legit_folder || mkdir $legit_folder;
test -d $expr_folder || mkdir $expr_folder;
test -f $expr || touch $expr;

test -f $read_me || printf "
Copy the files you want to block in LOCK folder. If the original file is modified, will pass through the system.
Copy the files you want to unblock in UNLOCK folder.

Create text file(s) in EXPRESSIONS folder.
Each line is an expression (one or more words or regex).
LiteDLP will verify the emails for all expressions mentioned in .txt files.
" | sed -e 's/$/\r/' > $read_me

content_file_list=`find $expr_folder -type f -name "*.txt"`;

test "$content_file_list" != "$empty" && (awk '{ sub("\r$", ""); print }' $expr_folder/*.txt | grep -vaE "^$|^ *$" | sed 's/\t/ /g' | sed 's/  */ /g' > $expr);

# test "$lock_folder" = "$empty" && lockfile-remove /tmp/signatures.lock && exit 0;
# test "$legit_folder" = "$empty" && lockfile-remove /tmp/signatures.lock && exit 0;

clam_hdb=/var/lib/clamav/so-md5.hdb;
clam_fp=/var/lib/clamav/so-md5.fp;

build_files()
{

	# Begin insert signature from LOCK folder (BLACKLIST)
	find $lock_folder -maxdepth 1 -type f | awk -F "/" '{print $NF}' |\
		while read file
		do
		md5_hash=`md5sum "$lock_folder/$file" | cut -d " " -f1`;
		size=`stat -c '%s' "$lock_folder/$file"`;
		echo "$md5_hash:$size:LiteDLP.$file" >> $clam_sig/so-md5.hdb.tmp;
		rm -f "$lock_folder/$file";
		done;

	test -e $clam_hdb || touch $clam_hdb;
	test -e $clam_sig/so-md5.hdb.tmp || touch $clam_sig/so-md5.hdb.tmp;

	cat $clam_hdb $clam_sig/so-md5.hdb.tmp | sort -u > $clam_sig/so-md5.hdb && rm -f $clam_sig/so-md5.hdb.tmp;

	# Begin insert signature from UNLOCK folder (WHITELIST)
	find $legit_folder -maxdepth 1 -type f | awk -F "/" '{print $NF}' |\
		while read file
		do
		md5_hash=`md5sum "$legit_folder/$file" | cut -d " " -f1`;
		size=`stat -c '%s' "$legit_folder/$file"`;
		echo "$md5_hash:$size:LiteDLP.$file" >> $clam_sig/so-md5.fp.tmp;
		 rm -f "$legit_folder/$file";
		done;

	test -e $clam_fp || touch $clam_fp;
	test -e $clam_sig/so-md5.fp.tmp || touch $clam_sig/so-md5.fp.tmp;

	cat $clam_fp $clam_sig/so-md5.fp.tmp | sort -u | grep -vi "thumbs" > $clam_sig/so-md5.fp && rm -f $clam_sig/so-md5.fp.tmp;
}


if [ "$(ls -A $lock_folder)" ]
then
	 
	build_files;

	elif [ "$(ls -A $legit_folder)" ]; then

	build_files;
	
else
	lockfile-remove /tmp/signatures.lock;
exit 0;
fi;

test -e $clam_sig/so-md5.hdb || touch $clam_sig/so-md5.hdb;
test -e $clam_sig/so-md5.fp || touch $clam_sig/so-md5.fp;
test -e $clam_sig/new_clam.hdb || touch $clam_sig/new_clam.hdb;
test -e $clam_sig/new_clam.fp || touch $clam_sig/new_clam.fp;

if [ -e $clam_sig/so-md5.hdb ] && [ -e $clam_sig/so-md5.fp ]; then
	grep -vnf $clam_sig/so-md5.fp $clam_sig/so-md5.hdb | cut -d ":" -f2- | grep -vi "thumbs" > $clam_sig/new_clam.hdb;
	grep -vnf $clam_sig/so-md5.hdb $clam_sig/so-md5.fp | cut -d ":" -f2- | grep -vi "thumbs" > $clam_sig/new_clam.fp;

	test -e $clam_sig/new_clam.hdb && (cat $clam_sig/new_clam.hdb | sort -u | grep -vi "thumbs" > $clam_hdb && chown clamav.clamav $clam_hdb);
	test -e $clam_sig/new_clam.fp && (cat $clam_sig/new_clam.fp | sort -u | grep -vi "thumbs" > $clam_fp && chown clamav.clamav $clam_fp);

	test -s $clam_hdb || rm -f $clam_hdb;
	test -s $clam_fp || rm -f $clam_fp;

	(test -e $clam_sig/new_clam.hdb || test -e $clam_sig/new_clam.fp) && /etc/init.d/clamav-daemon reload-database;

test -e $clam_sig/new_clam.hdb || rm $clam_sig/new_clam.hdb;
test -e $clam_sig/new_clam.fp || rm $clam_sig/new_clam.fp;
test -e $clam_sig/so-md5.hdb || rm $clam_sig/so-md5.hdb;
test -e $clam_sig/so-md5.fp || rm $clam_sig/so-md5.fp;

else
	lockfile-remove /tmp/signatures.lock;
	exit 0;
fi;

	lockfile-remove /tmp/signatures.lock;
	exit 0;