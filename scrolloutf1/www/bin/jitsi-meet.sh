#!/bin/bash




p_jvb=$(openssl rand -base64 20 | fold -w10 | head -n1)
p_jicofo=$(openssl rand -base64 20 | fold -w10 | head -n1)
p_focus=$(openssl rand -base64 20 | fold -w10 | head -n1)
p_jigasi=$(openssl rand -base64 20 | fold -w10 | head -n1)
sip_user="number@sip.provider"
sip_pass=$(openssl rand -base64 20 | fold -w10 | head -n1)

. /var/www/traffic.cfg

j_dom="meet.${domain[0]}"



### Prosody
rm /etc/prosody/conf.d/*.cfg.lua

cat << END > /etc/prosody/conf.avail/scrollout.cfg.lua

VirtualHost "localhost"

VirtualHost "guest.${j_dom}"
     authentication = "anonymous"

VirtualHost "${j_dom}"
		authentication = "internal_plain"
        -- enabled = false -- Remove this line to enable this host
        -- authentication = "anonymous"
        -- Properties below are modified by jitsi-meet-tokens package config
        -- and authentication above is switched to "token"
        --app_id="example_app_id"
        --app_secret="example_app_secret"
        -- Assign this host a certificate for TLS, otherwise it would use the one
        -- set in the global section (if any).
        -- Note that old-style SSL on port 5223 only supports one certificate, and will always
        -- use the global one.
        ssl = {
                key = "/etc/prosody/certs/${j_dom}.key";
                certificate = "/etc/prosody/certs/${j_dom}.crt";
				
        }
        -- we need bosh
        modules_enabled = {
            "bosh";
            "pubsub";
            "ping"; -- Enable mod_ping
        }

Component "conference.${j_dom}" "muc"
	restrict_room_creation = "local"
    --modules_enabled = { "token_verification" }
admins = { "focus@auth.${j_dom}" }

Component "jitsi-videobridge.${j_dom}"
    component_secret = "${p_jvb}"

VirtualHost "auth.${j_dom}"
    authentication = "internal_plain"

Component "focus.${j_dom}"
    component_secret = "${p_jicofo}"

Component "callcontrol.${j_dom}"
	component_secret = "${p_jigasi}"

END

ln -s /etc/prosody/conf.avail/scrollout.cfg.lua /etc/prosody/conf.d/scrollout.cfg.lua



prosodyctl register focus auth.${j_dom} ${p_focus}


rm /etc/prosody/certs/${j_dom}.*
ln -s /etc/postfix/certs/scrollout.cert /etc/prosody/certs/${j_dom}.crt; ln -s /etc/postfix/certs/scrollout.key /etc/prosody/certs/${j_dom}.key

rm /etc/prosody/certs/localhost.* 
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/prosody/certs/localhost.crt
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/prosody/certs/localhost.cert
ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/prosody/certs/localhost.key

# (openssl req -new -sha384 -newkey rsa:4096 -days 1000 -nodes -x509 -subj "/O=Scrollout/CN=localhost" -keyout /etc/prosody/certs/localhost.key  -out /etc/prosody/certs/localhost.crt)

chmod 644 /etc/postfix/certs/*

### JICOFO

cat << END > /etc/jitsi/jicofo/config
# Jitsi Conference Focus settings
# sets the host name of the XMPP server
JICOFO_HOST=localhost

# sets the XMPP domain (default: none)
JICOFO_HOSTNAME=${j_dom}

# sets the secret used to authenticate as an XMPP component
JICOFO_SECRET=${p_jicofo}

# sets the port to use for the XMPP component connection
JICOFO_PORT=5347

# sets the XMPP domain name to use for XMPP user logins
JICOFO_AUTH_DOMAIN=auth.${j_dom}

# sets the username to use for XMPP user logins
JICOFO_AUTH_USER=focus

# sets the password to use for XMPP user logins
JICOFO_AUTH_PASSWORD=${p_focus}

# extra options to pass to the jicofo daemon
JICOFO_OPTS=""

# adds java system props that are passed to jicofo (default are for home and logging config file)
JAVA_SYS_PROPS="-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=jicofo -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/jitsi -Djava.util.logging.config.file=/etc/jitsi/jicofo/logging.properties"

END

echo "org.jitsi.jicofo.auth.URL=XMPP:${j_dom}" >  /etc/jitsi/jicofo/sip-communicator.properties

### Videobridge

cat << END > /etc/jitsi/videobridge/config

# Jitsi Videobridge settings

# sets the XMPP domain (default: none)
JVB_HOSTNAME=${j_dom}

# sets the hostname of the XMPP server (default: domain if set, localhost otherwise)
JVB_HOST=

# sets the port of the XMPP server (default: 5275)
JVB_PORT=5347

# sets the shared secret used to authenticate to the XMPP server
JVB_SECRET=${p_jvb}

# extra options to pass to the JVB daemon
JVB_OPTS=""

# extra jvm params
#JVB_EXTRA_JVM_PARAMS="-javaagent:/usr/share/newrelic/newrelic.jar -Dnewrelic.config.file=/etc/jitsi/videobridge/newrelic.yml"

# adds java system props that are passed to jvb (default are for home and logging config file)
JAVA_SYS_PROPS="\$JVB_EXTRA_JVM_PARAMS -Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=videobridge -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/jitsi -Djava.util.logging.config.file=/etc/jitsi/videobridge/logging.properties"

END

echo "# org.jitsi.impl.neomedia.transform.srtp.SRTPCryptoContext.checkReplay=false" >  /etc/jitsi/videobridge/sip-communicator.properties

### Jigasi

cat << END > /etc/jitsi/jigasi/config
# Jigasi settings
JIGASI_SIPUSER=${sip_user}
JIGASI_SIPPWD=${sip_pass}
JIGASI_SECRET=${p_jigasi}
JIGASI_OPTS=""

# adds java system props that are passed to jigasi (default are for logging config file)
JAVA_SYS_PROPS="-Djava.util.logging.config.file=/etc/jitsi/jigasi/logging.properties"

END

### Nginx

rm -f $(grep -l jitsi /etc/nginx/sites-enabled/*.conf) > /dev/null 2>&1

cat << END > /etc/nginx/sites-available/${j_dom}.conf
server_names_hash_bucket_size 64;


server {
    listen 443 ssl;
    server_name ${j_dom};

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA256:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EDH+aRSA+AESGCM:EDH+aRSA+SHA256:EDH+aRSA:EECDH:!aNULL:!eNULL:!MEDIUM:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4:!SEED";

    add_header Strict-Transport-Security "max-age=31536000";

   ssl_certificate /etc/prosody/certs/${j_dom}.crt;
   ssl_certificate_key /etc/prosody/certs/${j_dom}.key;

    root /usr/share/jitsi-meet;
    index index.html index.htm;

    location / {
	allow 192.168.0.0/16;
	allow 172.16.0.0/12;
	allow 10.0.0.0/8;

	# Comment to allow access from Internet
	deny all;

        ssi on;
    }


    location /config.js {
        alias /etc/jitsi/meet/${j_dom}-config.js;
    }

    location ~ ^/([a-zA-Z0-9=\?]+)$ {
        rewrite ^/(.*)$ / break;
    }

    # Backward compatibility
    location ~ /external_api.* {
        root /usr/share/jitsi-meet/libs;
    }

    # BOSH
    location /http-bind {
        proxy_pass      http://localhost:5280/http-bind;
        proxy_set_header X-Forwarded-For \$remote_addr;
        proxy_set_header Host \$http_host;
    }
}

END

test -L /etc/nginx/sites-enabled/${j_dom}.conf || ln -s /etc/nginx/sites-available/${j_dom}.conf /etc/nginx/sites-enabled/${j_dom}.conf


### Jits-meet

rm /etc/jitsi/meet/*-config.js


cat << END > /etc/jitsi/meet/${j_dom}-config.js

/* jshint -W101 */
var config = {
    hosts: {
        domain: '${j_dom}',
		anonymousdomain: 'guest.${j_dom}',
		// authdomain: '${j_dom}',
		// jirecon: 'jirecon.${j_dom}',
        call_control: 'callcontrol.${j_dom}',
		// bridge: 'jitsi-videobridge.${j_dom}', // FIXME: use XEP-0030
        muc: 'conference.${j_dom}', // FIXME: use XEP-0030
    },
    useNicks: true,
    bosh: '//${j_dom}/http-bind', // FIXME: use xep-0156 for that
    clientNode: 'http://jitsi.org/jitsimeet', // The name of client node advertised in XEP-0115 'c' stanza

	
    desktopSharingChromeMethod: 'ext',
    desktopSharingChromeExtId: 'diibjkoicjeejcmhdnailmkgecihlobk',
    desktopSharingChromeSources: ['screen', 'window'],
    desktopSharingChromeMinExtVersion: '0.1',

    desktopSharingFirefoxExtId: null,
    desktopSharingFirefoxDisabled: true,
    desktopSharingFirefoxMaxVersionExtRequired: -1,
    desktopSharingFirefoxExtensionURL: null,

    webrtcIceUdpDisable: false,
    webrtcIceTcpDisable: false,

    openSctp: true, // Toggle to enable/disable SCTP channels
    disableStats: false,
    disableAudioLevels: false,
    channelLastN: -1, // The default value of the channel attribute last-n.
    adaptiveLastN: false,
    enableRecording: false,
    enableWelcomePage: true,
    disableSimulcast: false,
    logStats: false, // Enable logging of PeerConnection stats via the focus
    disableThirdPartyRequests: false,
    minHDHeight: 520
};

END


test -L /usr/share/jitsi-meet/images/rightwatermark.png || ln -s "/var/www/logo v3.png" /usr/share/jitsi-meet/images/rightwatermark.png
rm -f /usr/share/jitsi-meet/favicon.ico; ln -s /var/www/favicon.ico /usr/share/jitsi-meet/favicon.ico

sed -e "s/SHOW_JITSI_WATERMARK: .*,/SHOW_JITSI_WATERMARK: false,/" \
	-e "s/JITSI_WATERMARK_LINK: .*,/JITSI_WATERMARK_LINK: \"\",/" \
	-e "s/SHOW_BRAND_WATERMARK: .*,/SHOW_BRAND_WATERMARK: true,/" \
	-e "s/BRAND_WATERMARK_LINK: .*,/BRAND_WATERMARK_LINK: \"http:\/\/www.scrolloutf1.com\",/" \
	-e "s/APP_NAME: .*,/APP_NAME: \"Conference\",/" \
	-e "s/DEFAULT_REMOTE_DISPLAY_NAME: .*,/DEFAULT_REMOTE_DISPLAY_NAME: \"Guest\",/" \
	-e "s/FILM_STRIP_MAX_HEIGHT: .*,/FILM_STRIP_MAX_HEIGHT: 175,/" \
	-e "s/INVITATION_POWERED_BY: .*,/INVITATION_POWERED_BY: false,/" -i /usr/share/jitsi-meet/interface_config.js

