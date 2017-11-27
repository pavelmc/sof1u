<?
define('CERT_FILE', '/etc/postfix/certs/scrollout.cert');
define('KEY_FILE','/etc/postfix/certs/scrollout.key');

$certificate = openssl_x509_parse(file_get_contents(CERT_FILE));
$validFrom = date('Y-m-d H:i:s', $certificate['validFrom_time_t']);
$validTo = date('Y-m-d H:i:s', $certificate['validTo_time_t']);
$name = $certificate['name'];


function array2cert ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$cert = $_POST['cert'];
        return $cert;
  }
    else
    {
  return false;
    }
}

function array2key ($data)
{
  if (!empty($_POST) && is_array($_POST))
      {
	$certkey = $_POST['certkey'];
        return $certkey;
    }
    else
    {
  return false;
    }
}


function cert2array ()
{
  if (file_exists(CERT_FILE))
  {
	$rawcert = file_get_contents(CERT_FILE);
  }

return $rawcert;
}

function key2array ()
{
  if (file_exists(KEY_FILE))
  {
	$privkey = file_get_contents(KEY_FILE);
  }

return $privkey;
}




if (!empty($_POST))
{
        $values = $_POST;
        /**
         *      Process data
         */
        array_walk($_POST, 'trim');
                /**
                 *      Save data to file
                 */
                if (file_put_contents(CERT_FILE, array2cert($_POST)) !== false && file_put_contents(KEY_FILE, array2key($_POST)) !== false )
                {
		shell_exec('sudo /var/www/bin/service.sh cert'.' '.$_POST['passkey']);
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
   *    Load data from file
   */
}

$value_cert = cert2array();
$value_key = key2array();

?>

<? include 'top.php' ?>


		  <table width="75%" border="0" align="center" cellpadding="5" cellspacing="0">

			  <tr>
				<th colspan="10" nowrap="nowrap">&nbsp;</th>
			  </tr>
			  
			  <tr>
				<td colspan="10" nowrap="nowrap"><span class="style24"><span class="mi">&#xEC1B</span>&nbsp;&nbsp;&nbsp;Certificate</span>
				</td>
			  </tr>

			  <tr class="bsh">
				<td colspan="10" nowrap="nowrap" class="style24" align="center"><br/><span class="mi">&#xEB95;</span> CERTIFICATE</td>
			  </tr>


			  <tr class="card" id="cert">
				<td nowrap="nowrap" align="center" colspan="10" width="45%">
			<span class="style36">Valid From: <?= !empty($validFrom) ? $validFrom : 'NA'  ?> to <?= !empty($validTo) ? $validTo : '' ?><br/> Name: <?= !empty($name) ? $name : '' ?><br/></span><br/>
			<span class="style36">Include -----BEGIN CERTIFICATE-----</span><br/>
				<textarea style=" width: 75%;" placeholder="Open your trusted certificate file in a text editor. Copy & paste the CERTIFICATE part here." 
				class="style20" wrap="virtual" rows="10" name="cert" id="cert"><?= !empty($value_cert) ? $value_cert : '' ?></textarea>
			<span class="style36"><br/>Include -----END CERTIFICATE-----</span><br/>
				</td>
				
				</tr>

			  <tr class="bsh">
				<td colspan="10" nowrap="nowrap" class="style24" align="center"><br/><span class="mi">&#xE131;</span> PRIVATE KEY</td>
			  </tr>

			  <tr class="card" id="key">
				<td nowrap="nowrap" align="center" colspan="10" width="45%">
			<span class="style36">Include -----BEGIN PRIVATE KEY-----</span><br/>

				<textarea style="width: 75%;" placeholder="Open your trusted certificate or key file in a text editor. Copy & paste the PRIVATE KEY part here." 
				class="style20" wrap="virtual" rows="10" name="certkey" id="certkey"><?= !empty($value_key) ? $value_key : '' ?></textarea>
			<span class="style36"><br/>Include -----END PRIVATE KEY-----</span><br/>

<span id="error-certkey" style="color: #04acec; font-size:12px"><br/>WARNNING: Private key is encrypted with passphrase.<br/>
Passphrase: <input placeholder="passphrase" name="passkey" type="password" id="passkey" value="<?= !empty($value_passkey) ? $value_passkey : ''?>" />
</span>

				<script type="text/javascript">
                                    function validatecertkey(certkey) {
                                        var certkeyReg = /ENCRYPTED/;
                                        if( certkeyReg.test( certkey ) ) {
                                        $('#error-certkey').show();
                                        } else {
                                        $('#error-certkey').hide();
                                        }
                                        }
                                $(function(){
                                        $('#error-certkey').hide();
                                        $('#certkey').live('input propertychange',function(){
                                        var Addresscertkey=$(this).val();
                                         console.log("A");
                                        validatecertkey(Addresscertkey);
                                        });
                                        });
                                    </script>


				</td>
				
				</tr>


			  <tr>


			  <tr>
				<th colspan="11" nowrap="nowrap">&nbsp;</th>
			  </tr>

		  </table>


			<div align="center">
			  <input type="submit" class="mi-l" value=" &#xE10B " title="or Press ENTER" alt="or Press ENTER" />
			  </div>
	  </form>
	</div>



<? include 'footer.php' ?>

</body>
</html>

