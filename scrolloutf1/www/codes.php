<?
define('SETUP_FILE', '/var/www/codes.cfg');



function array2file ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$str = '';
	foreach ($_POST AS $key => $value)
	{
	  $str .= $key .'="'. $value ."\";\n";
	}

#	return str_replace(' ', '_', $str);
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
	  $phar = array('"','"'); 
	  $output[substr($line, 0, $position)] = substr(str_replace($phar, '', $line), $position + 1, -1);
	  unset($position);
	}
	
#	return str_replace('_', ' ', $output);
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
<? include 'top.php' ?>

	<table width="75%" border="0" align="center" cellpadding="2" cellspacing="0">
			  <tr>
				<th width="25%" nowrap="nowrap">&nbsp;</th>
				<th width="75%" nowrap="nowrap" class="style20">&nbsp;</th>
			  </tr>
			  <tr>
				<td nowrap="nowrap"><span class="style20 style22">Action</span></td>
				<td nowrap="nowrap" class="style20">&nbsp;</td>
			  </tr>
			  <tr bgcolor="#393939">
				<td nowrap="nowrap"><span class="style15">Greylist policy </span><span class="style36"><i>4xx messsage... only</i></span></td>
				<td nowrap="nowrap" bgcolor="#393939" class="style20"><input name="postgrey_code" type="text" id="postgrey_code" value="<?= !empty($values['postgrey_code']) ? $values['postgrey_code'] : ''?>" size="100" /></td>
			  </tr>
							
			  <tr bgcolor="#494949">
				<td nowrap="nowrap"><span class="style15">Client hostname policy</span></td>
				<td nowrap="nowrap" bgcolor="#494949" class="style20"><input name="client_code" type="text" id="client_code" value="<?= !empty($values['client_code']) ? $values['client_code'] : ''?>" size="100" /></td>
			  </tr>
			  <tr bgcolor="#393939">
				<td nowrap="nowrap"><span class="style15">Client IP policy</span></td>
				<td nowrap="nowrap" bgcolor="#393939" class="style20"><input name="cidr_client_code" type="text" id="cidr_client_code" value="<?= !empty($values['cidr_client_code']) ? $values['cidr_client_code'] : ''?>" size="100" /></td>
			  </tr>
			  <tr bgcolor="#494949">
				<td nowrap="nowrap"><span class="style15">Client TLD policy</span></td>
				<td nowrap="nowrap" bgcolor="#494949" class="style20"><input name="dottlds_code" type="text" id="dottlds_code" value="<?= !empty($values['dottlds_code']) ? $values['dottlds_code'] : ''?>" size="100" /></td>
			  </tr>
			  <tr bgcolor="#393939">
				<td nowrap="nowrap"><span class="style15">Sender address policy</span></td>
				<td nowrap="nowrap" bgcolor="#393939" class="style20"><input name="sender_code" type="text" id="sender_code" value="<?= !empty($values['sender_code']) ? $values['sender_code'] : ''?>" size="100" /></td>
			  </tr>
			  <tr bgcolor="#494949">
				<td nowrap="nowrap"><span class="style15">Recipient address policy</span></td>
				<td nowrap="nowrap" bgcolor="#494949" class="style20"><input name="recipients_code" type="text" id="recipients_code" value="<?= !empty($values['recipients_code']) ? $values['recipients_code'] : ''?>" size="100" /></td>
			  </tr>
			  
			  <tr bgcolor="#393939">
				<td nowrap="nowrap"><span class="style15">Header policy</span></td>
				<td nowrap="nowrap" bgcolor="#393939" class="style20"><input name="header_code" type="text" id="header_code" value="<?= !empty($values['header_code']) ? $values['header_code'] : ''?>" size="100" /></td>
			  </tr>
			  <tr bgcolor="#494949">
				<td nowrap="nowrap"><span class="style15">Body policy</span></td>
				<td nowrap="nowrap" bgcolor="#494949" class="style20"><input name="body_code" type="text" id="body_code" value="<?= !empty($values['body_code']) ? $values['body_code'] : ''?>" size="100" /></td>
			  </tr>
			  <tr bgcolor="#393939">
				<td nowrap="nowrap"><span class="style15">Report spam to </span><span class="style36"><i>e-mail address only</i></td>
				<td nowrap="nowrap" bgcolor="#393939" class="style20"><input name="report_spam" type="text" id="report_spam" value="<?= !empty($values['report_spam']) ? $values['report_spam'] : ''?>" size="100" /></td>
			  </tr>
			  <tr bgcolor="#494949">
				<td nowrap="nowrap"><span class="style15">Report virus to </span><span class="style36"><i>e-mail address only</i></td>
				<td nowrap="nowrap" bgcolor="#494949" class="style20"><input name="report_virus" type="text" id="report_virus" value="<?= !empty($values['report_virus']) ? $values['report_virus'] : ''?>" size="100" /></td>
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

