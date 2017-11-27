
<?


if (isset($_GET['service'])) {

$service = $_GET['service'];

shell_exec('sudo /var/www/bin/service.sh'.' '.EscapeShellArg($service));
}

?>


<?
$mem=shell_exec('sudo /var/www/bin/header.sh mem');
$cpu=shell_exec('sudo /var/www/bin/header.sh cpu');
$disk=shell_exec('sudo /var/www/bin/header.sh disk');
$netw=shell_exec('sudo /var/www/bin/header.sh network');
$services=shell_exec('sudo /var/www/bin/header.sh services');

?>


<div id="header" class="header">
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
			  <tr bgcolor="">
				<td bgcolor="" class="styleh">
				<div>
				<? print "$netw $cpu $mem $disk $services" ?>
				</div>
				 </td>
			  </tr>
		</table>

</div>

