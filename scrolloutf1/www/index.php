<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Scrollout F1</title>
<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title><?php echo $_SERVER['HTTP_HOST'] ?></title>
<? 
if ($_SERVER['PHP_AUTH_PW'] == '123456')
{
?>
	<meta http-equiv="refresh" content="5;url=pwd.html">
<?
}
else
{
?>

		<meta http-equiv="refresh" content="5;url=security.html">
<?
}
?>
		<meta name="Description" content="" />
		<meta name="keywords" content="" />
		<style type="text/css" media="Screen">/*\*/@import url("css/style.css");/**/</style>
				<style tyle="text/css">
				body {color: #CCCCCC; background-color: #191919;}
				a:link {color: #FFFFFF;}
				</style>


<body>
<div align="center">
  <table width="100%" border="0" cellpadding="3px">
<?
if (empty($_SERVER['HTTPS'])) {
?>
	<tr bgcolor="red">
	  <td nowrap="nowrap"><div align="center">
	<span class="style15">ALERT: This is not an encrypted channel! </span>
	<span class="style15">Always use <a href="{$_SERVER['REQUEST_URI']}" ?>">
	<strong>HTTPS</strong></a> for password protected access</span></div></td>
	</tr>
	
	<?
	}
		else
	{
	?><tr><td>
		<script>
		if (window.location.protocol != "https:")
		{
			alert("Alert!\nPossible hacking attempt in progress:\n1. The server received your request and answered on HTTPS channel.\n2. Your browser received the HTTPS response on the HTTP channel, instead on HTTPS. Someone or something made this switch between you and the server, in order to intercept the communication.\n3. If the browser does not display HTTPS in the address bar, a Man in The Middle attack may be in progress.\n\nResult: The password for web access is compromise.\n");
			window.location.href = "https:" + window.location.href.substring(window.location.protocol.length);
		}
		</script>
	</td></tr>
	<?
	}
	?>


	<tr>
	  <td><div align="center"><img src="f1logo.jpg" alt="Welcome" longdesc="Scrollout F1" /></div></td>
	</tr>
	<tr class="style36">
	<td><div align="center">
	Copyright &copy;  <?= exec('date -u +%Y') ?> Author: <script type='text/javascript'>var a = new Array('il.com','an@gma','.golog','marius');document.write("<a href='mailto:"+a[3]+a[2]+a[1]+a[0]+"'>Marius Gologan</a>");</script>. All rights reserved. | GMT: <?= exec('date -u') ?>
	</div>
	</td>
	</tr>
  </table>
</div>

<div id="contacts">
<a href="mailto:mariusgologan@gmail.com">Marius Gologan</a>
<a href="mailto:contatclub@@hotmail.com">Contact us</a>
<a href="mailto:contatclub@yahoo.com">Office</a>
<? include 'spamtraps.csv' ?>
</div>

</body>
</html>
