<?php
/*****Levels*****/  
define('SETUP_FILE', '/var/www/security.cfg');
define('SECURITY_FILE', '/var/www/security.list');
/*****Levels end*****/  

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
	  $message['msg'] = 'Settings saved successfully!';
	  $message['type'] = 'message';
	}
	else
	{
	  $message['msg'] = 'Can not save data!';
	  $message['type'] = 'error';
	}


?>