<?
define('SETUP_FILE', '/var/www/security.cfg');
define('SECURITY_FILE', '/var/www/security.list');

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


function loadSecurities ()
{
  if (file_exists(SECURITY_FILE) && is_file(SECURITY_FILE))
  {
    $content = file_get_contents(SECURITY_FILE);
    $lines = explode("\n", $content);
    $output = Array();
    foreach ($lines AS $count => $line)
    {
#	  $values = explode(',', $line);
      $security = str_replace(' ', '_', trim($line));
      if (!empty($security))
      {
	array_push($output, $security);
      }
      unset($values, $count, $line, $security);
    }
    unset($content, $lines);
    array_multisort($output, SORT_ASC);
    
    return $output;
  }
  else
  {
    error_log("No security file [". SECURITY_FILE ." defined!");
  }
  
  return false;
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
/**
 *	Load securities from file
 */
$securities = loadSecurities();
if (false === $securities)
{
  error_log("Can not load securities!");
}
?>
<? include 'top.php' ?>




<script type="text/javascript">
var checkAll = function(begins){
  for(i=0; (a=document.getElementsByTagName('input')[i]); i++){
      if(a.type == "radio"){
	var id = a.id.substring(0, begins.length);
      if(id == begins){
      a.checked = true;
    }
    }
  }
  }
</script>


	  <table width="75%" border="0" align="center" cellpadding="2" cellspacing="0">

	      <tr>
		<th colspan="11" nowrap="nowrap">&nbsp;</th>
	      </tr>
	      
	    <tr>
	      <td></td>
		<td colspan="3" nowrap="nowrap" class="bsh style36" style="color: #fff; background: linear-gradient(135deg, #52B852, #70C570);" align="center">AGGRESSIVE</td>
		<td colspan="3" nowrap="nowrap" class="bsh style36" style="color: #fff; background: linear-gradient(135deg, #7ECB7E, #D08E8E);" align="center">OPTIMUM</td>
		<td colspan="4" nowrap="nowrap" class="bsh style36" style="color: #fff; background: linear-gradient(135deg, #CA8080, #B85252);"align="center">PERMISSIVE</td>
	    </tr>


	<tr class="bsh">
		<td  nowrap="nowrap" width="30%" class="style24">
		<span class="style24"><i class="fa fa-sliders fa-2x"></i>&nbsp;&nbsp;&nbsp;Levels</span>
		<a class="tooltip"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
				    <b>SECURITY LEVELS</b><br/><br/>
				    GREEN levels: secure = aggressive<br/>
				    RED levels: less secure = permissive</span></a>
		</td>
		
		      <td nowrap="nowrap" bgcolor="#52B852">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('1_');"><span class="style24"  title="level 1 SECURE">1</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#61BE61">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('2_');"><span class="style24" title="level 2">2</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#70C570">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('3_');"><span class="style24" title="level 3">3</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#7ECB7E">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('4_');"><span class="style24" title="level 4">4</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#8DD18D">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('5_');"><span class="style24" title="level 5">5</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#D08E8E">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('6_');"><span class="style24" title="level 6">6</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#CA8080">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('7_');"><span class="style24" title="level 7">7</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#C47171">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('8_');"><span class="style24" title="level 8">8</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#BE6161">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('9_');"><span class="style24" title="level 9">9</span></a>
			
			</div>					  </td>
		      <td  nowrap="nowrap" bgcolor="#B85252">
			<div align="center" class="style11">
			<a href="javascript:void(0)" onclick="checkAll('10_');"><span class="style24" title="level 10 INSECURE">10</span></a>
			
			</div>					  </td>
		    </tr>



	      <tr>

			  

<?
if (!empty($securities)) :
  $bgcolor = '';
  foreach ($securities AS $count => $security) :
    $bgcolor = 0 == $count % 2 ? '#414141' : '#212121';
    $style = 0 == $count % 2 ? 'background: linear-gradient(135deg, #414141, #212121);' : 'background: linear-gradient(135deg, #393939, #191919);';
    $class = 0 == $count % 2 ? 'lrsh shade1' : 'lrsh shade2';

    $shortname = str_replace('_', ' ', $security)
?>
	      <tr class="<?= $class ?>">
		<td  nowrap="nowrap"><span class="style36"><?= $shortname ?></span>


		<a class="tooltip" href="javascript:void(0)"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
		<? include 'tooltips/'.str_replace(' ', '_', $shortname) ?>
		</span></a>

		<?
		if ($shortname == "Connection filter")
		{
		?>

	    <a class="style15 second" href="javascript:void(0)" onclick="toggle_visibility(event,'<?= $shortname ?>');"><span class="mi-s">&#xE019</span></a>


	    
		  <?
		  }
		  ?>  



		<?
		if ($shortname == "Rate limits in")
		{
		?>

	    <a class="style15 second" href="javascript:void(0)" onclick="toggle_visibility(event,'<?= $shortname ?>');"><span class="mi-s">&#xE019</span></a>

	    
		  <?
		  }
		  ?>  


	
		</td>
		<td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="1_<?= $count ?>" value="1" title="<?= $shortname ?> level 1 SECURE"<?= !empty($values[$security]) && 1 == $values[$security] ? ' checked' : '' ?> /> <label for="1_<?= $count ?>" title="<?= $shortname ?>"></label>
		    </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="2_<?= $count ?>" value="2" title="<?= $shortname ?> level 2"<?= !empty($values[$security]) && 2 == $values[$security] ? ' checked' : '' ?> /> <label for="2_<?= $count ?>" title="<?= $shortname ?>"></label>
		    </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="3_<?= $count ?>" value="3" title="<?= $shortname ?> level 3"<?= !empty($values[$security]) && 3 == $values[$security] ? ' checked' : '' ?> /> <label for="3_<?= $count ?>" title="<?= $shortname ?>"></label>
		  </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="4_<?= $count ?>" value="4" title="<?= $shortname ?> level 4"<?= !empty($values[$security]) && 4 == $values[$security] ? ' checked' : '' ?> /> <label for="4_<?= $count ?>" title="<?= $shortname ?>"></label>
		  </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="5_<?= $count ?>" value="5" title="<?= $shortname ?> level 5"<?= !empty($values[$security]) && 5 == $values[$security] ? ' checked' : '' ?> /> <label for="5_<?= $count ?>" title="<?= $shortname ?>"></label>
		  </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="6_<?= $count ?>" value="6" title="<?= $shortname ?> level 6"<?= !empty($values[$security]) && 6 == $values[$security] ? ' checked' : '' ?> /> <label for="6_<?= $count ?>" title="<?= $shortname ?>"></label>
		  </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="7_<?= $count ?>" value="7" title="<?= $shortname ?> level 7"<?= !empty($values[$security]) && 7 == $values[$security] ? ' checked' : '' ?> /> <label for="7_<?= $count ?>" title="<?= $shortname ?>"></label>
		  </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="8_<?= $count ?>" value="8" title="<?= $shortname ?> level 8"<?= !empty($values[$security]) && 8 == $values[$security] ? ' checked' : '' ?> /> <label for="8_<?= $count ?>" title="<?= $shortname ?>"></label>
		  </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="9_<?= $count ?>" value="9" title="<?= $shortname ?> level 9"<?= !empty($values[$security]) && 9 == $values[$security] ? ' checked' : '' ?> /> <label for="9_<?= $count ?>" title="<?= $shortname ?>"></label>
		  </span></td>
		    <td align="center"><span class="style20"><input class="with-font" type="radio" style="<?= $style ?>" name="<?= $security ?>" id="10_<?= $count ?>" value="10" title="<?= $shortname ?> level 10 INSECURE"<?= !empty($values[$security]) && 10 == $values[$security] ? ' checked' : '' ?> /> <label for="10_<?= $count ?>" title="<?= $shortname ?>"></label>
		  </span></td>
	      </tr>

		<?
		if ($shortname == "Connection filter")
		{
		?>

	      <tr class="<?= $class ?>" style="display: none;" id="<?= $shortname ?>">
		<td><span class="style36">RBL & DNSBL</span>
		</td>
		
		<td nowrap="nowrap" align="center" colspan="10">

		<div class="card">
	    <span class="style15">Check Client IP</span><br/>
	    <span class="style36">Active for Connection filter: 1-7</span><br/>
		<textarea style="width: 90%;" placeholder="Sender IP reputation providers" class="style20" wrap="virtual" rows="7" name="sip" id="sip"><?= !empty($values['sip']) ? str_replace(' ',"\r", $values['sip']) : ''?></textarea>

	    </div>

		<div class="card">
	    <span class="style15">Check Client HOSTNAME & HELO</span><br/>
	    <span class="style36">Active for Connection filter: 1-6</span><br/>
		<textarea style="width: 90%;" placeholder="Client Hostname reputation providers" class="style20" wrap="virtual" rows="3" name="shostname" id="shostname"><?= !empty($values['shostname']) ? str_replace(' ',"\r", $values['shostname']) : ''?></textarea>				

	    </div>

	    <div class="card">
	    <span class="style15">Check Sender DOMAIN</span><br/>
	    <span class="style36">Active for Connection filter: 1-5</span><br/>
		<textarea style="width: 90%;" placeholder="Sender Domain reputation providers" class="style20" wrap="virtual" rows="3" name="sdomain" id="sdomain"><?= !empty($values['sdomain']) ? str_replace(' ',"\r", $values['sdomain']) : ''?></textarea>
	    </div>
		</td>
		
		</tr>
	    
		  <?
		  }
		  ?>  




		<?
		if ($shortname == "Rate limits in")
		{
		?>

	      <tr class="<?= $class ?>" style="display: none;" id="<?= $shortname ?>">
		<td class="bsh lrsh"><span class="style36">RBL & DNSBL</span>
		</td>
		

		<td class="bsh lrsh" nowrap="nowrap" align="center" colspan="10">

		<div class="card">
	    <span class="style15">Check Sender Name Servers (Names)</span><br/>
	    <span class="style36">Active for Rate limits in: 1-5</span><br/>
		<textarea style="width: 90%;" placeholder="Name Servers reputation providers. Domain names only." class="style20" wrap="virtual" rows="3" name="check_ns_names" id="check_ns_names"><?= !empty($values['check_ns_names']) ? str_replace(' ',"\r", $values['check_ns_names']) : ''?></textarea>				

	    </div>

	    <div class="card">
	    <span class="style15">Check Sender Name Servers (IPs)</span><br/>
	    <span class="style36">Active for Rate limits in: 1-5</span><br/>
		<textarea style="width: 90%;" placeholder="Name Servers reputation providers. IPs only." class="style20" wrap="virtual" rows="3" name="check_ns_ips" id="check_ns_ips"><?= !empty($values['check_ns_ips']) ? str_replace(' ',"\r", $values['check_ns_ips']) : ''?></textarea>
	    </div>
		</td>
		
		</tr>
	    
		  <?
		  }
		  ?>  


<?
  endforeach ;
endif ;
?>


	      <tr>
		<th colspan="11" nowrap="nowrap">&nbsp;</th>
	      </tr>

	  </table>


	    <div align="center">
	      <input type="submit" class="mi-l" value=" &#xE10B " title="or Press ENTER" alt="or Press ENTER" />
	      
	      </div>
      </form>
    </div>


	    <script type="text/javascript">
	    <!--
	    function toggle_visibility(e, id) {
	    	e.preventDefault(); 
		    var e = document.getElementById(id);
		    if(e.style.display == '')
		    e.style.display = 'none';
		    else
		    e.style.display = '';
	     }
	     //-->
	     </script>


<? include 'footer.php' ?>

</body>
</html>

