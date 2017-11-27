path=`pwd`;
range=$path/range
cidr=$path/cidr
apt-get install ipcalc -y

for file in $(ls -l $range | awk '{print $NF}' | grep "[A-Z]")
do
cat "$range/$file" |\
    while read line
    do
    cidrline=`ipcalc $line | grep -vi [a-z] | grep "\/[0-9]\{1,2\}"`
    echo "$cidrline" >> $cidr/$file;
    done;
    sort -u $cidr/$file | grep -v "^$" > /tmp/$file.tmp
    mv /tmp/$file.tmp $cidr/$file
done

