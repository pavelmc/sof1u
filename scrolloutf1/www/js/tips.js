
var Tips = [],
index = 0;

    divs =	'<div id="carousel">';
    dive =	'</div>';

    Tips[0] =   "<b>Tip: </b>"+
                "Do not use public (open) DNS servers in your network settings, such as Google's 8.8.8.8.<br/>" +
                "Many RBL providers may not return any answer to SpamAssassin DNS queries, causing poor filtering results.";

    Tips[1] =   "<b>Tip: </b>"+
                "Make sure that you allways input IP address(es) in CIDR format in <b>ROUTE > Trust Networks</b>, e.g.: 192.168.1.1<u>/32</u><br/>"+
		"In Trust Networks, you can enumerate multiple IP addresses and networks seprated by comma, e.g.: 192.168.1.1/32,10.0.0./8</br>"+
		"The gateway/router is always excluded.";

    Tips[2] =   "<b>Tip: </b>"+
                "Scrollout needs to see the original IP address of the client, not the IP of your router/firewall.<br/>"+
                "Make sure that you forward the incoming traffic on port 25, on your firewall/router, to Scrollout.";

    Tips[3] =   "<b>Tip: </b>"+
                "Make sure that the IP address of your router/firewall never appear in logs (i.e., <b>Monitor > Logs</b>).<br/>"+
                "Scrollout needs to see the original IP address of the client, not the IP of your router/firewall.";

    Tips[4] =   "<b>Tip: </b>"+
                "Use SMTP Authentication to allow external servers to send emails. Find the credentials under<b> ROUTE > Inbound.</b>";

    Tips[5] =   "<b>Tip: </b>"+
                "Test mode (non-blocking) can be set under <b>ROUTE > Quarantine</b> using these values: <br/>"+
                "&lArr; PASS &rArr; [ 5 ] &lArr; TAG as SPAM &rArr; [ 999 ] &lArr; Quarantine to [ quarantine@your-domain.com ] &rArr; [ 999 ] &lArr; BLOCK";

    Tips[6] =   "<b>Tip: </b>"+
                "Never trust IP addresses of servers that don't belong to your network. Do not include them in Route > Inbound > Trust Networks.";

    Tips[7] =   "<b>Tip: </b>"+
                "Multiple spam gateways placed one behind another may affect results causing false positives, false negatives, asynchronous bounces etc.";

    Tips[8] =   "<b>Tip: </b>"+
                "The SMTP Account under <b>primary domain</b> can send emails on behalf of all other domains, while all other SMTP accounts are limited to their own domain.<br/>"+
		"Use that <b>primary account</b> to authenticate a MS Exchange Connector forwarding emails from multiple domains.";

    Tips[9] =   "<b>Contribute:</b> Have you used Scrollout for a while? <br/>"+
                'You can contribute with a <a href="http://sourceforge.net/projects/scrollout/reviews?source=navbar" target="_blank"><b>review in any language.</b></a>';

    Tips[10] =   "<b>Tip: </b>"+
                "The <b>Geographic filter</b> can be a handy tool if used properly:<br/>"+
		"Go to <b>SECURE > COUNTRIES</b> panel, click <b>Select Column</b> in the middle, scroll down the list and click <b>Business area</b> for all other trusted countries.";

    Tips[11] =   "<b>Tip: </b>"+
                "Scrollout is blocking for a while the IP addresses sending excessive volume of spam, hitting too many non-existing email addresses or trying too many wrong authentications (i.e.: SMTP, SSH, HTTP).";

    Tips[12] =   "<b>Tip: </b>"+
                "Messages older than 7 days are deleted from Spam Collector > Inbox folder.<br/>"+
		"Messages older than 1 day are deleted from Spam Collector > BAD & GOOD folders.";

    Tips[13] =   "<b>Tip: </b>"+
                "Always use STRONG PASSWORDS for accessing Scrollout (e.g.: ssh, http, https).";

    Tips[14] =   "<b>Note: </b>"+
                "Scrollout has no hardcoded accounts, default passwords nor any kind of code or service designed to share (leak) information without consent.";

    Tips[15] =   "<b>Tip: </b>"+
                "Always use a dedicated mailbox for Collector. Incoming messages to collector@your-domain.com are blocked.";
				
    Tips[16] =   "<b>Tip: </b>"+
                "Keep asynchronous bounces down to 0 to avoid being blocked or blacklisted.<br/>"+
				"Use Active Directory recipient validation (i.e., ROUTE > Inbound) if you run Exchange server 2007/2010 or later.";

	Tips[17] =   "<b>Used ports: </b>"+
					"<b>out 53 UDP:</b> DNS queries, RBL queries; "+
					"<b>out 80 TCP:</b> HTTP updates; "+
					"<b>in 80 TCP:</b> web management access; "+
					"<b>in 443 TCP:</b> web management access over TLS/SSL (recommended); "+
					"<b>in 25 TCP:</b> incoming SMTP traffic (and other customized local ports); "+
					"<b>out 25 TCP:</b> outgoing SMTP traffic (and other remote ports); "+
					"<b>in|out 8080 TCP:</b> proxy web cache for intranets; "+
					"<b>out 6277 UDP:</b> DCC service request; "+
					"<b>out 2703 TCP:</b> Razor2 service request; "+
					"<b>out 24441 UDP:</b> Pyzor service request; "+
					"<b>in|out 4500 UDP:</b> IPSec NAT Traversal; "+
					"<b>out 123 UDP:</b> NTP time request.";
				
    Tips[18] =   "<b>Note: </b>"+
                "Never use an Administrator's account in Collect or Route > Inbound > Active Directory validation nor for any other task, in your practice (e.g.: scheduled backup), that stores the username and password.";
				
	Tips[19] =   "<b>Tip: </b>"+
                "Scrollout publishes spam traps in the welcome page (div id: contacts). You may hide that div in your website source.<br/>"+
				"Create more effective ones in Collect > Spam Traps: <b>former_employee1 former_employee2</b> etc. Do not type @domain.com, will be added automatically.";

	Tips[20] =   "<b>Tip: </b>"+
                "To update Scrollout type in the Linux console <b>rm -f /var/www/ver; /var/www/bin/update.sh</b> ";
				
	Tips[21] =   "<b>Tip: </b>"+
                "<b>abuse@your-domain.com</b> is a must have email (or alias) address. Check it for messages periodically.";
				
	Tips[22] =   "<b>Tip: </b>"+
                "Activate greylist feature after some time (1-4 weeks). Change the value of <b>Rate Limits in</b> (Secure panel) to a value of 5.";

	Tips[23] =   "<b>Tip: </b>"+
                "In case of large SMTP attacks, change the value of <b>Rate limits in, Auto defense</b> (in Secure tab) to an aggressive value and <b>Rate limits out</b> to an optimum value.";

	Tips[24] =   "<b>Tip: </b>"+
                "Run <b>amavisd-new showkeys</b> to display all DKIM keys in short TXT format (necessary for DNS servers like BIND9).";

	Tips[25] =   "<b>Tip: </b>"+
                "Do not set more than few security features on aggressive levels. That might block legit emails. Keep settings in a safe zone (optimum values).";	
				
    Tips[26] =   "<b>Contribute:</b> Is Scrollout keeping your mailboxes safe and clean? <br/>"+
                'You can thank by <b>donating</b>'+
		' in <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TSGC9M53JPVCQ" target="_blank"><b>USD</b></a>'+    
		' or <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=H392JXKWPSNGY" target="_blank"><b>EUR</b></a>.';

    Tips[27] =   "<b>Tip: </b>"+
                "Not using a recipient verification is a bad idea. Accepting messages for non-existing recipients will cause bounce messages to be sent to forged senders.<br/>"+
				"Activate <b>[x] Filter recipient who are not in Active Directory</b> in Exchange 2000/2003;<br/>"+
				"Use Active Directory recipient validation (i.e., ROUTE > Inbound) if you run Exchange server 2007/2010 or later.";

	Tips[28] =   "<b>Tip: </b>"+
                "In order to bypass any content filtering, from your server, use SMTP port 587 and Connection filter >= 6. Note that port 587 requires both authentication and encryption.";				
	
	Tips[29] =   "<b>Tip: </b>"+
                "In order to bypass any content filtering, send messages using <b>not filtered</b> anywhere in the Subject field.";	
				
	Tips[30] =   "<b>Tip: </b>"+
                "IPSec transport encryption can be used to secure communication with Microsoft Windows Servers too.";
				
	Tips[31] =   "<b>Tip: </b>"+
                "Use your own local RBL service in: <b>/var/www/rbldns/</b> folder.";
				
index = Math.floor(Math.random() * Tips.length);
$("#tips").html(divs+Tips[index]+dive);

setInterval(function() {
index = Math.floor(Math.random() * Tips.length);
$("#tips").html(divs+Tips[index]+dive);
}, 30000);
