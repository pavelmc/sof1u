#!/bin/bash

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################


# sort the complet list of tlds
sort_tlds=`sort -t "," +1 -2 $alltlds | grep -vi "^$"`

# sort the list of countries name
sort_countries=`sort -u $countries | grep -vi "^$"`

# sort countries IP
sort_cc=`sort -t "," +1 -2 $countries_codes | grep -vi "^$"`

#filter countires setup
c_setup=`cat $setup | sed 's/"\"//g' | tr "_" " " | sort -u | tr "=" "," | grep -vi "^$"`

# join for URI URL TLD
URI_TLD=`join -t "," -1 2 -2 1 <(echo "$sort_tlds") <(echo "$c_setup") | sort -t "," +1 -1 | grep -vi "^$" `

# join for IPs
IP_TLD=`join -t "," -1 2 -2 1 <(echo "$URI_TLD") <(echo "$sort_cc")`

