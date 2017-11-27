#!/bin/bash

user=$2
bit=2048
crypt=rsa${bit}
host=`hostname -f`

case $1 in

# CREATE YOUR CERTIFICATION AUTHORITY (CA)

ca )
cd /etc/ipsec.d/
ipsec pki --gen --type rsa --size ${bit} --outform pem > private/caKey-${crypt}.pem
chmod 600 private/*.pem
ipsec pki --self --ca --lifetime 3650 --in private/caKey-${crypt}.pem --type rsa --dn "O=Scrollout, CN=Scrollout Root CA" --outform pem > cacerts/caCert-${crypt}.pem
;;

# CREATE YOUR VPN HOST CERTIFICATE

host )
cd /etc/ipsec.d/
ipsec pki --gen --type rsa --size ${bit} --outform pem > private/HostKey-$host-${crypt}.pem
chmod 600 private/*.pem
ipsec pki --pub --in private/HostKey-$host-${crypt}.pem --type rsa | ipsec pki --issue --lifetime 730 --cacert cacerts/caCert-${crypt}.pem --cakey private/caKey-${crypt}.pem \
        --dn "O=Scrollout, CN=$host" \
        --san $host \
        --flag serverAuth --flag ikeIntermediate \
        --outform pem > certs/HostCert-$host-${crypt}.pem

;;


client )
# CREATE A CLIENT CERTIFICATE

cd /etc/ipsec.d/
ipsec pki --gen --type rsa --size ${bit} --outform pem > private/${user}Key-${crypt}.pem
chmod 600 private/*.pem
ipsec pki --pub --in private/${user}Key-${crypt}.pem --type rsa | ipsec pki --issue --lifetime 730 --cacert cacerts/caCert-${crypt}.pem \
        --cakey private/caKey-${crypt}.pem \
        --dn "O=Scrollout, CN=${user}@$host" \
		--flag clientAuth --flag ikeIntermediate \
        --san ${user}@$host \
        --outform pem > certs/${user}Cert-${crypt}.pem


# EXPORT CLIENT CERTIFICATE AS A PKCS#12 FILE

cd /etc/ipsec.d/
test -d export || mkdir export

openssl pkcs12 -export -inkey private/${user}Key-${crypt}.pem \
        -in certs/${user}Cert-${crypt}.pem -name "${user}'s VPN Certificate" \
        -certfile cacerts/caCert-${crypt}.pem \
        -caname "Scrollout Root CA" \
        -out export/${user}.p12

;;

revoke )
# REVOKE A CERTIFICATE (IF NECESSARY)

cd /etc/ipsec.d/
ipsec pki --signcrl --reason key-compromise --cacert cacerts/caCert-${crypt}.pem --cakey private/caKey-${crypt}.pem --cert certs/${user}Cert-${crypt}.pem --outform pem > crls/crl.pem
;;

esac

exit 0
