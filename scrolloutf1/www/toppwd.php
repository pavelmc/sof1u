<!DOCTYPE html>
<html lang="en">

<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title><?php echo $_SERVER['HTTP_HOST'] ?></title>
		<meta name="Description" content="" />
		<meta name="keywords" content="" />
		<style type="text/css" media="Screen">/*\*/@import url("css/style.css");/**/</style>
		<link rel="stylesheet" href="css/nav.css">
		<script src="jquery-latest.js"></script>

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

<body>

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

		<div id="setup">
				<form name="setup" action="" method="post">
			  <? if (!empty($message)) : ?>
				<div align="center" class="<?= $message['type'] ?>"><?= $message['msg'] ?></div>
			  <? endif ; ?>
				<div>



		<table width="75%" border="0" align="center" cellpadding="0" cellspacing="0">

			<tr>
				<td width="0" align="left" valign="bottom">
					<div align="center"><img src="logo v3.png" alt="Logo" />
					</div>
				</td>

                                <td width="100%">
                                    <div id="resources">
                                    </div>
                                </td>

				</td>
			</tr>

			  <tr>
				<td colspan="2" width="100%">

<? include 'nav.php' ?>
				</td>
			  </tr>
		</table>
		</div>
