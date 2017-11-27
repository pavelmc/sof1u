
rm -fr /etc/mail/spamassassin/FuzzyOcr;
cp -r /var/www/cfg/fuzzy/FuzzyOcr* /etc/mail/spamassassin/;


# apt-get install subversion -y
# cd /usr/local/src
# test -e FuzzyOcr-3.5.1 && mv FuzzyOcr-3.5.1 FuzzyOcr-3.5.1-old
# test -e devel && mv devel devel-old
# svn -r 131 co https://svn.own-hero.net/fuzzyocr/trunk/devel
# mv devel FuzzyOcr-3.5.1
# cd FuzzyOcr-3.5.1
# wget http://www200.pair.com/mecham/spam/FuzzyOcr-3.5.0-rc1.netpbm_less_than_10.34.patch
# wget http://www200.pair.com/mecham/spam/FuzzyOcr-3.5.0-rc1.netpbm_less_than_10.34.patch2
# wget http://www200.pair.com/mecham/spam/FuzzyOcr-3.5.0-rc1.netpbm_less_than_10.34.patch3
# apt-get install patch -y
# patch -p0 < FuzzyOcr-3.5.0-rc1.netpbm_less_than_10.34.patch
# patch -p0 < FuzzyOcr-3.5.0-rc1.netpbm_less_than_10.34.patch2
# patch -p0 < FuzzyOcr-3.5.0-rc1.netpbm_less_than_10.34.patch3
# which pamtopnm
# which pamditherbw
# wget http://www200.pair.com/mecham/spam/gary.3.5.0-rc1.old.netpbm.patch1
# wget http://www200.pair.com/mecham/spam/gary.3.5.0-rc1.old.netpbm.patch2
# wget http://www200.pair.com/mecham/spam/gary.3.5.0-rc1.old.netpbm.patch3
# patch -p0 < gary.3.5.0-rc1.old.netpbm.patch1
# patch -p0 < gary.3.5.0-rc1.old.netpbm.patch2
# patch -p0 < gary.3.5.0-rc1.old.netpbm.patch3
# cp -r FuzzyOcr /etc/mail/spamassassin
# cp FuzzyOcr.cf /etc/mail/spamassassin
# cp FuzzyOcr.pm /etc/mail/spamassassin
# cp FuzzyOcr.preps /etc/mail/spamassassin
# cp FuzzyOcr.scansets /etc/mail/spamassassin

