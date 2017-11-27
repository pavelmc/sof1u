<?php

define('SETUP_FILE', '/var/www/connection.cfg');

$interface=exec("sudo /sbin/ip link show | /usr/bin/awk -F ': ' '/^[0-9]*: .*: <BROADCAST,MULTICAST/ {print $2;exit;}'");
$ipaddr = exec('sudo /sbin/ifconfig | /bin/grep -v "127\.0\.0" | /bin/grep -m1 "inet .* Bcast.* Mask" | /bin/sed "s/.*addr:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *B.*/\1/"');
$ipaddr6 = exec("sudo /sbin/ip -6 a s dev ". $interface ." | /usr/bin/awk '/inet6.*scope global/ {print $2; exit;}' | /usr/bin/awk -F '/' '{print $1}'");
$maskaddr = exec('sudo /sbin/ifconfig | /bin/grep -m1 "inet .* Bcast.* Mask" | /bin/sed "s/.*Mask:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)$/\1/"');
$maskaddr6 = exec("sudo /sbin/ip -6 a s dev ". $interface ." | /usr/bin/awk '/inet6.*scope global/ {print $2; exit;}' | /usr/bin/awk -F '/' '{print $2}'");
$gwaddr = exec('sudo /sbin/route -n | /bin/grep -m1 "^0.0.0.0.*" | /bin/sed "s/^0.0.0.0 *\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *.*/\1/"');
$gwaddr6 = exec("sudo /sbin/ip -6 r s dev ". $interface ." | /usr/bin/awk '/^default/ && !/ fe80:/ {print $3; exit;}'");
$ns = exec('/bin/cat /etc/resolv.conf | /bin/grep "^nameserver " | /usr/bin/cut -d " " -f2 | /usr/bin/tr "\n" " "');
$domainsearch = exec('/bin/cat /etc/resolv.conf | /bin/grep "^search " | /usr/bin/cut -d " " -f2 | /usr/bin/tr "\n" " "');
$hostname = exec('/bin/hostname');
$dn = exec('/bin/hostname -d');


function array2file ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$str = '';
	foreach ($_POST AS $key => $value)
	{
	  $str .= $key .'=('. $value .");\n";
	}

	return $str;
  }

  return false;
}
function file2array ()
{
  if (file_exists(SETUP_FILE))
  {
	$array = explode("\n", file_get_contents(SETUP_FILE));
	foreach ($array AS $count => $line)
	{
	  $position = strpos($line, '=');
	  $phar = array('(',')');
	  $output[substr($line, 0, $position)] = substr(str_replace($phar, '', $line), $position + 1, -1);
	  unset($position);
	}

	return $output;

  }
}
if (!empty($_POST))
{
	$values = $_POST;
	/**
	 *	Process data
	 */
	array_walk($_POST, 'trim');
		/**
		 *	Save data to file
		 */
		if (file_put_contents(SETUP_FILE, array2file($_POST)))
		{

	exec('sudo /var/www/bin/net.sh');
	$ipaddr = exec('sudo /sbin/ifconfig | /bin/grep -v "127\.0\.0" | /bin/grep -m1 "inet .* Bcast.* Mask" | /bin/sed "s/.*addr:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *B.*/\1/"');
	$ipaddr6 = exec("sudo /sbin/ip -6 a s dev ". $interface ." | /usr/bin/awk '/inet6.*scope global/ {print $2; exit;}' | /usr/bin/awk -F '/' '{print $1}'");
	$maskaddr = exec('sudo /sbin/ifconfig | /bin/grep -m1 "inet .* Bcast.* Mask" | /bin/sed "s/.*Mask:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)$/\1/"');
	$maskaddr6 = exec("sudo /sbin/ip -6 a s dev ". $interface ." | /usr/bin/awk '/inet6.*scope global/ {print $2; exit;}' | /usr/bin/awk -F '/' '{print $2}'");
	$gwaddr = exec('sudo /sbin/route -n | /bin/grep -m1 "^0.0.0.0.*" | /bin/sed "s/^0.0.0.0 *\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *.*/\1/"');
	$gwaddr6 = exec("sudo /sbin/ip -6 r s dev ". $interface ." | /usr/bin/awk '/^default/ && !/ fe80:/ {print $3; exit;}'");
	$ns = exec('/bin/cat /etc/resolv.conf | /bin/grep "^nameserver " | /usr/bin/cut -d " " -f2 | /usr/bin/tr "\n" " "');
	$domainsearch = exec('/bin/cat /etc/resolv.conf | /bin/grep "^search " | /usr/bin/cut -d " " -f2 | /usr/bin/tr "\n" " "');
	$hostname = exec('/bin/hostname');
	$dn = exec('/bin/hostname -d');

		  $message['msg'] = 'Settings saved successfully!';
		  $message['type'] = 'message';
		}
		else
		{
		  $message['msg'] = 'Can not save data!';
		  $message['type'] = 'error';
		}
	echo json_encode($message);
}

?>