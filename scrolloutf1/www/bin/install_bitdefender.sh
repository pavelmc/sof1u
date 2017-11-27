#!/bin/bash

case $1 in

install)
clear;

echo "Please answer "N" when you see this question:"
echo "Do you want to install BitDefender Antivirus Scanner GUI package ? (Y/n)"
echo "Type "N" and press Enter."

sleep 5;

clear;

# Download and install
cd /tmp/
wget http://download.bitdefender.com/SMB/Workstation_Security_and_Management/BitDefender_Antivirus_Scanner_for_Unices/Unix/Current/EN_FR_BR_RO/Linux/BitDefender-Antivirus-Scanner-7.7-1-linux-amd64.deb.run
test -f /tmp/BitDefender-Antivirus-Scanner-7.7-1-linux-amd64.deb.run && /bin/bash /tmp/BitDefender-Antivirus-Scanner-7.7-1-linux-amd64.deb.run


echo '#!/bin/bash' > /etc/cron.hourly/bdupdate
echo "bdscan --update > /dev/null 2>&1" >> /etc/cron.hourly/bdupdate
chmod +x /etc/cron.hourly/bdupdate && /etc/cron.hourly/bdupdate


sudo adduser bitdefender amavis
sudo adduser amavis bitdefender
/etc/init.d/amavis restart

touch /opt/BitDefender-scanner/var/lib/scan/Plugins/cache.000
chown bitdefender:bitdefender /opt/BitDefender-scanner/var/lib/scan/Plugins/cache.000


echo "Done!";
;;

uninstall)

cd /tmp/
wget http://download.bitdefender.com/SMB/Workstation_Security_and_Management/BitDefender_Antivirus_Scanner_for_Unices/Unix/Current/EN_FR_BR_RO/Linux/BitDefender-Antivirus-Scanner-7.7-1-linux-amd64.deb.run
test -f /tmp/BitDefender-Antivirus-Scanner-7.7-1-linux-amd64.deb.run && /bin/bash /tmp/BitDefender-Antivirus-Scanner-7.7-1-linux-amd64.deb.run --uninstall
test -f /etc/cron.hourly/bdupdate && rm /etc/cron.hourly/bdupdate

/etc/init.d/amavis restart

echo "Done!";
;;
esac

exit 0;