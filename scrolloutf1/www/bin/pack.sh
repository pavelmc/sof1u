#!/bin/bash

rm -r /tmp/www;
rm -r /tmp/scrolloutf1.tar;
cp -r ../../www/ /tmp/www/;
echo > /tmp/www/cfg/10_wb.cf;
echo > /tmp/www/cfg/20_wb.cf;
echo > /tmp/www/cfg/sndr;
echo > /tmp/www/cfg/iptrap;
date +%F > /tmp/www/ver;
cd /tmp
tar -cvf scrolloutf1.tar www/;
rm -r /tmp/www;
