<?
define('LOGS_FILE', '/var/log/mail.log');
define('SETUP_FILE', '/var/www/filter.cfg');

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
		 *	  Process data
		 */
		array_walk($_POST, 'trim');
		/**
		 *	  Save data to file
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


function loadLogs ()
{
  if (file_exists(LOGS_FILE) && is_file(LOGS_FILE))
  {
	$values = file2array();
	if (!empty($values['search']))
	{
	$content = shell_exec('awk \'BEGIN {IGNORECASE=1;} tolower($0) ~ /'.$values['search'].'/\' '.LOGS_FILE.' | tail -n1000 ');	
	}
	else
		{
		$content = shell_exec('tail -n100 '.LOGS_FILE.'');
		}

	$lines = explode("\n", $content);
	$output = Array();
	foreach ($lines AS $count => $line)
	{
	  $values = $line;
	  $char= array('<','>');
	  $log = str_replace($char,'', trim($line));
	  if (!empty($log))
	  {
		array_push($output, $log);
	  }
	  unset($values, $count, $line, $log);
	}
	unset($content, $lines);
#	array_multisort($output, SORT_ASC);

	return $output;
  }
  else
  {
	error_log("No log file [". LOGS_FILE ." defined!");
  }

  return false;
}
$logs = loadLogs();

?>



<div id="logs" class="logs">
		<table width="100%" border="0" align="center" cellpadding="1" cellspacing="0">
<?
if (!empty($logs)) :
  $bgcolor = '';
  foreach ($logs AS $count => $log) :
	$bgcolor = 0 == $count % 2 ? '#393939"' : '#494949';
	$class = 0 == $count % 2 ? 'lrsh shade1' : 'lrsh shade2';
?>
			  <tr class="lrsh <?= $class ?>">
				<td>
				<?
				$log = preg_replace("/\w*?".preg_quote('TLS connection established')."\w*/", "<font color=\"lightgreen\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('Blocked SPAM')."\w*/", "<font color=\"#F0079A\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('X-Spam-Status: Yes')."\w*/", "<font color=\"#F0079A\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('- spam')."\w*/", "<font color=\"#F0079A\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('Blocked INFECTED')."\w*/", "<font color=\"#A10316\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('Blocked BANNED')."\w*/", "<font color=\"#A10316\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('reject')."\w*/i", "<font color=\"#FF7700\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('rank ')."\w*/i", "<font color=\"#FF7700\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('blocked using')."\w*/", "<font color=\"#FF7700\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('status=bounced')."\w*/", "<font color=\"#525252\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('status=deferred')."\w*/", "<font color=\"#525252\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('limit exceeded')."\w*/", "<font color=\"#525252\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('status=undeliverable')."\w*/", "<font color=\"#525252\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('greylist,')."\w*/i", "<font color=\"#525252\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('status=sent')."\w*/", "<font color=\"#04acec\">$0</font>",$log);
				$log = preg_replace("/\w*?".preg_quote('Received OK')."\w*/i", "<font color=\"#0072FD\">$0</font>",$log);
				?>
				 <span id="<?= $count ?>" class="style_log"><?= !empty($values['search']) ? preg_replace("/\w*?".preg_quote($values['search'])."\w*/i", "<font color=\"#04acec\">$0</font>",$log) : $log ?></span>
				 </td>
			  </tr>
<?
  endforeach ;
endif ;
?>
		</table>
</div>

<script type="text/javascript">
var objDiv = document.getElementById("logs");
objDiv.scrollTop = (lastpos > 0) ? lastpos : objDiv.scrollHeight;
</script>

		<table width="75%" border="0" align="center" cellpadding="0" cellspacing="0">
			  <tr>
				<td align="left" colspan="2" width="0%" class="style20"></i><? echo date("M d H:i:s", time()); ?>
				<i class="fa fa-clock-o fa-fw">
				</td>
			  </tr>
	</table>
