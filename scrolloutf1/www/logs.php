<?
define('SETUP_FILE', '/var/www/filter.cfg');

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

?>



<!DOCTYPE html>
<html lang="en">

<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title><?php echo $_SERVER['HTTP_HOST'] ?></title>
<?
if ($_SERVER['PHP_AUTH_PW'] == '123456' || $_SERVER['PHP_AUTH_PW'] == '')
{
?>
		<meta http-equiv="refresh" content="0;url=pwd.html">
<?
}
?>
		<meta name="Description" content="" />
		<meta name="keywords" content="" />
		<style type="text/css" media="Screen">/*\*/@import url("css/style.css");/**/</style>
		<script src="js/jquery-latest.js"></script>
		<link rel="stylesheet" href="css/nav.css">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

	<script type="text/javascript">
		$(function() {
		  if ($.browser.msie && $.browser.version.substr(0,1)<7)
		  {
						$('li').has('ul').mouseover(function(){
								$(this).children('ul').show();
								}).mouseout(function(){
								$(this).children('ul').hide();
								})
		  }
		});
	</script>




		<script>
		var lastpos = 0;
		$(document).ready(function() {
		$("#responsecontainer").load("logsreload.html");
		var refreshId = setInterval(function() {
		lastpos = $('#responsecontainer .logs').scrollTop();
		$("#responsecontainer").load('logsreload.html?randval='+ Math.random());
		}, 10000);
		});
		</script>

<?
if (isset($_GET['service'])) {
$service = $_GET['service'];
?>
                <script>
                $(document).ready(function() {
                $("#resources").load("header.html?service=<? print "$service" ?>");
                var refreshId = setInterval(function() {
                $("#resources").load('header.html?randval='+ Math.random());
                }, 5000);
                });
                </script>
<?
}
else
{
?>
                <script>
                $(document).ready(function() {
                $("#resources").load("header.html");
                var refreshId = setInterval(function() {
                $("#resources").load('header.html?randval='+ Math.random());
                }, 5000);
                });
                </script>

<?
}
?>
</head>

<body class="no-js">

<?
if (empty($_SERVER['HTTPS'])) {
?>
<table border="0" cellpadding="3px" align="center" width="100%">
        <tr bgcolor="red">
          <td nowrap="nowrap"  padding="100px" margin="100px"><div align="center">
                <span class="style15">ALERT: This is not an encrypted channel! </span>
                <span class="style15">Always use <a href="https://<? print "{$_SERVER['SERVER_NAME']}{$_SERVER['REQUEST_URI']}" ?>">
        <strong>HTTPS</strong></a> for password protected access</span></div></td>
        </tr>

</table>


<?
}
else
{
?>
<script>
if (window.location.protocol != "https:")
{
alert("Alert!\nPossible hacking attempt in progress:\n1. The server received your request and answered on HTTPS channel.\n2. Your browser received the HTTPS response on the HTTP channel, instead on HTTPS. Someone or something made this s
witch between you and the server, in order to intercept the communication.\n3. If the browser does not display HTTPS in the address bar, a Man in The Middle attack may be in progress.\n\nResult: The password for web access is compromise.
\n");
    window.location.href = "https:" + window.location.href.substring(window.location.protocol.length);
}

</script>

<?
}
?>

	 <script>
		var el = document.getElementsByTagName("body")[0];
		el.className = "";
	</script>



		<div id="setup">
				<div>

<table width="75%" border="0" align="center" cellpadding="0" cellspacing="0">

			<tr>
				<td width="0%" align="left" valign="bottom">
					<div align="center"><img src="logo v3.png" alt="Logo" /><br>
					</div>
				</td>
                                <td width="100%">

                                <div id="resources" style="width: 100%;">
                                </div>

                                </td>

			</tr>

			  <tr>
				<td colspan="2" width="100%">

<? include 'nav.php' ?>

				</td>
			  </tr>
		</table>


		<table width="75%" border="0" align="center" cellpadding="5" cellspacing="0">
			  <tr>
				<th colspan="2" width="0%">&nbsp;</th>
			  </tr>
			  <tr>
				<td colspan="2"  width="0%"><span class="style24"><span class="mi">&#xE82D</span>&nbsp;&nbsp;&nbsp;Logs</span>
				</td>
			  </tr>
			  <tr class="tblrsh shade">
			  <td width="50%" nowrap="nowrap" align="left">

		    <div class="f-form">
			<form name="setup" action="logs.php" method="post">
			<span class="style15"><span class="mi-s">&#xE094;</span>
			  <input placeholder="text1.*text2.*text3" size="40" name="search" type="text" id="search" value="<?= !empty($values['search']) ? $values['search'] : ''?>" />
			  <input type="submit" class="mi-s" value=" &#xE16E " title="or Press ENTER" alt="or Press ENTER" />
			  </form>
		    </div>

		    <div class="f-form">
			<form name="clean" action="logs.php" method="post">
			  <input name="from" type="hidden" id="from" value="" />
			  <input name="to" type="hidden" id="to" value="" />
			  <input name="search" type="hidden" id="search" value="" />
			  <input type="submit" class="mi-s" value=" &#xE894 " />
			  </form>
		    </div>
			  </td>
			  <td  width="50%" align="right">

			    <div style="display: inline; white-space: nowrap;">

			<span title="download" class="mi-l">&#xE118;</span>

			<form name="log1" action="mail.log.1" method="get" style="display: inline;">
			  <input type="submit" class="style15" value=" Last week " />
			</form>

			<form name="log" action="mail.log" method="get" style="display: inline;">
			  <input type="submit" class="style15" value=" This week " />
			</form>
			
			</div>

			</td>
				</tr>
			</table>
</div>


<div  id="responsecontainer">
</div>




<? include 'footer.php' ?>


</body>
</html>
