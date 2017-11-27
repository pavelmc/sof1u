<?
define('SETUP_FILE', '/var/www/collector.cfg');



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
			  <tr class="bsh">
				<td nowrap="nowrap"><span class="style24"><span class="mi">&#xEDAB</span>&nbsp;&nbsp;&nbsp;Collector</span>
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				<? include 'tooltips/collector' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" class="style20">&nbsp;</td>
			  </tr>
			  <tr class="lrsh shade1">
			  <td nowrap="nowrap"><span class="style15">Mailbox</span>
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				<? include 'tooltips/mailbox' ?>
				</span></a>




			  </td>
			<td nowrap="nowrap" class="style20">
			<input placeholder="An email address for reports, collector and feeder" name="mailbox" type="text" id="mailbox" value="<?= !empty($values['mailbox']) ? $values['mailbox'] : ''?>" size="50"  required/>
			<span id="mailbox-error" style="color: #04acec;"><br/>Valid email address required: address@example.com</span>
			<ul>

                        <label for="reportc">
			<input class="with-font" type="checkbox" name="reportc" value="1" id="reportc"<?= (isset($values['reportc']) && (1 == $values['reportc'])) ? ' checked' : '' ?> />
			<label for="reportc">Do not collect detailed reports
			</label>

			<br/>
                        <input class="with-font" type="checkbox" name="spamc" value="1" id="spamc"<?= (isset($values['spamc']) && (1 == $values['spamc'])) ? ' checked' : '' ?> />
			<label for="spamc">Do not collect spam (erase spam emails)
			</label>
			<br/>

                        <input class="with-font" type="checkbox" name="virusc" value="1" id="virusc"<?= (isset($values['virusc']) && (1 == $values['virusc'])) ? ' checked' : '' ?> />
                        <label for="virusc">Do not collect virus (erase virus emails)</label>
			<br/>

                        <input class="with-font" type="checkbox" name="banc" value="1" id="banc"<?= (isset($values['banc']) && (1 == $values['banc'])) ? ' checked' : '' ?> />
                        <label for="banc">Do not collect banned files (erase emails with banned files)</label>
			</ul>

			</td>
			</tr>
			  <tr class="lrsh shade2">
				<td nowrap="nowrap"><span class="style15">IMAP Server</span>
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				<? include 'tooltips/imap_server' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" class="style20">
				<input placeholder="hostname or IP" name="imapserver" type="text" id="dns7" value="<?= !empty($values['imapserver']) ? $values['imapserver'] : ''?>" size="50" />

				<input class="with-font" type="checkbox" name="ssl" value="1" id="ssl_0"<?= (isset($values['ssl']) && (1 == $values['ssl'])) ? ' checked' : '' ?> />
				<label for="ssl_0">Secure connection with IMAP server</label>
				</td>
			  </tr>
			  <tr class="lrsh shade1">
				<td nowrap="nowrap"><span class="style15">User Name</span>
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				<? include 'tooltips/user_name' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" class="style20"><input placeholder="IMAP User" name="username" type="text" id="dns8" value="<?= !empty($values['username']) ? $values['username'] : ''?>" /></td>
			  </tr>
			  <tr class="lrsh shade2">
				<td nowrap="nowrap"><span class="style15">Password</span></td>
				<td nowrap="nowrap" class="style20"><input placeholder="password" name="password" type="password" id="dns9" value="<?= !empty($values['password']) ? $values['password'] : ''?>" />
                                <span id="error-dns9" style="color: #04acec;"><br/>Password should not contain characters like !,&,#,*,(,),$</span>
                                    <script type="text/javascript">
                                    function validatedns9(dns9) {
                                        var dns9Reg = /[\!\#\$\&\*\)\(\$]/;
                                        if( dns9Reg.test( dns9 ) ) {
                                        $('#error-dns9').show();
                                        } else {
                                        $('#error-dns9').hide();
                                        }
                                        }
                                $(function(){
                                        $('#error-dns9').hide();
                                        $('#dns9').live('input propertychange',function(){
                                        var Addressdns9=$(this).val();
                                        validatedns9(Addressdns9);
                                        });
                                        });
                                    </script>


			</td>
			  </tr>
			  <tr class="lrsh shade1">
				<td nowrap="nowrap"><span class="style15">Legit Folder</span>
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				<? include 'tooltips/legit_folder' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" class="style20"><input placeholder="A LEGIT folder in mailbox" name="legitimatefolder" type="text" id="dns10" value="<?= !empty($values['legitimatefolder']) ? $values['legitimatefolder'] : ''?>" />
				<input class="with-font" type="checkbox" style="{background-color: #494949}" name="resend" value="1" id="resend_0"<?= (isset($values['resend']) && (1 == $values['resend'])) ? ' checked' : '' ?> />
				<label for="resend_0">Send false positive messages to original recipients</label>
			</td>
			  </tr>
			  <tr class="lrsh shade2">
				<td nowrap="nowrap"><span class="style15">Spam Folder</span>
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				<? include 'tooltips/spam_folder' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" class="style20"><input placeholder="A SPAM folder in mailbox" name="spamfolder" type="text" id="dns11" value="<?= !empty($values['spamfolder']) ? $values['spamfolder'] : ''?>" /></td>
			  </tr>


			  <tr class="lrsh shade1">
				<td nowrap="nowrap"><span class="style15">Report</span>
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				<? include 'tooltips/report' ?>
				</span></a>
				</td>
				<td nowrap="nowrap" class="style20">
				<input class="with-font" type="checkbox" name="rspam" value="1" id="rspam_0"<?= (isset($values['rspam']) && (1 == $values['rspam'])) ? ' checked' : '' ?> />
				<label for="rspam_0">
				Report fingerprints to ScrolloutF1.com</label>
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


<script type="text/javascript">

   function validateEmail(mailbox) {
    var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
    if( !emailReg.test( mailbox ) ) {
 	 $('#mailbox-error').show();
	} else {
	 $('#mailbox-error').hide();  
	}
    }

   $(function(){
    $('#mailbox-error').hide();
     
    $('#mailbox').live('input propertychange',function(){
        var emailAddress=$(this).val();
		validateEmail(emailAddress);
    });

   });
</script>


<? include 'footer.php' ?>

</body>
</html>

