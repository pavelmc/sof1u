<?php
define('SETUP_FILE', '/var/www/collector.cfg');



function array2file ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$str = '';
	foreach ($_POST AS $key => $value)
	{
	  $str .= $key .'="'. $value ."\";\n";
	}

	return $str;
  }
  
  return false;
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
		  $message['msg'] = 'Settings saved successfully!';
		  $message['type'] = 'message';
		}
		else
		{
		  $message['msg'] = 'Can not save data!';
		  $message['type'] = 'error';
		}
}

