<?
define('SETUP_FILE', '/var/www/connection.cfg');

$interface=exec("sudo /sbin/ip link show | /usr/bin/awk -F ': ' '/^[0-9]*: .*: <BROADCAST,MULTICAST/ {print $2;exit;}'");
$ipaddr = exec('sudo /sbin/ifconfig | /bin/grep -v "127\.0\.0" | /bin/grep -m1 "inet .* Bcast.* Mask" | /bin/sed "s/.*addr:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *B.*/\1/"');
$ipaddr6 = exec("sudo /sbin/ip -6 a s dev ". $interface ." | /usr/bin/awk '/inet6.*scope global/ {print $2; exit;}' | /usr/bin/awk -F '/' '{print $1}'");
$maskaddr = exec('sudo /sbin/ifconfig | /bin/grep -m1 "inet .* Bcast.* Mask" | /bin/sed "s/.*Mask:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)$/\1/"');
$maskaddr6 = exec("sudo /sbin/ip -6 a s dev ". $interface ." | /usr/bin/awk '/inet6.*scope global/ {print $2; exit;}' | /usr/bin/awk -F '/' '{print $2}'");
$gwaddr = exec('sudo /sbin/route -n | /bin/grep -m1 "^0.0.0.0.*" | /bin/sed "s/^0.0.0.0 *\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *.*/\1/"');
$gwaddr6 = exec("sudo /sbin/ip -6 r s dev ". $interface ." | /usr/bin/awk '/^default/ && !/ fe80:/ {print $3; exit;}'");
$ns = exec('/bin/cat /etc/resolv.conf | /bin/grep "^nameserver " | /usr/bin/cut -d " " -f2 | /usr/bin/tr "\n" " "');
$domainsearch = exec('/bin/cat /etc/resolv.conf | /bin/grep "^search " | /usr/bin/cut -d " " -f2 | /usr/bin/tr "\n" " "');
$hostname = exec('/bin/hostname');
$dn = exec('/bin/hostname -d');


function array2file ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$str = '';
	foreach ($_POST AS $key => $value)
	{
	  $str .= $key .'=('. $value .");\n";
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
	  $phar = array('(',')');
	  $output[substr($line, 0, $position)] = substr(str_replace($phar, '', $line), $position + 1, -1);
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

	exec('sudo /var/www/bin/net.sh');
	$ipaddr = exec('sudo /sbin/ifconfig | /bin/grep -v "127\.0\.0" | /bin/grep -m1 "inet .* Bcast.* Mask" | /bin/sed "s/.*addr:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *B.*/\1/"');
	$ipaddr6 = exec("sudo /sbin/ip -6 a s dev ". $interface ." | /usr/bin/awk '/inet6.*scope global/ {print $2; exit;}' | /usr/bin/awk -F '/' '{print $1}'");
	$maskaddr = exec('sudo /sbin/ifconfig | /bin/grep -m1 "inet .* Bcast.* Mask" | /bin/sed "s/.*Mask:\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)$/\1/"');
	$maskaddr6 = exec("sudo /sbin/ip -6 a s dev ". $interface ." | /usr/bin/awk '/inet6.*scope global/ {print $2; exit;}' | /usr/bin/awk -F '/' '{print $2}'");
	$gwaddr = exec('sudo /sbin/route -n | /bin/grep -m1 "^0.0.0.0.*" | /bin/sed "s/^0.0.0.0 *\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\) *.*/\1/"');
	$gwaddr6 = exec("sudo /sbin/ip -6 r s dev ". $interface ." | /usr/bin/awk '/^default/ && !/ fe80:/ {print $3; exit;}'");
	$ns = exec('/bin/cat /etc/resolv.conf | /bin/grep "^nameserver " | /usr/bin/cut -d " " -f2 | /usr/bin/tr "\n" " "');
	$domainsearch = exec('/bin/cat /etc/resolv.conf | /bin/grep "^search " | /usr/bin/cut -d " " -f2 | /usr/bin/tr "\n" " "');
	$hostname = exec('/bin/hostname');
	$dn = exec('/bin/hostname -d');

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

<script>
function toggle(source) {
    checkboxes = $(":input[name$='day']");

    for(var i=0, n=checkboxes.length;i<n;i++) {
    checkboxes[i].checked = source.checked;
    if (source.checked==false){
	checkboxes[i].disabled = true;
    }else{
	checkboxes[i].disabled = false;
    }
  }

    if (source.checked==true){
	document.getElementById("nameserver").style.display='block';
    }else{
	document.getElementById("nameserver").style.display='none';
    }

}
</script>

	<table width="75%" border="0" align="center" cellpadding="2" cellspacing="0">
			  <tr>
				<th nowrap="nowrap">&nbsp;</th>
				<th nowrap="nowrap" class="style20">&nbsp;</th>
			  </tr>
			  <tr class="bsh">
				<td nowrap="nowrap"><span class="style24">
				<span class="mi">&#xE839;</span>&nbsp;&nbsp;&nbsp;Connect</span>
				
				</td>

				<td nowrap="nowrap" class="style24">&nbsp;</td>
			  </tr>
			  <tr class="lrsh shade1">
				<td width="25%" nowrap="nowrap"><span class="style15">
				<label>Network configuration</label>
				</span></td>
	<td width="75%" nowrap="nowrap">

<span class="mi-l">&#xEDA3;</span>
<span class="style20">
<input class="with-font" type="radio" name="network" value="0" id="network_0"<?= (isset($values['network']) && (0 == $values['network'])) ? ' checked' : '' ?> />
<label for="network_0">Auto</label>&nbsp;&nbsp;&nbsp;</span>

<span class="style20">
<input class="with-font" type="radio" name="network" value="1" id="network_1"<?= (isset($values['network']) && (1 == $values['network'])) ? ' checked' : '' ?> />
<label for="network_1">Manual</label>
</span><br />
</td>
			  </tr>
			  <tr class="lrsh shade2">
				<td width="25%" nowrap="nowrap">
				<span class="style15">
				<label for="hostname">Hostname</label>
				</span>
				</td>
				
				<td width="75%" nowrap="nowrap">
				<input style="text-align:right;" size="17" placeholder="hostname" type="text" name="hostname" id="hostname" value="<?= $hostname ?>" required />
				.<?= $dn ?>
				<span id="error-hostname" style="color: #04acec">
				</br>Use short hostname, without including the domain name. Example: ScrolloutF1</br>
				The intended long hostname (FQDN) will be made using this hostname + the first domain in ROUTE panel.</span>

                                    <script type="text/javascript">
                                    function validatehostname(hostname) {
                                        var hostnameReg = /^([\w-]+\.[\w-]+([\.\w-]+)?)?$/;
                                        if( hostnameReg.test( hostname ) ) {
                                        $('#error-hostname').show();
                                        } else {
                                        $('#error-hostname').hide();
                                        }
                                        }
                                $(function(){
                                        $('#error-hostname').hide();
                                        $('#hostname').live('input propertychange',function(){
                                        var Addresshostname=$(this).val();
                                        validatehostname(Addresshostname);
                                        });
                                        });
                                    </script>

				</td>
			  </tr>



			  <tr class="lrsh shade1">
				<td width="25%" nowrap="nowrap"><span class="style15">
				<label for="ip">Local IP address</label>
				</span></td>
				
				<td width="75%" nowrap="nowrap">
				IPv4: <input size="12" placeholder="IPv4 address" type="text" name="ip" id="ip" value="<?= $ipaddr ?>"  required />
				&nbsp;
				IPv6: <input size="22" placeholder="IPv6 address" type="text" name="ipv6" id="ipv6" value="<?= $ipaddr6 ?>" />
				&nbsp;
				<label for="port">Additional SMTP Ports:</label>
				<input placeholder="2525,3000:4000" type="text" name="port" id="port" value="<?= $values['port'] ?>" size="10" />
				
				</td>
			  </tr>

			  <tr class="lrsh shade2">
				<td width="25%" nowrap="nowrap"><span class="style15">
				<label for="mask">Mask</label>
				</span></td>
				<td width="75%" nowrap="nowrap">
				IPv4: <input size="12" placeholder="IPv4 Network mask" name="mask" type="text" id="mask" value="<?= $maskaddr ?>"  required/>
				&nbsp;
				IPv6: <input size="22" placeholder="IPv6 Network mask" name="mask6" type="text" id="mask6" value="<?= $maskaddr6 ?>" />
				</td>
			  </tr>
			  <tr class="lrsh shade1">
				<td width="25%" nowrap="nowrap"><span class="style15">
				<label for="gateway">Gateway</label>
				</span></td>
				<td width="75%" nowrap="nowrap">
				IPv4: <input size="12" placeholder="IPv4 Router" name="gateway" type="text" id="gateway" value="<?= $gwaddr ?>"  required/>
				&nbsp;
				IPv6: <input size="22" placeholder="IPv6 Router" name="gateway6" type="text" id="gateway6" value="<?= $gwaddr6 ?>" />
				</td>
			  </tr>
			  <tr class="lrsh shade2">
				<td width="25%" nowrap="nowrap"><span class="style15">
				<label for="dns1">DNS Servers</label>
				</span></td>
				<td width="75%" nowrap="nowrap">
				IPv*: <input placeholder="DNS servers separated by space: 192.168.1.1 192.168.1.2 ::1 2001:4860:4860::8888" name="dns1" type="text" id="dns1" value="<?= $ns ?>" size="80" required /></td>
			  </tr>
			  <tr class="lrsh shade1">
				<td nowrap="nowrap"><span class="style15">
				<label for="dns3">DNS Suffixes Search</label>
				</span></td>
				<td nowrap="nowrap" class="style20"><input placeholder="Optional local.domain suffix search" name="dnssuffix" type="text" id="dns3"
				value="<?= $domainsearch ?>" size="50" /></td>
			  </tr>
			  <tr class="lrsh shade2">
				<td style="word-wrap: break-space"><span class="style15">
				<label for="caching">Internal DNS Server</label>
				</span>
                                        <a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
                                        <? include 'tooltips/nameserver' ?>
					</span></a>
					<br/>
					(optional)
					</td>

				<td style="word-wrap: break-word;">
				<input type="checkbox" name="caching" value="1" onClick="toggle(this)" id="caching"<?= (isset($values['caching']) && (1 == $values['caching'])) ? ' checked' : '' ?> />
				<label for="caching">Use internal DNS server (recommended)</label>

				<div id="nameserver" name="nameserver" style="display: none;">
				<p>
				Internal DNS server (nameserver caching) improves spam detection and Bayesian training.
				</p>

				<span class="style15">Training Days</span> (optional)<br/>
				<table align="left" border="0" width="0%" cellpadding="0" cellspacing="5">
				<tbody>
				<tr>

				<th width="75px" align="left">
				<label for="monday">Mondays</label>
				</th>

				<th width="75px" align="left">
				<label for="tuesday">Tuesdays</label>
				</th>

				<th width="75px" align="left">
				<label for="wednesday">Wednesdays</label>
				</th>

				<th width="75px" align="left">
				<label for="thursday">Thursdays</label>
				</th>

				<th width="75px" align="left">
				<label for="friday">Fridays</label>
				</th>

				<th width="75px" align="left">
				<label for="saturday">Saturdays</label>
				</th>

				<th width="75px" align="left">
				<label for="sunday">Sundays</label>
				</th>
				</tr>

				<tr>
				<td>
				<input type="checkbox" name="monday" value="1" id="monday"<?= (isset($values['monday']) && (1 == $values['monday'])) ? ' checked' : '' ?> />
				</td>

				<td>
				<input type="checkbox" name="tuesday" value="2" id="tuesday"<?= (isset($values['tuesday']) && (2 == $values['tuesday'])) ? ' checked' : '' ?> />
				</td>

				<td>
				<input type="checkbox" name="wednesday" value="3" id="wednesday"<?= (isset($values['wednesday']) && (3 == $values['wednesday'])) ? ' checked' : '' ?> />
				</td>

				<td>
				<input type="checkbox" name="thursday" value="4" id="thursday"<?= (isset($values['thursday']) && (4 == $values['thursday'])) ? ' checked' : '' ?> />
				</td>

				<td>
				<input type="checkbox" name="friday" value="5" id="friday"<?= (isset($values['friday']) && (5 == $values['friday'])) ? ' checked' : '' ?> />
				</td>

				<td>
				<input type="checkbox" name="saturday" value="6" id="saturday"<?= (isset($values['saturday']) && (6 == $values['saturday'])) ? ' checked' : '' ?> />
				</td>

				<td>
				<input type="checkbox" name="sunday" value="7" id="sunday"<?= (isset($values['sunday']) && (7 == $values['sunday'])) ? ' checked' : '' ?> />
				</td>

				</tr>
				</tbody>
				</table>


				</div>

				</td>

			  </tr>

			  <tr>
				<td nowrap="nowrap">&nbsp;</td>
				<td nowrap="nowrap" class="style20">&nbsp;</td>
			  </tr>
		  </table>
<div>
			<div align="center">
			  <input type="submit" class="mi-l" value=" &#xE10B " title="or Press ENTER" alt="or Press ENTER" />
			  </div>
		</div>
	  </form>
	</div>
<? include 'footer.php' ?>


</body>
</html>

