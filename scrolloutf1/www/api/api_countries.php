<?
define('SETUP_FILE', '/var/www/countries.cfg');
define('COUNTRIES_FILE', '/var/www/cfg/geo/countries');

function array2file ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$str = '';
	foreach ($_POST AS $key => $value)
	{
	  $str .= $key .'='. $value .";\n";
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