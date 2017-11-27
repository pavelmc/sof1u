

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

##################################################################################
# Modified by Pavel Milanes (pavel.mc@gmail.com) to work with Ubuntu 16.04.x LTS #
# Main changes are issues with (so far)
#  - PHP5 not being available on Ubuntu xenial: using PHP7
#  -
##################################################################################

# DO NOT MODIFY THIS CONFIGURATION FILE IN AN ATTEMPT TO INSTALL ON AN EXISTING SYSTEM.
# ATTEMPTING TO INSTALL SCROLLOUT ON AN EMAIL SERVER OR WEB SERVER WILL DISTROY YOUR CONFIGURATION FILES.
# INSTALL SCROLLOUT ON A FRESH OPERATING SYSTEM ONLY !!!

sudo apt-get install apt-transport-https -y --force-yes

rm -f /etc/apt/sources.list.d/*.list
test -f /etc/postsrsd.secret || openssl rand -base64 50 | fold -w30 | head -n1 > /etc/postsrsd.secret
test -d /usr/lib/postsrsd || mkdir -p /usr/lib/postsrsd;
cat << END > /etc/default/postsrsd
SRS_DOMAIN=$(postconf -h mydomain)
#SRS_EXCLUDE_DOMAINS=.example.com,example.org
#SRS_SEPARATOR==
SRS_SECRET=/etc/postsrsd.secret
SRS_FORWARD_PORT=10001
SRS_REVERSE_PORT=10002
RUN_AS=nobody
CHROOT=/usr/lib/postsrsd

END


sudo apt-get clean
sudo apt-get install debian-keyring debian-archive-keyring -y
sudo apt-get update || apt-get install sudo -y && sudo apt-get update;
sudo apt-get install libc-bin libc6 -y
sudo apt-get autoremove --purge apache2 -y
sudo apt-get autoremove resolvconf -y
sudo apt-get autoremove avahi-daemon -y
sudo apt-get autoremove samba -y
sudo apt-get autoremove rpcbind -y
sudo apt-get install arc -y
sudo apt-get install unattended-upgrades apt-listchanges -y
sudo apt-get install apache2-utils -y
sudo apt-get install altermime -y
sudo apt-get install arj -y
sudo apt-get install --only-upgrade bash -y
sudo apt-get install binutils -y
sudo apt-get install build-essential -y
sudo apt-get install bzip2 -y
sudo apt-get install ca-certificates -yq
sudo apt-get install cabextract -y
sudo apt-get install catdoc -y
sudo apt-get install cpio -y
sudo apt-get install clamav-daemon -y
sudo apt-get install clamav-freshclam -y
sudo apt-get install cryptsetup -y
sudo apt-get install dnsutils -y
sudo apt-get install dovecot-common -y
sudo apt-get install file -y
sudo apt-get install fail2ban -y
sudo apt-get install getmail4 -y
sudo apt-get install giflib-tools -y
sudo apt-get install gifsicle -y
sudo apt-get install gocr -y
sudo apt-get install gzip -y
sudo apt-get install gawk -y
sudo apt-get install imagemagick -y
sudo apt-get install rsyslog -y
sudo apt-get install inetutils-syslogd -y
sudo apt-get install incron -y
sudo apt-get install jlha-utils -y
sudo apt-get install libc-bin libc6 -y
sudo apt-get install libio-socket-ip-perl -y
sudo apt-get install libcompress-raw-zlib-perl -y
sudo apt-get install libgeo-ip-perl -y
sudo apt-get install libgeo-ipfree-perl -y
sudo apt-get install libencode-detect-perl -y
sudo apt-get install libdigest-sha-perl -y
sudo apt-get install libdbd-mysql-perl -y
sudo apt-get install libdbi-perl -y
sudo apt-get install libencode-detect-perl -y
sudo apt-get install libio-socket-inet6-perl -qy
sudo apt-get install libio-socket-ssl-perl -y
sudo apt-get install libmail-spf-perl -qy
sudo apt-get install libnet-patricia-perl -y
sudo apt-get install libmldbm-sync-perl -y
sudo apt-get install libnet-dns-perl -y
sudo apt-get install libnet-ident-perl -y
sudo apt-get install libstring-approx-perl -y
sudo apt-get install libtie-cache-perl -qy
sudo apt-get install lockfile-progs -y
sudo apt-get install lvm2 -y
sudo apt-get install lzop -y
sudo apt-get install lzma -y
sudo apt-get install lrzip -y
sudo apt-get install liblz4-tool -y
sudo apt-get install melt -y
sudo apt-get install mpack -y
sudo apt-get install netpbm -y
sudo apt-get install nomarch -y
sudo apt-get install ntpdate -y
sudo apt-get install ocrad -y
sudo apt-get install openssl -y
sudo apt-get install openssh-server -y
sudo apt-get install pciutils -y
sudo apt-get install p7zip-full -y
sudo apt-get install p7zip -y
sudo apt-get install pax -y
sudo apt-get install poppler-utils -y
sudo apt-get install pyzor -y
sudo apt-get install python-pip -y
sudo apt-get install redis-server -y
sudo pip install --upgrade pyzor
sudo pip install redis
sudo apt-get install bind9 -y
sudo apt-get install quagga -y
sudo apt-get install parallel -y
# update for Ubuntu Xenial
#sudo apt-get install php5-fpm -y
sudo apt-get install php-fpm -y
sudo apt-get install host -y
sudo apt-get install telnet -y
sudo apt-get install pflogsumm -y
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install rbldnsd -yq
sudo apt-get install razor -y
sudo apt-get install ripole -y
sudo apt-get install rpm -y
sudo apt-get install rrdtool -y
sudo apt-get install rsync -y
sudo apt-get install sharutils -y
sudo apt-get install strongswan -y
sudo apt-get install libstrongswan-extra-plugins -y
sudo apt-get install libstrongswan-standard-plugins -y
sudo apt-get install libcharon-extra-plugins -y
sudo apt-get install sysstat -y
sudo apt-get install libsasl2-2 libsasl2-modules -y
sudo apt-get install spamassassin -y
sudo apt-get install tesseract-ocr -y
sudo apt-get install tnef -y
sudo apt-get install unar -y
sudo apt-get install unp -y
sudo apt-get install unrar-free -y
sudo apt-get install unace -y
sudo apt-get install unzip -y
sudo apt-get install fcgiwrap -y
sudo apt-get install xzdec -y
sudo apt-get install zip -y
sudo apt-get install zoo -y
sudo apt-get install xtables-addons-common -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install amavisd-new -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install clamav-daemon -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx-extras -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install mailgraph -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install ntpdate -y
# update for Ubuntu Xenial
#sudo DEBIAN_FRONTEND=noninteractive apt-get install php5 -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install php -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install postfix -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install smbfs -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install cifs-utils -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install tzdata -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install postfix-ldap -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install postfix-pcre -y
sudo apt-get install postfix-policyd-spf-python -y
sudo apt-get install postsrsd -y
sudo dpkg -i /tmp/scrolloutf1/www/cfg/geo/libip-country-perl_2.27-1_all.deb
sudo apt-get install libtext-csv-xs-perl -y
sudo sa-update -D

sudo adduser clamav amavis
sudo adduser amavis clamav

rm /usr/bin/pyzor
rm /usr/bin/pyzord
ln -s /usr/local/bin/pyzor /usr/bin/pyzor
ln -s /usr/local/bin/pyzord /usr/bin/pyzord

mkdir -p /var/lib/.pyzor/
mkdir -p /var/lib/amavis/.pyzor/

cat <<END> /var/lib/.pyzor/config
[server]
Engine = redis
DigestDB = localhost,6379,,10

[client]
ReportThreshold = 0
WhitelistThreshold = 0

END

cat <<END> /var/lib/amavis/.pyzor/config
[client]
ReportThreshold = 0
WhitelistThreshold = 0

END

cat <<END> /var/lib/.pyzor/pyzord.access
check whitelist report ping pong info : anonymous : allow
END

test -f /var/lib/.pyzor/pyzord.pid && kill -9 $(cat /var/lib/.pyzor/pyzord.pid) && rm /var/lib/.pyzor/pyzord.pid
test -f /var/lib/.pyzor/pyzord.pid || pyzord --detach /dev/null --homedir=/var/lib/.pyzor/ -a 127.0.0.1 --cleanup-age=2592000

cat <<END> /var/lib/amavis/.pyzor/servers
127.0.0.1:24441
pyzor.scrolloutf1.com:24441
public.pyzor.org:24441
END

test -f /var/spool/disclaimers || mkdir -p /var/spool/disclaimers;
test -f /var/spool/filter || mkdir -p /var/spool/filter;

cat <<END> /var/spool/filter/servers
127.0.0.1:24441
pyzor.scrolloutf1.com:24441
# public.pyzor.org:24441
END

chown -R nobody /var/spool/disclaimers
chown -R nobody /var/spool/filter

ln -sf /tmp/scrolloutf1/www/ /tmp/www;
cp /tmp/scrolloutf1/www /var/ -r
ln -sf /etc/amavis /var/www/amavis
ln -sf /var/log /var/www/log
ln -sf /etc/postfix /var/www/postfix
ln -sf /etc/mail/spamassassin /var/www/spamassassin
ln -sf /var/log/mail.log /var/www/mail.log

echo "root" >> /etc/incron.allow

cd /usr/src/
cp /var/www/cfg/geo/fuzzyocr-3.5.1-devel.tar.gz /usr/src/
tar xvfz fuzzyocr-3.5.1-devel.tar.gz
cd FuzzyOcr-3.5.1/
mv FuzzyOcr* /etc/mail/spamassassin/

echo "SHELL=/bin/bash" > /var/spool/cron/crontabs/root
echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >> /var/spool/cron/crontabs/root
echo "*/3 * * * * /usr/bin/nice -n 19 /var/www/bin/fetch.sh > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "*/59 * * * * /usr/bin/nice -n 19 /var/www/bin/fetch.sh inbox > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "*/7 * * * * /usr/bin/nice -n 19 /var/www/bin/fetch.sh queue > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 0 1 1 * logrotate -f /etc/logrotate.d/rsyslog" >> /var/spool/cron/crontabs/root
echo "0 1 1 1 * /etc/init.d/mailgraph restart > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 */1 * * * chown www-data /var/log/mail.log > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 */1 * * * /var/www/bin/dns.sh > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo '# 0 23 * * * [[ `find /var/lib/amavis/.spamassassin/bayes_{seen,toks} -type f -size +40M` ]] && /usr/bin/nice -n 10 su - amavis -c "sa-learn --force-expire" > /dev/null 2>&1' >> /var/spool/cron/crontabs/root
echo "@reboot /var/www/bin/scrollout.sh traffic > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 1 * * * /usr/bin/nice -n 19 find /var/lib/amavis/virusmails/ -mtime +30 -delete > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 1 * * * /usr/bin/nice -n 19 find /var/lib/amavis/tmp/ -mtime +30 -delete > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 2 * * * /usr/bin/nice -n 19 find /backup/scrolloutf1* -type f -mtime +180 -delete > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 3 * * * /usr/bin/nice -n 19 find /var/log/mail.* -type f -mtime +365 -delete > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 4 * * * /usr/bin/nice -n 19 find /var/www/fetch/ -type f -mtime +7 -delete > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
echo "0 23 * * 5 /usr/bin/nice -n 19 tar -zcvf /backup/scrolloutf1.weekly.tar.gz /var/www --exclude="fetch" > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
sed -i "/sa-clean/d" /etc/cron.d/amavisd-new

chmod 0600 /var/spool/cron/crontabs/root
chown root.crontab /var/spool/cron/crontabs/root

echo '#!/bin/bash' > /etc/cron.hourly/ntpdate
echo "ntpdate -u time.nist.gov time.windows.com ntp.ubuntu.com pool.ntp.org > /dev/null 2>&1" >> /etc/cron.hourly/ntpdate
chmod +x /etc/cron.hourly/ntpdate

test -f /var/lib/amavis/.spamassassin/auto-whitelist && rm /var/lib/amavis/.spamassassin/auto-whitelist > /dev/null 2>&1

echo '#!/bin/bash' > /etc/cron.hourly/scrolloutf1
echo "sa-update > /dev/null 2>&1" >> /etc/cron.hourly/scrolloutf1
echo "/etc/init.d/clamav-freshclam status > /dev/null 2>&1 || /etc/init.d/clamav-freshclam restart > /dev/null 2>&1" >> /etc/cron.hourly/scrolloutf1
echo "freshclam > /dev/null 2>&1" >> /etc/cron.hourly/scrolloutf1
echo "/etc/init.d/clamav-daemon status > /dev/null 2>&1 || /etc/init.d/clamav-daemon restart > /dev/null 2>&1" >> /etc/cron.hourly/scrolloutf1
echo "/var/www/bin/update.sh  > /dev/null 2>&1" >> /etc/cron.hourly/scrolloutf1
chmod +x /etc/cron.hourly/scrolloutf1


rm -fr /etc/cron.daily/scrolloutf1
rm -fr /etc/cron.daily/clamav
/etc/init.d/cron restart

cp -p /var/www/cgi-bin/mailgraph.cgi /usr/lib/cgi-bin/mailgraph.cgi

test -d /etc/postfix/certs || mkdir /etc/postfix/certs;
test -d /etc/dovecot/private || mkdir /etc/dovecot/private
[[ -f /etc/dovecot/private/dovecot.pem ]] || openssl req -new -sha384 -newkey rsa:4096 -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -out /etc/dovecot/dovecot.pem -keyout /etc/dovecot/private/dovecot.pem
[[ -f /etc/dovecot/dovecot.pem ]] || openssl req -new -sha384 -newkey rsa:4096 -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -out /etc/dovecot/dovecot.pem -keyout /etc/dovecot/private/dovecot.pem
[[ -f /etc/postfix/certs/scrollout.cert ]] || (openssl req -new -sha384 -newkey rsa:4096 -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -keyout /etc/postfix/certs/scrollout.key  -out /etc/postfix/certs/scrollout.cert && cp /etc/postfix/certs/scrollout.cert /usr/share/ca-certificates/)
[[ -f /etc/postfix/certs/scrollout-dsa.cert ]] || (openssl req -new -newkey dsa:<(openssl dsaparam 4096) -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -keyout /etc/postfix/certs/scrollout-dsa.key  -out /etc/postfix/certs/scrollout-dsa.cert && cp /etc/postfix/certs/scrollout-dsa.cert /usr/share/ca-certificates/)
[[ -f /etc/postfix/certs/scrollout-ecdsa.cert ]] || (openssl req -new -sha384 -newkey ec:<(openssl ecparam -name secp384r1) -days 1000 -nodes -x509 -subj "/O=${organization[*]}/CN=$hostname.$domain" -keyout /etc/postfix/certs/scrollout-ecdsa.key  -out /etc/postfix/certs/scrollout-ecdsa.cert && cp /etc/postfix/certs/scrollout-ecdsa.cert /usr/share/ca-certificates/)
test -f /etc/postfix/certs/dh_512.pem || openssl dhparam -out /etc/postfix/certs/dh_512.pem 512
test -f /etc/postfix/certs/dh_1024.pem || openssl dhparam -out /etc/postfix/certs/dh_1024.pem 1024
test -f /etc/postfix/certs/dh_2048.pem || openssl dhparam -out /etc/postfix/certs/dh_2048.pem 2048
test -f /etc/postfix/certs/scrollout-ecdsa.cert && chown root.www-data /etc/postfix/certs/scrollout*.{key,cert}
test -f /etc/postfix/certs/scrollout.key && chmod 664 /etc/postfix/certs/scrollout*.{key,cert}
update-ca-certificates

rm -fr /etc/nginx/sites-{available,enabled}/*default*
cp /var/www/cfg/scrollout.conf /etc/nginx/sites-available
cp /var/www/cfg/fcgiwrap.conf /etc/nginx/conf.d
test -L /etc/nginx/sites-enabled/scrollout.conf || ln -s /etc/nginx/sites-available/scrollout.conf /etc/nginx/sites-enabled/

### Automatically install Jitsi-Meet
#cat << END | debconf-set-selections
# jitsi-videobridge       jitsi-videobridge/jvb-hostname  string $(hostname -f)
# jitsi-meet              jitsi-meet/cert-choice          select Self-signed certificate will be generated
# jitsi-meet              jitsi-meet/jvb-serve            boolean false
# jitsi-meet              jitsi-meet/jvb-hostname         string $(hostname -f)
# jigasi                                        jigasi/sip-password                             password $(openssl rand -base64 20 | fold -w10 | head -n1)
# jigasi                                        jigasi/sip-account                              string  number@sip.provider

# END

# sudo apt-get install jitsi-meet jigasi -qy

let disksize=`df | awk '/\/$/ {print $2}' | head -1`/1024/4;
sed -i -e "s/.*auth_worker_max_count = .*/auth_worker_max_count = 300/" /etc/dovecot/conf.d/10-auth.conf;
# update for Ubuntu Xenial
#~ sed -i "s/.*short_open_tag .*/short_open_tag = On/" /etc/php5/fpm/php.ini
#~ sed -i "s/.*max_input_vars .*/max_input_vars = 25000/" /etc/php5/fpm/php.ini
#~ sed -i "s/.*max_execution_time .*/max_execution_time = 300/" /etc/php5/fpm/php.ini
#~ sed -i "s/.*memory_limit .*/memory_limit = 128M/" /etc/php5/fpm/php.ini
#~ sed -i "s/.*suhosin.post.max_vars .*/suhosin.post.max_vars = 25000/" /etc/php5/fpm/php.ini
#~ sed -i "s/.*suhosin.request.max_vars .*/suhosin.request.max_vars = 25000/" /etc/php5/fpm/php.ini
sed -i "s/.*short_open_tag .*/short_open_tag = On/" /etc/php/7.0/fpm/php.ini
sed -i "s/.*max_input_vars .*/max_input_vars = 25000/" /etc/php/7.0/fpm/php.ini
sed -i "s/.*max_execution_time .*/max_execution_time = 300/" /etc/php/7.0/fpm/php.ini
sed -i "s/.*memory_limit .*/memory_limit = 128M/" /etc/php/7.0/fpm/php.ini
sed -i "s/.*suhosin.post.max_vars .*/suhosin.post.max_vars = 25000/" /etc/php/7.0/fpm/php.ini
sed -i "s/.*suhosin.request.max_vars .*/suhosin.request.max_vars = 25000/" /etc/php/7.0/fpm/php.ini
cp /var/www/cfg/incrontab /var/spool/incron/root
cp /var/www/cfg/geo/URICountry.pm /usr/share/perl5/Mail/SpamAssassin/Plugin
cp /var/www/cfg/quagga_daemons.conf /etc/quagga/daemons
cp /var/www/cfg/quagga_bgpd.conf /etc/quagga/bgpd.conf
cp /var/www/cfg/quagga_ospfd.conf /etc/quagga/ospfd.conf
cp /var/www/cfg/quagga_ospf6d.conf /etc/quagga/ospf6d.conf
cp /var/www/cfg/quagga_zebra.conf /etc/quagga/zebra.conf

passw=`tr -cd "a-zA-Z0-9\-=_" < /dev/urandom | fold -w35 | head -n1`
sed -i "s/password .*/password ${passw}/g" /etc/quagga/*.conf

/var/www/bin/fixfuzzy.sh
/var/www/bin/rbldnsd.sh create
cp /var/www/cfg/incron /etc/cron.daily
cp -p $target/scrolloutf1/www/cfg/mailgraph /etc/default/mailgraph && /etc/init.d/mailgraph restart

test -f /etc/sudores && rm -f /etc/sudores;
cat /etc/sudoers | grep -v "^User_Alias WWW " | grep -v "^www-data ALL=" | grep -v "^Cmnd_Alias SO =" | grep -v "^WWW ALL=NOPASSWD" > /tmp/sudoers.tmp
printf "User_Alias WWW = www-data\nCmnd_Alias SO = /sbin/ip, /usr/bin/awk, /sbin/ifconfig, /sbin/route, /usr/bin/tr, /var/www/bin/*.sh\nWWW ALL=NOPASSWD: SO\n" >> /tmp/sudoers.tmp && mv /tmp/sudoers.tmp /etc/sudoers;
chmod 0440 /etc/sudoers;

if grep -q "Debian GNU/Linux 7" /etc/issue; then
        test -f /etc/apt/sources.list.d/wheezy-backports.list || echo 'deb http://http.debian.net/debian wheezy-backports main' > /etc/apt/sources.list.d/wheezy-backports.list
        apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" postfix spamassassin clamav-daemon clamav-freshclam getmail4 fail2ban dovecot-common postfix-pcre postfix-ldap -t wheezy-backports
fi

if grep -q "Debian GNU/Linux 8" /etc/issue; then
        test -f /etc/apt/sources.list.d/jessie-backports.list || echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
        apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" postfix spamassassin amavisd-new clamav-daemon clamav-freshclam getmail4 fail2ban dovecot-common postfix-pcre postfix-ldap -t jessie-backports
fi

if grep -q "Debian GNU/Linux 9" /etc/issue; then
        test -f /etc/apt/sources.list.d/stretch-backports.list || echo 'deb http://http.debian.net/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports.list
        apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" postfix spamassassin amavisd-new clamav-daemon clamav-freshclam getmail4 fail2ban dovecot-common postfix-pcre postfix-ldap -t stretch-backports
fi

postconf -d | grep "^mail_version = 2.[8-9].[0-9]$" && apt-get autoremove postgrey -y

test -f /var/www/spamassassin/v320.pre && sed -i -e "s/^loadplugin Mail::SpamAssassin::Plugin::Rule2XSBody/# loadplugin Mail::SpamAssassin::Plugin::Rule2XSBody/" /var/www/spamassassin/v320.pre;
test -f /var/www/spamassassin/sa-compile.pre && sed -i -e "s/^loadplugin Mail::SpamAssassin::Plugin::Rule2XSBody/# loadplugin Mail::SpamAssassin::Plugin::Rule2XSBody/" /var/www/spamassassin/sa-compile.pre;
test -f /var/www/spamassassin/v320.pre && sed -i -e "s/^loadplugin Mail::SpamAssassin::Plugin::Shortcircuit/# loadplugin Mail::SpamAssassin::Plugin::Shortcircuit/" /var/www/spamassassin/v320.pre
test -d /var/lib/spamassassin/compiled && rm -fr /var/lib/spamassassin/compiled

cp /var/www/cfg/geo/*.gif `perl -MIP::Country::Fast -e '$_=$INC{"IP/Country/Fast.pm"};s/\.pm/\n/;print';`

test -f /var/www/ver || date +%F > /var/www/ver;
test -f /etc/postfix/sndr || echo "" > /etc/postfix/sndr;
test -e /etc/cron.daily/amavisd-new && (mv /etc/cron.daily/amavisd-new /etc/cron.weekly/)

sudo find /var/www -type d -exec chmod 755 {} \;
sudo find /var/www -type f -exec chmod 644 {} \;
chown www-data /var/www/*;
chown www-data /var/www/cfg/sndr;
chown www-data /var/www/postfix/sndr;
chown www-data /var/www/spamassassin/20_wb.cf;
chown www-data /var/www/.htpasswd;
chown nobody /var/www/bin/spawn.sh
chown nobody /var/www/bin/policy.sh
chown nobody /var/www/bin/smtp_tls_policy.sh
if [[ `grep "Ubuntu " /etc/issue` ]];
then
chmod 644 /var/log/mail.log
chown syslog.adm /var/log/mail.log
else
chmod 644 /var/log/mail.log
chown root.adm /var/log/mail.log
fi
chmod 644 /var/www/*.cfg
chmod 755 /var/www/cgi-bin/*
chmod 755 /var/www/bin/*
chmod -R 775 /var/lib/amavis/tmp


amavisu=`id -u amavis`
amavisg=`id -g amavis`

# memory=`free -m | grep "^Mem" | awk -F " " '{print $4}'`
# [ $memory -ge 1536 ] && (let mem=$memory/2; grep "/var/lib/amavis/tmp" /etc/fstab || echo "/dev/shm           /var/lib/amavis/tmp tmpfs defaults,noexec,nodev,nosuid,size="$mem"m,mode=750,uid=$amavisu,gid=$amavisg 0 0" >> /etc/fstab)

grep "swapfile.img swap" /etc/fstab > /dev/null || (
dd if=/dev/zero of=/swapfile.img bs=1024 count=1M
mkswap /swapfile.img
swapon /swapfile.img
echo "/swapfile.img swap swap sw 0 0" >> /etc/fstab
)

/etc/init.d/nginx restart
# update for Ubuntu Xenial
#/etc/init.d/php5-fpm restart
/etc/init.d/php7.0-fpm restart

localip=`ifconfig | grep -m1 "inet .* Bcast.* Mask" | sed "s/.*addr:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *B.*/\1/"`;
/etc/init.d/incron restart;
# sed -i -e "s/rotate [1-9]\{1\}$/rotate 52\n\tsize 10M/" /etc/logrotate.d/rsyslog
clear;

printf "\nConnect to http://$localip/ using any web browser"
printf "\nUser: Admin"
printf "\nPass: 123456 (It is CRITICAL to change it with a new complex password)"
printf "\nSupport & feedback: marius.gologan@gmail.com\n"
