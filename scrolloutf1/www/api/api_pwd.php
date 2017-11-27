<?php
	define('SETUP_FILE', '/var/www/.htpasswd');
	define('PASSWORD_LENGTH', 6);




	if ($_SERVER['PHP_AUTH_PW'] == $_POST['currpass'])
	{
		if (!empty($_POST['newpass']) && PASSWORD_LENGTH <= strlen($_POST['newpass']))
		{
		  if ($_POST['newpass'] == $_POST['newpass2'])
		  {
			$cmd = 'htpasswd -b '. SETUP_FILE .' '. $_SERVER['PHP_AUTH_USER'] ." ". escapeshellarg ($_POST['newpass']);
			exec($cmd);
			$message['msg'] = 'Password updated successfully!';
			$message['type'] = 'message';
		  }
		  else
		  {
			$message['msg'] = 'New password do not match!'; 
			$message['type'] = 'error';
		  }
		}
		else
		{
		  $message['msg'] = 'Min lenght for new password is '. PASSWORD_LENGTH .' chars!'; 
		  $message['type'] = 'error';
		}
    }
	else
	{
		$message['msg'] = 'Wrong old password!';
		$message['type'] = 'error';

    }
 	echo json_encode($message);

?>