<?
define('SETUP_FILE', '/var/www/.htpasswd');
define('PASSWORD_LENGTH', 6);



if (!empty($_POST))
{
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
}

include 'toppwd.php';
?>

<table width="75%" border="0" align="center" cellpadding="2" cellspacing="0">
<form name="password" method="post" action="">
	<tr>
	  <th width="25%" nowrap="nowrap">&nbsp;</th>
	  <th width="75%" nowrap="nowrap" class="style20">&nbsp;</th>
	</tr>
	<tr class="bsh">
<?
if ($_SERVER['PHP_AUTH_PW'] == '123456')
{
?>
	  <td nowrap="nowrap"<span class="style24"><font color="orange">Change the default password</font></span></td>
<?
}
else
{
?>
	  <td nowrap="nowrap"><span class="style24"><span class="mi">&#xE192</span>&nbsp;&nbsp;&nbsp;Password</span></td>
<?
}
?>
	  <td nowrap="nowrap" class="style20">&nbsp;</td>
	</tr>
	<tr class="shade1">
	  <td nowrap="nowrap"><span class="style15">Old password</span></td>
<?
if ($_SERVER['PHP_AUTH_PW'] == '123456')
{
?>
	  <td nowrap="nowrap"><input type="password" name="currpass" value="<? print $_SERVER['PHP_AUTH_PW'] ?>"/></td>
<?
}
else
{
?>
	  <td nowrap="nowrap"><input type="password" name="currpass" /></td>
<?
}
?>
	</tr>
	<tr class="shade2">
	  <td nowrap="nowrap"><span class="style15">New password</span></td>
	  <td nowrap="nowrap"><input type="password" name="newpass" /></td>
	</tr>
	<tr class="shade1">
	  <td nowrap="nowrap"><span class="style15">Confirm New Password</span></td>
	  <td nowrap="nowrap"><input type="password" name="newpass2" /></td>
	</tr>
<?
if (empty($_SERVER['HTTPS'])) {
?>
	<tr bgcolor="#494949">
	  <td nowrap="nowrap"><span class="style15">Recommendation:</span></td>
	  <td nowrap="nowrap"><span class="style15">Use <a href="https://<? print $_SERVER['SERVER_NAME'] ?>">
	HTTPS://<? print $_SERVER['SERVER_NAME'] ?></a> for web access</span></td>
	</tr>
<?
}
?>

	  <td nowrap="nowrap">&nbsp;</td>
	  <td nowrap="nowrap">&nbsp;</td>
	</tr>
	<tr>
	  <td nowrap="nowrap">&nbsp;</td>
	  <td nowrap="nowrap" class="style20"><span class="style15">
		<input type="submit" name="submit" class="mi-l" value=" &#xE10B " />
		<input type="hidden" name="redirect" value="true" />
	  </span></td>
	</tr>
</form>
</table>
<? include 'footer.php' ?>
</body>
</html>

