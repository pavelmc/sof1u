<?
define('CERT_FILE', '/etc/postfix/certs/scrollout.cert');
define('KEY_FILE','/etc/postfix/certs/scrollout.key');

$certificate = openssl_x509_parse(file_get_contents(CERT_FILE));
$validFrom = date('Y-m-d H:i:s', $certificate['validFrom_time_t']);
$validTo = date('Y-m-d H:i:s', $certificate['validTo_time_t']);
$name = $certificate['name'];


function array2cert ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$cert = $_POST['cert'];
        return $cert;
  }
    else
    {
  return false;
    }
}

function array2key ($data)
{
  if (!empty($_POST) && is_array($_POST))
      {
	$certkey = $_POST['certkey'];
        return $certkey;
    }
    else
    {
  return false;
    }
}
  $values = $_POST;
        /**
         *      Process data
         */
        $_POST =  array_map("trim", $_POST);
                /**
                 *      Save data to file
                 */
                if (file_put_contents(CERT_FILE, array2cert($_POST)) !== false && file_put_contents(KEY_FILE, array2key($_POST)) !== false )
                {
		shell_exec('sudo /var/www/bin/service.sh cert'.' '.$_POST['passkey']);
                  $message['msg'] = 'Settings saved successfully!';
                  $message['type'] = 'message';
                }
                else
                {
                  $message['msg'] = 'Can not save data!';
                  $message['type'] = 'error';
                }