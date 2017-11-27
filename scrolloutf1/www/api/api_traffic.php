<?php
define('SETUP_FILE', '/var/www/traffic.cfg');
$keys = shell_exec('sudo /var/www/bin/dkim.sh showkeys');
$pwd = shell_exec('sudo /var/www/bin/pwd.sh create');

function array2file ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
  $str = '';
  foreach ($_POST AS $key => $value)
  {
    $str .= $key ."=('" .str_replace(array("\r\n","\r","\n"),"' '",str_replace(" ",'',$value))."');\n";
  }
  return $str;
  }

  return false;
}

if (!empty($_POST))
{
    $values = $_POST;
    /**
     *    Process data
     */
    array_walk($_POST, 'trim');
    /**
     *    Save data to file
     */
    $_POST['domain'] = strtolower(implode("\n", $_POST['domain']));
    $_POST['transport'] = strtolower(implode("\n", $_POST['transport']));
    $_POST['mynets'] = implode("\n", $_POST['mynets']);
    $_POST['ipsecips'] = implode("\n", $_POST['ipsecips']);
    $_POST['ipseckey'] = implode("\n", $_POST['ipseckey']);
    $_POST['assips'] = implode("\n", $_POST['assips']);
    $_POST['quarantine'] = strtolower(implode("\n", $_POST['quarantine']));
    $_POST['tag'] = implode("\n", $_POST['tag']);
    $_POST['sbj'] = implode("\n", $_POST['sbj']);
    $_POST['lsrv'] = strtolower(implode("\n", $_POST['lsrv']));
    $_POST['ldap'] = implode("\n", $_POST['ldap']);
    $_POST['spam'] = implode("\n", $_POST['spam']);
    $_POST['spamd'] = implode("\n", $_POST['spamd']);
    $_POST['bounce'] = implode("\n", $_POST['bounce']);
    $_POST['virus'] = implode("\n", $_POST['virus']);
    $_POST['ban'] = implode("\n", $_POST['ban']);
    $_POST['ldom'] = implode("\n", $_POST['ldom']);
    $_POST['luser'] = implode("\n", $_POST['luser']);
    $_POST['lpass'] = implode("\n", $_POST['lpass']);
    $_POST['block'] = implode("\n", $_POST['block']);
    $_POST['cutoff'] = implode("\n", $_POST['cutoff']);
    $_POST['hrelays'] = strtolower(implode("\n", $_POST['hrelays']));
    $_POST['clones'] = strtolower(implode("\n", $_POST['clones']));
    $_POST['redirect'] = strtolower(implode("\n", $_POST['redirect']));
    $_POST['senders'] = strtolower(implode("\n", $_POST['senders']));
    $_POST['sendersd'] = strtolower(implode("\n", $_POST['sendersd']));
    $_POST['receivers'] = strtolower(implode("\n", $_POST['receivers']));
    $_POST['receiversd'] = strtolower(implode("\n", $_POST['receiversd']));
    $_POST['urelays'] = implode("\n", $_POST['urelays']);
    $_POST['prelays'] = implode("\n", $_POST['prelays']);
    $_POST['encrypt'] = implode("\n", $_POST['encrypt']);
    $_POST['report'] = implode("\n", $_POST['report']);
    $_POST['spamtraps'] = strtolower(implode("\n", $_POST['spamtraps']));
    $_POST['d_dkim'] = implode("\n", $_POST['d_dkim']);
    $_POST['srs'] = implode("\n", $_POST['srs']);
    $_POST['srsto'] = implode("\n", $_POST['srsto']);
    if (file_put_contents(SETUP_FILE, array2file($_POST)))
    {
      $message['msg'] = 'Settings saved successfully!';
      $message['type'] = 'message';
    }
    else
    {
      $message['msg'] = 'Can not save data!';
      $message['type'] = 'error';
    }
}