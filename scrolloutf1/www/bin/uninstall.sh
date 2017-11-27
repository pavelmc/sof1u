#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

function f_uninstall(){

sudo apt-get update || apt-get install sudo -y
sudo apt-get autoremove arc -y
sudo apt-get autoremove altermime -y
sudo apt-get autoremove arj -y
sudo apt-get autoremove binutils -y
sudo apt-get autoremove bzip2 -y
sudo apt-get autoremove cabextract -y
sudo apt-get autoremove catdoc -y
sudo apt-get autoremove cpio -y
sudo apt-get autoremove fail2ban -y
sudo apt-get autoremove file -y
sudo apt-get autoremove freeze -y
sudo apt-get autoremove fail2ban -y
sudo apt-get autoremove getmail4 -y
sudo apt-get autoremove giflib-tools -y
sudo apt-get autoremove gifsicle -y
sudo apt-get autoremove gocr -y
sudo apt-get autoremove gzip -y
sudo apt-get autoremove imagemagick -y
sudo apt-get autoremove incron -y
sudo apt-get autoremove jlha-utils -y
sudo apt-get autoremove libdbd-mysql-perl -y
sudo apt-get autoremove libdbi-perl -y
sudo apt-get autoremove libencode-detect-perl -y
sudo apt-get autoremove libio-socket-inet6-perl -qy
sudo apt-get autoremove libio-socket-ssl-perl -y
sudo apt-get autoremove libmail-spf-perl -qy
sudo apt-get autoremove libmail-spf-query-perl -y
sudo apt-get autoremove libmldbm-sync-perl -y
sudo apt-get autoremove libnet-dns-perl -y
sudo apt-get autoremove libnet-ident-perl -y
sudo apt-get autoremove libstring-approx-perl -y
sudo apt-get autoremove libtie-cache-perl -qy
sudo apt-get autoremove lockfile-progs -y
sudo apt-get autoremove lzop -y
sudo apt-get autoremove lzma -y
sudo apt-get autoremove melt -y
sudo apt-get autoremove mpack -y
sudo apt-get autoremove netpbm -y
sudo apt-get autoremove nomarch -y
sudo apt-get autoremove ntpdate -y
sudo apt-get autoremove ocrad -y
sudo apt-get autoremove openssl -y
sudo apt-get autoremove openssh-server -y
sudo apt-get autoremove p7zip-full -y
sudo apt-get autoremove p7zip -y
sudo apt-get autoremove pax -y
sudo apt-get autoremove poppler-utils -y
sudo apt-get autoremove ppthtml -y
sudo apt-get autoremove pyzor -y
sudo apt-get autoremove rar -y
sudo apt-get autoremove razor -y
sudo apt-get autoremove ripole -y
sudo apt-get autoremove rpm -y
sudo apt-get autoremove rrdtool -y
sudo apt-get autoremove sharutils -y
sudo apt-get autoremove spamassassin -y
sudo apt-get autoremove tesseract-ocr -y
sudo apt-get autoremove tnef -y
sudo apt-get autoremove unar -y
sudo apt-get autoremove unp -y
sudo apt-get autoremove unrar-free -y
sudo apt-get autoremove unrar -y
sudo apt-get autoremove unzip -y
sudo apt-get autoremove xzdec -y
sudo apt-get autoremove zip -y
sudo apt-get autoremove zoo -y
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge amavisd-new -y
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge clamav-daemon -y
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge apache2 -y
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge mailgraph -y
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge php5 -y
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge postfix -y
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge postgrey -y
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge smbfs -y
sudo apt-get autoremove libip-country-perl -y
apt-get autoclean -y



echo "REMOVE FILES"
rm -fr /var/www/collector.cfg
rm -fr /var/www/ldp.cfg
rm -fr /var/www/connection.php
rm -fr /var/www/ver
rm -fr /var/www/security.cfg
rm -fr /var/www/jQuery.js
rm -fr /var/www/menu.js
rm -fr /var/www/collector.php
rm -fr /var/www/spamtraps.csv
rm -fr /var/www/css/nav.css
rm -fr /var/www/css/style.css
rm -fr /var/www/countries.php
rm -fr /var/www/countries.cfg
rm -fr /var/www/filter.cfg
rm -fr /var/www/traffic.cfg
rm -fr /var/www/.htaccess
rm -fr /var/www/logsreload.php
rm -fr /var/www/f1logo.jpg
rm -fr /var/www/functions.js
rm -fr /var/www/.htpasswd
rm -fr /var/www/codes.php
rm -fr /var/www/security.php
rm -fr /var/www/logs.php
rm -fr /var/www/top.jpg
rm -fr /var/www/top.php
rm -fr /var/www/ldp.php
rm -fr /var/www/tooltips
rm -fr /var/www/pwd.php
rm -fr /var/www/index.html
rm -fr /var/www/footer.php
rm -fr /var/www/logo.jpg
rm -fr /var/www/jquery-latest.js
rm -fr /var/www/index.php
rm -fr /var/www/security.list
rm -fr /var/www/js
rm -fr /var/www/graph.php
rm -fr /var/www/codes.cfg
rm -fr /var/www/connection.cfg
rm -fr /var/www/traffic.php
rm -fr /var/www/css
rm -fr /var/www/dkim
rm -fr /var/www/tooltips
rm -fr /var/www/cgi-bin
rm -fr /var/www/fetch
rm -fr /var/www/cfg
rm -fr /var/www/cfg/geo
rm -fr /var/www/js
rm -fr /var/www/amavis
rm -fr /var/www/mail.log
rm -fr /var/www/spamass*
rm -fr /var/www/postfix
rm -fr /var/www/log
rm -fr /var/www/bin
clear && echo "done.";
}

clear;
printf "\n\
\n\n--------------------------------------   WARNING! -----------------------------------------\n\
All packages and configuration files, used by Scrollout F1, will be removed!\n\
(e.g.: Postfix, Postgrey Amavis, Apache, Clamav etc.)\n\
ARE YOU SURE YOU WANT TO CONTINUE?\n\
-------------------------------------------------------------------------------------------\n"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) f_uninstall && exit 0;;
		No ) exit;;
	esac
done