<?
define('SETUP_FILE', '/var/www/ldp.cfg');



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
function file2array ()
{
  if (file_exists(SETUP_FILE))
  {
	$array = explode("\n", file_get_contents(SETUP_FILE));
	foreach ($array AS $count => $line)
	{
	  $position = strpos($line, '=');
	  $output[substr($line, 0, $position)] = substr(str_replace('"', '', $line), $position + 1, -1);
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
		  $message['msg'] = 'Settings saved successfully!';
		  $message['type'] = 'message';
		}
		else
		{
		  $message['msg'] = 'Can not save data!';
		  $message['type'] = 'error';
		}
}
else
{
  /**
   *	Load data from file
   */
  $values = file2array();
  
}
?>
<? include 'top.php'?>

	<table width="75%" border="0" align="center" cellpadding="2" cellspacing="0">
			  <tr>
				<th width="25%" nowrap="nowrap">&nbsp;</th>
				<th width="75%" nowrap="nowrap" class="style20">&nbsp;</th>
			  </tr>
			  <tr>
				<td nowrap="nowrap"><span class="style24">Lite DLP</span>
				<a class="tooltip" href="#">(i)<span>
				<? include 'tooltips/lite_dlp' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" class="style20">&nbsp;</td>
			  </tr>
			  <tr bgcolor="#393939">
				<td nowrap="nowrap"><span class="style15">Connect to Windows share</span>
				<a class="tooltip" href="#">(i)<span>
				<? include 'tooltips/lite_share' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" bgcolor="#393939" class="style20">\\<input placeholder="file server or host" name="file_server" type="text" id="dns11" value="<?= !empty($values['file_server']) ? $values['file_server'] : ''?>"/>\<input placeholder="shared folder" name="share" type="text" id="dns11" value="<?= !empty($values['share']) ? $values['share'] : ''?>" />
				</td>
			  </tr>
			  <tr bgcolor="#494949">
				<td nowrap="nowrap"><span class="style15">Windows Domain & User</span>
				<a class="tooltip" href="#">(i)<span>
				<? include 'tooltips/lite_user' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" bgcolor="#494949" class="style20">&nbsp;&nbsp;
				<input placeholder="Windows Domain or host" name="user_domain" type="text" id="dns8" value="<?= !empty($values['user_domain']) ? $values['user_domain'] : ''?>"/>\<input placeholder="Windows User" name="folder_username" type="text" id="dns8" value="<?= !empty($values['folder_username']) ? $values['folder_username'] : ''?>" /></td>
			  </tr>
			  <tr bgcolor="#393939">
				<td nowrap="nowrap"><span class="style15">Password</span></td>
				<td nowrap="nowrap" bgcolor="#393939" class="style20">&nbsp;&nbsp;<input placeholder="password" name="folder_password" type="password" id="dns9" value="<?= !empty($values['folder_password']) ? $values['folder_password'] : ''?>" /></td>
			  </tr>
			  <tr>
				<td nowrap="nowrap">&nbsp;</td>
				<td nowrap="nowrap" class="style20">&nbsp;</td>
			  </tr>
		  </table>
  <div>
			<div align="center">
			  <input type="submit" class="style15" value=" APPLY " title="or Press ENTER" alt="or Press ENTER" />
			  </div>
		</div>
	  </form>
	</div>
<? include 'footer.php' ?>

</body>
</html>

