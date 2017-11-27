<?
define('SETUP_FILE', '/var/www/traffic.cfg');
$keys = shell_exec('sudo /var/www/bin/dkim.sh showkeys');
$pwd = shell_exec('sudo /var/www/bin/pwd.sh create');

function array2file ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$str = '';
	foreach ($_POST AS $key => $value)
	{
	  $str .= $key ."=('" .str_replace(array("\r\n","\r","\n"),"' '",str_replace(" ",'',$value))."');\n";
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
	  $phar = array('(',')',"'");
	  $output[substr($line, 0, $position)] = substr(str_replace($phar,'',$line), $position + 1, -1);
	  unset($position);
	}

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
		$_POST['domain'] = strtolower(implode("\n", $_POST['domain']));
		$_POST['transport'] = strtolower(implode("\n", $_POST['transport']));
		$_POST['mynets'] = implode("\n", $_POST['mynets']);
		$_POST['ipsecips'] = implode("\n", $_POST['ipsecips']);
		$_POST['ipseckey'] = implode("\n", $_POST['ipseckey']);
		$_POST['assips'] = implode("\n", $_POST['assips']);
		$_POST['quarantine'] = strtolower(implode("\n", $_POST['quarantine']));
		$_POST['tag'] = implode("\n", $_POST['tag']);
		$_POST['sbj'] = implode("\n", $_POST['sbj']);
		$_POST['lsrv'] = strtolower(implode("\n", $_POST['lsrv']));
		$_POST['ldap'] = implode("\n", $_POST['ldap']);
		$_POST['spam'] = implode("\n", $_POST['spam']);
		$_POST['spamd'] = implode("\n", $_POST['spamd']);
		$_POST['bounce'] = implode("\n", $_POST['bounce']);
		$_POST['virus'] = implode("\n", $_POST['virus']);
		$_POST['ban'] = implode("\n", $_POST['ban']);
		$_POST['ldom'] = implode("\n", $_POST['ldom']);
		$_POST['luser'] = implode("\n", $_POST['luser']);
		$_POST['lpass'] = implode("\n", $_POST['lpass']);
		$_POST['block'] = implode("\n", $_POST['block']);
		$_POST['cutoff'] = implode("\n", $_POST['cutoff']);
		$_POST['hrelays'] = strtolower(implode("\n", $_POST['hrelays']));
		$_POST['clones'] = strtolower(implode("\n", $_POST['clones']));
		$_POST['redirect'] = strtolower(implode("\n", $_POST['redirect']));
		$_POST['senders'] = strtolower(implode("\n", $_POST['senders']));
		$_POST['sendersd'] = strtolower(implode("\n", $_POST['sendersd']));
		$_POST['receivers'] = strtolower(implode("\n", $_POST['receivers']));
		$_POST['receiversd'] = strtolower(implode("\n", $_POST['receiversd']));
		$_POST['urelays'] = implode("\n", $_POST['urelays']);
		$_POST['prelays'] = implode("\n", $_POST['prelays']);
		$_POST['encrypt'] = implode("\n", $_POST['encrypt']);
		$_POST['report'] = implode("\n", $_POST['report']);
		$_POST['spamtraps'] = strtolower(implode("\n", $_POST['spamtraps']));
		$_POST['d_dkim'] = implode("\n", $_POST['d_dkim']);
		$_POST['srs'] = implode("\n", $_POST['srs']);
		$_POST['srsto'] = implode("\n", $_POST['srsto']);
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
/**
 *	Load data from file
 */
$values = file2array();

?>
<? include 'top.php' ?>
			<table width="75%" border="0" align="center" cellpadding="2" cellspacing="0">
			  <tr>
				<th width="10%" nowrap="nowrap">&nbsp;</th>
				<th width="90%" nowrap="nowrap" class="style20">&nbsp;</th>
			  </tr>
			  <tr class="bsh">
				<td nowrap="nowrap"><span class="style24"><span class="mi">&#xE13C</span>&nbsp;&nbsp;&nbsp;Route</span></td>
				<td nowrap="nowrap" class="style20">&nbsp;</td>
			  </tr>
			  <tr class="lrsh shade1">
				<td nowrap="nowrap"><span class="style15">Organization</span>
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<b>Organization name</b> is a part of the SMTP banner.<br/><br/>
					Recommendation:<br/>
					Don't use special characters.<br/><br/>
					SMTP banner example:<br/>
					220 Hostname.Domain.tld ESMTP Organization or company name
					</span></a>

				</td>
				<td nowrap="nowrap" class="style20">
				Name:<input placeholder="Company name" name="organization" type="text" id="organization" value="<?= !empty($values['organization']) ? $values['organization'] : ''?>" size="20" required/>
				Web support:<input placeholder="http://www.domain.com" name="web" type="text" id="web" value="<?= !empty($values['web']) ? $values['web'] : ''?>" size="20" />
				Phone support:<input placeholder="+40.000.00.00" name="tel" type="text" id="web" value="<?= !empty($values['tel']) ? $values['tel'] : ''?>" size="15" />
				</td>
			  </tr>

			  <tr class="lrsh shade bsh">
					<td nowrap="nowrap" align="center">

					<a class="tooltip" href="#">
					<i class="mi" style="font-style: normal;">&#xE909;&#xE7EA;&#xEDB3;&#xEA62;</i>

					<span>
					<b>Domain Names</b> is an <u>important</u> part of the SMTP banner, Helo/Ehlo message and<br/>
					all other processes.<br/>
					First domain in line will be used as primary domain.<br /><br />
					Recommendations:<br/>
					<li> Don't use special characters.</li>
					<li> At least one of the MX records of each domain must be pointing to this hostname.</li>
					<li> Make sure that the coresponding IP address has a valid reverse DNS record
					(aka PTR record) pointing to this hostname.</li>
					<li> Make sure that the router or firewall is forwarding the port no. 25 to this host/IP.</li><br/>
					SMTP banner example:<br/>
					<i>220 Hostname.<b>PrimaryDomain</b>.tld ESMTP Organization or company name</i><br/><br/>
					HELO/EHLO message examples:<br/>
					<i>helo hostname.<b>PrimaryDomain</b>.tld<br/>
					ehlo hostname.<b>PrimaryDomain</b>.tld</i>
					</span></a>


				</td>
				<td colspan="2" class="master">

				<?
				if (!empty($values['domain']))
				{
				  $domains = explode(' ', $values['domain']);
				}
				if (!empty($values['transport']))
				{
				  $transport = explode(' ', $values['transport']);
				}
				if (!empty($values['mynets']))
				{
				  $mynet = explode(' ', $values['mynets']);
				}
				if (!empty($values['ipsecips']))
				{
				  $ipsecips = explode(' ', $values['ipsecips']);
				}
				if (!empty($values['ipseckey']))
				{
				  $ipseckey = explode(' ', $values['ipseckey']);
				}

				if (!empty($values['assips']))
				{
				  $assip = explode(' ', $values['assips']);
				}
				if (!empty($values['quarantine']))
				{
				  $quarantines = explode(' ', $values['quarantine']);
				}
				if (!empty($values['tag']))
				{
				  $tags = explode(' ', $values['tag']);
				}
				if (!empty($values['lsrv']))
				{
				  $lsrvs = explode(' ', $values['lsrv']);
				}
				if (!empty($values['ldap']))
				{
				  $ldapall = explode(' ', $values['ldap']);
				}
				if (!empty($values['spam']))
				{
				  $spamall = explode(' ', $values['spam']);
				}
				if (!empty($values['spamd']))
				{
				  $spamdall = explode(' ', $values['spamd']);
				}
				if (!empty($values['bounce']))
				{
				  $bounceall = explode(' ', $values['bounce']);
				}
				if (!empty($values['virus']))
				{
				  $virusall = explode(' ', $values['virus']);
				}
				if (!empty($values['ban']))
				{
				  $banall = explode(' ', $values['ban']);
				}
				if (!empty($values['ldom']))
				{
				  $ldoms = explode(' ', $values['ldom']);
				}
				if (!empty($values['luser']))
				{
				  $lusers = explode(' ', $values['luser']);
				}
				if (!empty($values['lpass']))
				{
				  $lpasses = explode(' ', $values['lpass']);
				}
				if (!empty($values['block']))
				{
				  $blocks = explode(' ', $values['block']);
				}
				if (!empty($values['cutoff']))
				{
				  $cutoffs = explode(' ', $values['cutoff']);
				}
				if (!empty($values['urelays']))
				{
				  $urelays = explode(' ', $values['urelays']);
				}
				
				if (!empty($values['prelays']))
				{
				  $prelays = explode(' ', $values['prelays']);
				}
				
				if (!empty($values['hrelays']))
				{
				  $hrelays = explode(' ', $values['hrelays']);
				}
				if (!empty($values['clones']))
				{
				  $clones = explode(' ', $values['clones']);
				}

				if (!empty($values['redirect']))
				{
				  $redirect = explode(' ', $values['redirect']);
				}

				if (!empty($values['senders']))
				{
				  $senders = explode(' ', $values['senders']);
				}

				if (!empty($values['sendersd']))
				{
				  $sendersd = explode(' ', $values['sendersd']);
				}

				if (!empty($values['receivers']))
				{
				  $receivers = explode(' ', $values['receivers']);
				}

				if (!empty($values['receiversd']))
				{
				  $receiversd = explode(' ', $values['receiversd']);
				}

				if (!empty($values['sbj']))
				{
				  $sbj = explode(' ', $values['sbj']);
				}

				if (!empty($values['encrypt']))
				{
				  $encrypt = explode(' ', $values['encrypt']);
				}

				if (!empty($values['report']))
				{
				  $report = explode(' ', $values['report']);
				}

				if (!empty($values['spamtraps']))
				{
				  $spamtraps = explode(' ', $values['spamtraps']);
				}


				if (!empty($values['d_dkim']))
				{
				  $d_dkim = explode(' ', $values['d_dkim']);
				}

				if (!empty($values['srs']))
				{
				  $srs = explode(' ', $values['srs']);
				}
				if (!empty($values['srsto']))
				{
				  $srsto = explode(' ', $values['srsto']);
				}


				$cycle_values = count($domains) > count($transport) ? $domains : $transport;
				foreach ($cycle_values AS $count => $value)
				{
	$bgcolor = '';
	$bgcolor = 0 == $count % 2 ? '#494949"' : '#393939';
	$style = 0 == $count % 2 ? 'background-color: #292929' : 'background-color: #393939';
	$class = 0 == $count % 2 ? 'shade1' : 'shade2';

				?>
				  <div class="input shade3 bsh">
					<a class="tooltip" href="#">
					    <i class="mi" style="font-style: normal;">&#xE7EA;&#xEDB3;&#xEA62;&#xE168;</i>
					<span>
					<? include 'tooltips/domain' ?>
					</span></a>
					<input placeholder="example.com" size="25" type="text" name="domain[]" value="<?= !empty($domains[$count]) ? $domains[$count] : '' ?>" id="domain<?= $count + 1 ?>" class="domain<?= $count + 1 ?> domain"/>

					<a class="tooltip" href="#">
					    <i class="mi" style="font-style: normal;">&#xE7EA;&#xEDB3;&#xEA62;&#xE716;</i>
					<span>
					<? include 'tooltips/outbound' ?>
					</span></a>

					<input placeholder="[mail.server.com] or [ip.add.re.ss]" size="50" type="text" name="transport[]" value="<?= !empty($transport[$count]) ? $transport[$count] : '' ?>" id="transport<?= $count + 1 ?>"/>

				    <script type="text/javascript">
				    function validatetransport<?= $count + 1 ?>(transport<?= $count + 1 ?>) {
					var transport<?= $count + 1 ?>Reg = /^(\[[\w-]+\.[\w-]+\.[\w-]+(\.[\w-]+)?\](:[\d-]+)?)?$/;
					if( !transport<?= $count + 1 ?>Reg.test( transport<?= $count + 1 ?> ) ) {
        				$('#error-transport<?= $count + 1 ?>').show();
    					} else {
        				$('#error-transport<?= $count + 1 ?>').hide();
    					}
					}
				$(function(){
					$('#error-transport<?= $count + 1 ?>').hide();
				        $('#transport<?= $count + 1 ?>').live('input propertychange',function(){
				        var Addresstransport<?= $count + 1 ?>=$(this).val();
				        validatetransport<?= $count + 1 ?>(Addresstransport<?= $count + 1 ?>);
				        });
					});
				    </script>


			<span id="error-transport<?= $count + 1 ?>" style="color: #04acec"></br>For server name or IP address use brackets: [server.example.com]</span>
                        <script type="text/javascript">
                        $(document).ready(function(){
                            var $this = $('#<?= $domains[$count] ?>_spam'.replace(/\./g,'\\.'));

                            $('#<?= $domains[$count] ?>_spam_btn'.replace(/\./g,'\\.')).click(function() {
                            $this.slideToggle("fast");
                            });
                        });
                         </script>

                        <script type="text/javascript">
                        $(document).ready(function(){
                            var $this = $('#<?= $domains[$count] ?>_IN'.replace(/\./g,'\\.'));

                            $('#<?= $domains[$count] ?>_IN_btn'.replace(/\./g,'\\.')).click(function() {
                            $this.slideToggle("fast");
                            });
                        });
                         </script>

                        <script type="text/javascript">
                        $(document).ready(function(){
                            var $this = $('#<?= $domains[$count] ?>_OUT'.replace(/\./g,'\\.'));

                            $('#<?= $domains[$count] ?>_OUT_btn'.replace(/\./g,'\\.')).click(function() {
                            $this.slideToggle("fast");
                            });
                        });
                         </script>


                        <script type="text/javascript">
                        $(document).ready(function(){
                            var $this = $('#<?= $domains[$count] ?>_IPSec'.replace(/\./g,'\\.'));

                            $('#<?= $domains[$count] ?>_IPSec_btn'.replace(/\./g,'\\.')).click(function() {
                            $this.slideToggle("fast");
                            });
                        });
                         </script>



			<div style="text-align: right; display: inline-block;">
			<ul style="margin: 0 0 0 -40px;">
<?
if ($domains[$count] != '')
{
?>

			<div class="button1" href="javascript:void(0)" id="<?= $domains[$count] ?>_spam_btn"><i class="fa fa-recycle fa-fw fa-2x"></i>
			<div class="style11">Quarantine</div>
			</div>
			<div class="button1" href="javascript:void(0)" id="<?= $domains[$count] ?>_IN_btn"><i class="fa fa-sign-in fa-fw fa-2x"></i>
			<div class="style11">Inbound</div>
			</div>

			<div class="button1" href="javascript:void(0)" id="<?= $domains[$count] ?>_OUT_btn"><i class="fa fa-sign-out fa-fw fa-2x"></i>
			<div class="style11">Outbound</div>
			</div>

<!--			<div class="button1" href="javascript:void(0)" id="<?= $domains[$count] ?>_IPSec_btn">&nbsp;IPSec&nbsp;
			<div class="style11">IPSec</div>
			</div>
 -->



<?
}
?>



			</ul>
			</div>

			<?= 0 < $count ? '
			<a class="remove" href="javascript: void(0);"><div class="button1"><span class="mi">&#xE74D</span><div class="style11">Delete</div></div></a>'
			 : '' ?>


			<div id="<?= $domains[$count] ?>_spam" class="card" style="display: none;">
			<span class="label1">&nbsp;<i class="fa fa-recycle fa-2x"></i> QUARANTINE <?= $domains[$count] ?>&nbsp;</span>

		<ul>
		<table class="shade3" width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
		<tr>
		<td width="0%" nowrap="nowrap">
			<span class="<?= $style ?>">-&infin;</span>
			<label for="tags<?= $count + 1 ?>">&lArr;ALLOW&rArr;</label>
				<input placeholder="5.0" size="3" name="tag[]"  id="rangeinput" type="text" 
				value="<?= !empty($tags[$count]) ? $tags[$count] : '' ?>" /> 

			<label for="sbj<?= $count + 1 ?>"> &lArr;TAG as</label>
			<input placeholder="Spam" size="2" type="text" name="sbj[]" 
					value="<?= !empty($sbj[$count]) ? $sbj[$count] : '' ?>" id="sbj<?= $count + 1 ?>" />

			<label for="blocks<?= $count + 1 ?>">&rArr;</label>
				<input placeholder="7.0" size="5" name="block[]"  id="blocks<?= $count + 1 ?>" type="text"
				value="<?= !empty($blocks[$count]) ? $blocks[$count] : '' ?>" />
			<label for="blocks<?= $count + 1 ?>">&lArr;</label>

			<label for="quarantines<?= $count + 1 ?>"><b>Quarantine</b> to:</label>
		</td>
		<td width="100%" nowrap="nowrap">
					<input placeholder="e.g.: quarantine@<?= $domains[$count] ?>" size="30" type="text" name="quarantine[]" 
					value="<?= !empty($quarantines[$count]) ? $quarantines[$count] : '' ?>" id="quarantines<?= $count + 1 ?>" />

			<label for="cutoff<?= $count + 1 ?>">&rArr;</label>
			<input placeholder="25" size="5" name="cutoff[]"  id="cutoffs<?= $count + 1 ?>" type="text"
			value="<?= !empty($cutoffs[$count]) ? $cutoffs[$count] : '' ?>" /> &lArr;BLOCK&rArr; +&infin;
		</td>
		</tr>

		<tr>
		<td></td>
		<td>
			<br/>
			<input class="with-font" type="checkbox" name="report[]" value="checked" id="report<?= $count + 1 ?>" <?= (!empty($report[$count]) && ("checked" == $report[$count])) ? $report[$count] : '' ?> />
			<label for="report<?= $count + 1 ?>">Do not send detailed report</label>

			<br/>
			<input class="with-font" type="checkbox" name="spam[]" value="checked" id="spamall<?= $count + 1 ?>" <?= (!empty($spamall[$count]) && ("checked" == $spamall[$count])) ? $spamall[$count] : '' ?> />
			<label for="spamall<?= $count + 1 ?>">Do not send spam to quarantine (erase spam emails)</label>

			<br/>
			<input class="with-font" type="checkbox" name="virus[]" value="checked" id="virusall<?= $count + 1 ?>" <?= (!empty($virusall[$count]) && ("checked" == $virusall[$count])) ? $virusall[$count] : '' ?> />
			<label for="virusall<?= $count + 1 ?>">Do not send virus to quarantine (erase virus emails)</label>

			<br/>
			<input class="with-font" type="checkbox" name="ban[]" value="checked" id="banall<?= $count + 1 ?>" <?= (!empty($banall[$count]) && ("checked" == $banall[$count])) ? $banall[$count] : '' ?> />
			<label for="banall<?= $count + 1 ?>">Do not send banned files to quarantine (erase emails with banned files)</label>
		</td>
		</tr>
		</table>
			</ul>
			</div>

			<div id="<?= $domains[$count] ?>_IN" class="card" style="display: none">
			<span class="label1">&nbsp;<i class="fa fa-sign-in fa-2x"></i> INBOUND <?= $domains[$count] ?>&nbsp;</span>
			<ul>
			<div class="bsh shade3">
			<br/>
			<li><span class="<?= $style ?>"><b>SMTP Authentication</b><br /></span></li>
			<ul><ul>
			<?= shell_exec('/var/www/bin/pwd.sh list'.' '.EscapeShellArg($domains[$count])) ?>
			</ul></ul>
			</div>
			</ul>
			<ul>
			<div class="bsh shade3"><br/>
				<li><span class="<?= $style ?>"><b>Trust networks</b></span>
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				<? include 'tooltips/subnets' ?>
				</span><br/></a></li>
				<ul><ul>
				<label for="mynets<?= $count + 1 ?>">CIDR addr.:</label>
				<input placeholder="e.g.: 172.16.0.0/12,10.0.0.0/8" size="70" type="text" name="mynets[]" value="<?= !empty($mynet[$count]) ? $mynet[$count] : '' ?>" id="mynets<?= $count + 1 ?>" />
	                        <span id="cidr-error-mynets<?= $count + 1 ?>" style="color: #04acec"></br>IP address(es) must be in <b>CIDR format:</b> 192.168.1.0/24, !192.168.1.1/32</span>
				</ul></ul>
				    <script type="text/javascript">
				    function validateCidrmynets<?= $count + 1 ?>(mynets<?= $count + 1 ?>) {
					var cidrReg = /[\d-]+\.[\d-]+\.[\d-]+\.[\d-]+\/[\d-]+/;
					if( !cidrReg.test( mynets<?= $count + 1 ?> ) ) {
        				$('#cidr-error-mynets<?= $count + 1 ?>').show();
    					} else {
        				$('#cidr-error-mynets<?= $count + 1 ?>').hide();
    					}
					}
				$(function(){
					$('#cidr-error-mynets<?= $count + 1 ?>').hide();
				        $('#mynets<?= $count + 1 ?>').live('input propertychange',function(){
				        var cidrAddressmynets<?= $count + 1 ?>=$(this).val();
				        validateCidrmynets<?= $count + 1 ?>(cidrAddressmynets<?= $count + 1 ?>);
				        });
					});
				    </script>
			</div>
			</ul>
			<ul>
			<div class="bsh shade3">
			<br/>
			<li><span class="<?= $style ?>"><b>Validate recipients in this Active Directory, OpenLDAP, Zimbra or Lotus Domino</b><br /></span></li>
			<ul><ul>
			<label for="lsrvs<?= $count + 1 ?>">Server:</label>
				<input placeholder="host.domain.com:port" size="15" name="lsrv[]"  id="lsrvs<?= $count + 1 ?>" type="text" 
				value="<?= !empty($lsrvs[$count]) ? $lsrvs[$count] : '' ?>" />

			<label for="ldoms<?= $count + 1 ?>"> Forest Domain:</label>
				<input placeholder="domain.local" size="15" name="ldom[]"  id="ldoms<?= $count + 1 ?>" type="text"
				value="<?= !empty($ldoms[$count]) ? $ldoms[$count] : '' ?>" />
			<br/>
			<label for="lusers<?= $count + 1 ?>">USER Account:</label>
				<input placeholder="User, NOT Administrator" size="15" name="luser[]"  id="lusers<?= $count + 1 ?>" type="text"
				value="<?= !empty($lusers[$count]) ? $lusers[$count] : '' ?>" />

			<label for="lpasses<?= $count + 1 ?>"> Password:</label>
				<input placeholder="password" size="15" name="lpass[]"  id="lpasses<?= $count + 1 ?>" type="password"
				value="<?= !empty($lpasses[$count]) ? $lpasses[$count] : '' ?>" />
	                        <span id="error-ldoms<?= $count + 1 ?>" style="color: #04acec"></br>Forest Domain must be in a valid format: domain.local</span>
	                        <span id="error-lpasses<?= $count + 1 ?>" style="color: #04acec"></br>Password should not contain characters like &,#,(,)</span>

				    <script type="text/javascript">
				    function validateldoms<?= $count + 1 ?>(ldoms<?= $count + 1 ?>) {
					var ldoms<?= $count + 1 ?>Reg = /^([\w-]+\.[\w-]+)?$/;
					if( !ldoms<?= $count + 1 ?>Reg.test( ldoms<?= $count + 1 ?> ) ) {
        				$('#error-ldoms<?= $count + 1 ?>').show();
    					} else {
        				$('#error-ldoms<?= $count + 1 ?>').hide();
    					}
					}
				$(function(){
					$('#error-ldoms<?= $count + 1 ?>').hide();
				        $('#ldoms<?= $count + 1 ?>').live('input propertychange',function(){
				        var Addressldoms<?= $count + 1 ?>=$(this).val();
				        validateldoms<?= $count + 1 ?>(Addressldoms<?= $count + 1 ?>);
				        });
					});
				    </script>

				    <script type="text/javascript">
				    function validatelpasses<?= $count + 1 ?>(lpasses<?= $count + 1 ?>) {
					var lpasses<?= $count + 1 ?>Reg = /[\!\#\$\&]/;
					if( lpasses<?= $count + 1 ?>Reg.test( lpasses<?= $count + 1 ?> ) ) {
        				$('#error-lpasses<?= $count + 1 ?>').show();
    					} else {
        				$('#error-lpasses<?= $count + 1 ?>').hide();
    					}
					}
				$(function(){
					$('#error-lpasses<?= $count + 1 ?>').hide();
				        $('#lpasses<?= $count + 1 ?>').live('input propertychange',function(){
				        var Addresslpasses<?= $count + 1 ?>=$(this).val();
				        validatelpasses<?= $count + 1 ?>(Addresslpasses<?= $count + 1 ?>);
				        });
					});
				    </script>
<br/>
			<input class="with-font" type="checkbox" name="ldap[]" value="checked" id="ldapall<?= $count + 1 ?>" <?= (!empty($ldapall[$count]) && ("checked" == $ldapall[$count])) ? $ldapall[$count] : '' ?> />
			<label for="ldapall<?= $count + 1 ?>">Secure connection with AD Server</label>
			</ul></ul>
			</div>
			<div class="bsh shade3">
					<br/>
					<span class="mi">&#xE1D5; </span>
					<li><label for="receivers<?= $count + 1 ?>">
					<b>Backup incoming emails sent TO <?= $domains[$count] ?>: </b></label>
					    
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<? include 'tooltips/recipient_bcc' ?>
					</span></a></li>
					
					<ul><ul>
					FROM: anywhere 
					TO:
					<input placeholder="anyone" size="10" type="text" name="receivers[]" value="<?= !empty($receivers[$count]) ? $receivers[$count] : '' ?>" id="receivers<?= $count + 1 ?>" />
					@<?= $domains[$count] ?> &rArr; BCC:
					<input placeholder="mailbox@domain.com" size="20" type="text" name="receiversd[]" value="<?= !empty($receiversd[$count]) ? $receiversd[$count] : '' ?>" id="receiversd<?= $count + 1 ?>" />
					</ul></ul>
			</div>

			<div class="bsh shade3">
					<br/>
					<span class="mi">&#xE89A; </span>
					<li><label for="clones<?= $count + 1 ?>"><b>Clone incoming emails for recipients@<?= $domains[$count] ?>
					<span class="style15 second">&rArr;</span> recipients@(SUB.)DOMAIN(s):</b></label>
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<? include 'tooltips/clones' ?>
					</span></a></li>
					
					<ul><ul>
					RECIPIENTS@<input placeholder="(sub.)domain1.com,(sub.)domain2.com" size="70" type="text" name="clones[]" value="<?= !empty($clones[$count]) ? $clones[$count] : '' ?>" id="clones<?= $count + 1 ?>" />
					</ul></ul>
			</div>
			<div class="bsh shade3">
					<br/>
					<li><label for="redirect<?= $count + 1?>"><b>Redirect all emails for recipients@<?= $domains[$count] ?>
					<span class="style15 second">&rArr;</span> mailbox@domain.com:</b></label>
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<? include 'tooltips/redirect_all' ?>
					</span></a></li>
					<ul><ul>
					RECIPIENTS@<?= $domains[$count] ?> &rArr; TO:
                                        <input placeholder="mailbox@domain.com" size="20" type="text" name="redirect[]" value="<?= !empty($redirect[$count]) ? $redirect[$count] : '' ?>" id="redirect<?= $count + 1 ?>" />
					</ul></ul>
			</div>
			<div class="bsh shade3">
					<br/>
					<li><label for="spamtraps<?= $count + 1 ?>"><b>Declare old removed addresses (known by spammers) as spam traps</b> (separate by commas ",")
					</label>
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<? include 'tooltips/spam_traps' ?>
					</span></a></li>
					
					<ul><ul>
					<input placeholder="former-employee1, former-employee2" size="70" type="text" name="spamtraps[]" value="<?= !empty($spamtraps[$count]) ? $spamtraps[$count] : '' ?>" id="spamtraps<?= $count + 1 ?>" /> @ <?= $domains[$count]; ?>
					</ul></ul>
					</div>



			</ul>
			</div>

			<div id="<?= $domains[$count] ?>_OUT" class="card" style="display: none">
			<span class="label1">&nbsp;<i class="fa fa-sign-out fa-2x"></i> OUTBOUND <?= $domains[$count] ?>&nbsp;</span>

			<ul>
			<div class="bsh shade3">
				<br/>
				<li>
				<input class="with-font" type="checkbox" name="encrypt[]" value="checked" id="encrypt<?= $count + 1 ?>" <?= (!empty($encrypt[$count]) && ("checked" == $encrypt[$count])) ? $encrypt[$count] : '' ?> />
				<label for="encrypt<?= $count + 1 ?>">Enforce encryption with downstream server(s). Do not use unecrypted connections</label></li>
			</div>
			</ul>

			<ul>
			<div  class="bsh shade3">
				<br/>
				<li><b>Manage bounces caused by downstream server(s) <?= $transport[$count] ?></b></li>
			    <ul><ul>
				<input class="with-font" type="checkbox" name="spamd[]" value="checked" id="spamdall<?= $count + 1 ?>" <?= (!empty($spamdall[$count]) && ("checked" == $spamdall[$count])) ? $spamdall[$count] : '' ?> />
				<label for="spamdall<?= $count + 1 ?>">Downstream server(s) runs an accurate spam detection. Learn from rejected spam instead of bouncing</label>
				<br/>
				<input class="with-font" type="checkbox" name="bounce[]" value="checked" id="bounceall<?= $count + 1 ?>" <?= (!empty($bounceall[$count]) && ("checked" == $bounceall[$count])) ? $bounceall[$count] : '' ?> />
				<label for="bounceall<?= $count + 1 ?>">Reduce other bounces caused by downstream server(s)</label>
			    </ul></ul>
			</div>
			</ul>
			<div class="bsh shade3">
			<ul>
					<br/>
					<li><b>Protect the brand by certifying <?= !empty($domains[$count]) ? $domains[$count] : '' ?> domain and its IP addresses with SPF, DKIM & DMARC DNS records</b></li>

					<ul><ul>
					<div>
					<?= !empty($domains[$count]) ?
					'<p>'.$domains[$count].'. 3600 TXT<br/>
					<input class="style99" size="100" disabled="disabled" type="text"
					value="v=spf1 a mx -all" />' : 
					'' ?>
					<br>
					<input class="with-font" type="checkbox" name="srs[]" value="checked" id="srs<?= $count + 1 ?>" <?= (!empty($srs[$count]) && ("checked" == $srs[$count])) ? $srs[$count] : '' ?> />
					<label for="srs<?= $count + 1 ?>">Disable SRS for messages sent FROM <?= $domains[$count] ?></label>
					<br>
					<input class="with-font" type="checkbox" name="srsto[]" value="checked" id="srsto<?= $count + 1 ?>" <?= (!empty($srsto[$count]) && ("checked" == $srsto[$count])) ? $srsto[$count] : '' ?> />
					<label for="srsto<?= $count + 1 ?>">Disable SRS for messages sent TO <?= $domains[$count] ?></label>
					</p>
					</div>


					<div><p> <?= shell_exec('sudo /var/www/bin/dkim.sh'.' '.EscapeShellArg($keys).' '.EscapeShellArg($domains[$count])); ?>
					</br>
					<input class="with-font" type="checkbox" name="d_dkim[]" value="checked" id="d_dkim<?= $count + 1 ?>" <?= (!empty($d_dkim[$count]) && ("checked" == $d_dkim[$count])) ? $d_dkim[$count] : '' ?> />
					<label for="d_dkim<?= $count + 1 ?>">Disable DKIM for <?= $domains[$count] ?></label>
					</p></div>

					<div>
					<?=
					'<p>_dmarc.'.$domains[$count].'. 3600 TXT<br/>
					<input class="style99" size="100" disabled="disabled" type="text"
					value="v=DMARC1; p=quarantine; rua=mailto:abuse@'.$domains[$count].'" /></p>' 
					 ?>
					  </div>
					   
					</ul></ul>
			</div>
			<div class="bsh shade3">
					<br/>
					<li><label for="assips<?= $count + 1 ?>"><b>Assign a different local IP or IP Pool for outbound</b></label>
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<? include 'tooltips/assip' ?>
					</span></a></li>
			
			
			<ul><ul>
					<input placeholder="e.g.: 11.11.11.11, 22.22.22.22" size="75" type="text" name="assips[]" value="<?= !empty($assip[$count]) ? $assip[$count] : '' ?>" id="assips<?= $count + 1 ?>" />
			</ul></ul>
			</div>
			
			<div  class="bsh shade3">
					<br/>
					<li><label for="hrelays<?= $count + 1 ?>"><b>Forward mail from @<?= $domains[$count] ?>
					<span class="style15 second">&rArr;</span> to smart host:</b></label>
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<? include 'tooltips/hrelays' ?>
					</span></a></li>
					
					<ul><ul>
					<input placeholder="relay.server.com or [ip.add.re.ss]:port" size="35" type="text" name="hrelays[]" value="<?= !empty($hrelays[$count]) ? $hrelays[$count] : '' ?>" id="hrelays<?= $count + 1 ?>" />
					<inputplaceholder="User" size="15" type="text" name="urelays[]" value="<?= !empty($urelays[$count]) ? $urelays[$count] : '' ?>" id="urelays<?= $count + 1 ?>" />
					<inputplaceholder="Password" size="15" type="password" name="prelays[]" value="<?= !empty($prelays[$count]) ? $prelays[$count] : '' ?>" id="prelays<?= $count + 1 ?>" />
					</ul></ul>
					</div>


			<div class="bsh shade3">
					<br/>
					<li><label for="senders<?= $count + 1 ?>"><b>Backup outgoing emails sent FROM <?= $domains[$count] ?>: </b></label>
					    
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<? include 'tooltips/sender_bcc' ?>
					</span></a></li>
					
					<ul><ul>
					FROM: 
					<input placeholder="anyone" size="10" type="text" name="senders[]" value="<?= !empty($senders[$count]) ? $senders[$count] : '' ?>" id="senders<?= $count + 1 ?>" />
					@<?= $domains[$count] ?> TO: anywhere &rArr; BCC: 
					<input placeholder="mailbox@domain.com" size="20" type="text" name="sendersd[]" value="<?= !empty($sendersd[$count]) ? $sendersd[$count] : '' ?>" id="sendersd<?= $count + 1 ?>" />
					</ul></ul>
					</div>

					</ul>

					</div>










			<div id="<?= $domains[$count] ?>_IPSec" style="display: none; border: 1px dotted gray; margin:5px 5px; border-radius:5px;">
			<span class="label1">&nbsp; IPSec <?= $domains[$count] ?>&nbsp;</span>

			<ul>
			<div>

			<div class="bsh shade3">
					<br/>
					<li><label for="ipsecips<?= $count + 1 ?>">Communicate with other hosts using <b>IPSec</b> encryption. Input <b>external</b> IP or network addresses</label>
					    
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<? include 'tooltips/ipsec' ?>
					</span></a></li>
					
					<ul><ul>


				<input placeholder="e.g.: 99.16.0.0/12, 1.1.1.1:2525" size="85" type="text" name="ipsecips[]" value="<?= !empty($ipsecips[$count]) ? $ipsecips[$count] : '' ?>" id="ipsecips<?= $count + 1 ?>" />
	                        <span id="cidr-error-ipsecips<?= $count + 1 ?>" style="color: #04acec"></br>IP and network address(es) must be in <b>CIDR format:</b> 192.168.1.0/24, 192.168.1.1/32</span>


				    <script type="text/javascript">
				    function validateCidripsecips<?= $count + 1 ?>(ipsecips<?= $count + 1 ?>) {
					var cidrRegipsecips = /[\d-]+\.[\d-]+\.[\d-]+\.[\d-]+\/[\d-]+/;
					if( !cidrRegipsecips.test( ipsecips<?= $count + 1 ?> ) ) {
        				$('#cidr-error-ipsecips<?= $count + 1 ?>').show();
    					} else {
        				$('#cidr-error-ipsecips<?= $count + 1 ?>').hide();
    					}
					}
				$(function(){
					$('#cidr-error-ipsecips<?= $count + 1 ?>').hide();
				        $('#ipsecips<?= $count + 1 ?>').live('input propertychange',function(){
				        var cidrAddressipsecips<?= $count + 1 ?>=$(this).val();
				        validateCidripsecips<?= $count + 1 ?>(cidrAddressipsecips<?= $count + 1 ?>);
				        });
					});
				    </script>

<br/>

					Long authentication key: 
					<input class="shade" placeholder="e.g.: 1234ABCDabcd<.,=:-+_>{!?}" size="66" type="text" name="ipseckey[]" value="<?= !empty($ipseckey[$count]) ? $ipseckey[$count] : '' ?>" id="ipseckey<?= $count + 1 ?>" />

					</ul></ul>
					</div>

					</ul>

					</div>
				  </div>











				<?
				}
				?>
				<div class="button_add" href="javascript: void(0);"><span class="mi">&#xE948</span>
				<div class="style11">New domain</div>
				</div>

				  <input type="hidden" id="total_inputs" value="<?= $count + 1 ?>">
				</td>
			  </tr>


			  <tr class="lrsh shade1">
				<td valign="top" nowrap="nowrap"><span class="style15">ISP or Smarthost</span>
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<b>Optional: </b>Input an ISP hostname or [ip.add.re.ss] where you want to forward all<br/>
					your outgoing messages sent from your network to Internet.
					</span></a>

				</td>
				<td nowrap="nowrap" class="style20">
				<input placeholder="Optional: hostrelay.domain.com:port or [ip.add.re.ss]:port" name="hostrelay" type="text" id="hostrelay" value="<?= !empty($values['hostrelay']) ? $values['hostrelay'] : ''?>" size="50" />
				<input placeholder="User" name="uhostrelay" type="text" id="uhostrelay" value="<?= !empty($values['uhostrelay']) ? $values['uhostrelay'] : ''?>" size="15" />
				<input placeholder="Password" name="phostrelay" type="password" id="phostrelay" value="<?= !empty($values['phostrelay']) ? $values['phostrelay'] : ''?>" size="15" />
				</td>
			  </tr>


<!--
			  <tr class="shade1">
				<td valign="top" nowrap="nowrap"><span class="style15">Replicate Domains to</span>
					<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
					<b>Replicate Domains to</b> can be very useful in a migration, backup scenario<br/>
					or to deliver a copy of the message to a different geographic location.
					</span></a>
				</td>
				<td nowrap="nowrap" bgcolor="#494949" class="style20">
				<textarea placeholder="Optional: backup.domain.com" class="style20" wrap="virtual" cols="47" rows="3" name="split" id="split"><?= !empty($values['split']) ? str_replace(' ',"\r", $values['split']) : ''?></textarea></td>

			  </tr>
-->
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

<script type="text/javascript">
function showValue(newValue)
{
	document.getElementById("range").innerHTML=newValue;
	}
	</script>


<script type="text/javascript" src="js/jQuery.js"></script>
<script type="text/javascript" src="js/functions.js"></script>

<script>
// many thanks for this script: http://tim.purewhite.id.au/2012/09/submitting-empty-checkboxes-when-in-array/
$(document).ready(function(){
    // do when submit is pressed
    $('form').submit(function() {

        $('input:checkbox:not(:checked)').each(function() {
                console.log($(this).attr('name'));
                $(this).before($('<input>')
                .attr('type', 'hidden')
                .attr('name', $(this).attr('name')));
                // .val('off'));
        });  
    });

});
</script>

<? include 'footer.php' ?>





</body>
</html>
