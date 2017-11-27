<?
define('SETUP_FILE', '/var/www/cfg/sndr');
define('POSTFIX_FILE', '/var/www/postfix/sndr');
define('SA_FILE', '/var/www/spamassassin/20_wb.cf');
define('AMAVIS_FILE', '/var/www/amavis/sndr');


if (!empty($_POST))
{
	$values = $_POST;
	/**
	 *	Process data
	 */
		/**
		 *	Save data to file
		 */
		 if (file_put_contents(SETUP_FILE, array2file($_POST)) !== false && file_put_contents(POSTFIX_FILE, array2postfix($_POST)) !== false && file_put_contents(SA_FILE, array2sa($_POST)) !== false && file_put_contents(AMAVIS_FILE, array2amavis($_POST)) !== false )
		{
		  $message['msg'] = 'Settings saved successfully!';
		  $message['type'] = 'message';
		}
		else
		{
		  $message['msg'] = 'Can not save data! Collector may be in progress writing the files.';
		  $message['type'] = 'error';
		}
}
else
{
  /**
   *	Load data from file
   */
}
	

  if (file_exists(SETUP_FILE))
	{
	$ar=file(SETUP_FILE);

	$tot_lines=count($ar);

	$ok=array();
	$not_ok=array();

	for($i=0; $i<$tot_lines; $i++){
	
	$vector_d=str_getcsv($ar[$i],"\t");
	
	if(trim($vector_d[1])=='OK'){
		$ok[]=str_replace(array('$/','/^','/^$/','\#','\.','\@','/','\\','\-','\_','\^','\=','\+'), array('','','','#','.','@','','','-','_','^','=','+'), $vector_d[0]);
	}

	if(trim($vector_d[1])=='xMESSAGEx'){
		$not_ok[]=str_replace(array('$/','/^','/^$/','\#','\.','\@','/','\\','\-','\_','\^','\=','\+'), array('','','','#','.','@','','','-','_','^','=','+'), $vector_d[0]);
	}
	}

  }



function array2file ()
{
	$ok=array();
	$not_ok=array();

  if (!empty($_POST) && is_array($_POST))
  {

	$data=str_replace(array("\r\n","\r"," "), "\n", $_POST);
	$ok=preg_grep('#@*\.#',array_unique(explode("\n",$data['OK']),SORT_STRING));
	$not=preg_grep('#@*\.#',array_unique(explode("\n",$data['xMESSAGEx']),SORT_STRING));

	foreach($ok as $val){
	if (!empty($val)){
		$ok_str.="/".preg_replace('/^([a-zA-Z0-9\_\-\+\^\\\]..*@)/','^\1',str_replace(array('#','.','@','-','_','=','^','+','*'), array('\#','\.','\@','\-','\_','\=','\^','\+',''),$val))."$/\tOK\n";
	}
	}
	foreach($not as $val){
	if (!empty($val)){
	$notok_str.="/".preg_replace('/^([a-zA-Z0-9\_\-\+\^\\\]..*@)/','^\1',str_replace(array('#','.','@','-','_','=','^','+','*'), array('\#','\.','\@','\-','\_','\=','\^','\+',''),$val))."$/\txMESSAGEx\n";
	}
	}
  return ($ok_str.$notok_str);
}
}


function array2postfix ()
{
	$ok=array();
	$not_ok=array();

  if (!empty($_POST) && is_array($_POST))
  {

	$data=str_replace(array("\r\n","\r"," "), "\n", $_POST);
	$ok=preg_grep('#@*\.#',array_unique(explode("\n",$data['OK']),SORT_STRING));
	$not=preg_grep('#@*\.#',array_unique(explode("\n",$data['xMESSAGEx']),SORT_STRING));

	foreach($ok as $val){
	if (!empty($val)){
		$ok_str.="/".preg_replace('/^([a-zA-Z0-9\_\-\+\^\\\]..*@)/','^\1',str_replace(array('#','.','@','-','_','=','^','+','*'), array('\#','\.','\@','\-','\_','\=','\^','\+','.*'),$val))."$/\tOK\n";
	}
	}
	foreach($not as $val){
	if (!empty($val)){
	$notok_str.="/".preg_replace('/^([a-zA-Z0-9\_\-\+\^\\\]..*@)/','^\1',str_replace(array('#','.','@','-','_','=','^','+','*'), array('\#','\.','\@','\-','\_','\=','\^','\+','.*'),$val))."$/\tREJECT\n";
	}
	}
  return ($ok_str.$notok_str);
}
}


function array2sa ()
{
	$ok=array();
	$not_ok=array();

  if (!empty($_POST) && is_array($_POST))
  {

	$data=str_replace(array("\r\n","\r"," "), "\n", $_POST);
	$ok=preg_grep('#@*\.#',array_unique(explode("\n",$data['OK']),SORT_STRING));
	$not=preg_grep('#@*\.#',array_unique(explode("\n",$data['xMESSAGEx']),SORT_STRING));

	foreach($ok as $val){
	if (!empty($val)){
		$ok_str.="whitelist_auth\t".preg_replace(array('/^@/','/^\./'),array('*@','*.'),$val)."\n";
	}
	}
	foreach($not as $val){
	if (!empty($val)){
	$notok_str.="blacklist_from\t".preg_replace(array('/^@/','/^\./'),array('*@','*.'),$val)."\n";
	}
	}
  return ($ok_str.$notok_str);
}
}

function array2amavis ()
{
	$ok=array();
	$not_ok=array();

  if (!empty($_POST) && is_array($_POST))
  {

	$data=str_replace(array("\r\n","\r"," "), "\n", $_POST);
	$ok=preg_grep('#@*\.#',array_unique(explode("\n",$data['OK']),SORT_STRING));
	$not=preg_grep('#@*\.#',array_unique(explode("\n",$data['xMESSAGEx']),SORT_STRING));

	foreach($ok as $val){
	if (!empty($val)){
		$ok_str.=preg_replace(array('/^@/'),array('.'),$val)."\tNO_BANNED_ATTACHMENTS\n";
	}
	}

  return ($ok_str);
}
}

?>

<? include 'top.php' ?>



		  <table width="75%" border="0" align="center" cellpadding="5" cellspacing="0">

			  <tr>
				<th colspan="10" nowrap="nowrap">&nbsp;</th>
			  </tr>
			  
			  <tr>
				<td colspan="10" nowrap="nowrap"><span class="style24"><span class="mi">&#xE25B</span>&nbsp;&nbsp;&nbsp;Senders</span>
				</td>
			  </tr>

			  <tr>
				<td colspan="5" nowrap="nowrap" class="style24" align="center"><span class="mi">&#xECA7;</span> SECURE WHITELIST
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span align="left">
					<? include 'tooltips/whitelist' ?>
					</span></a>
				</td>
				<td colspan="5" nowrap="nowrap" class="style24" align="center"><span class="mi">&#xE1E0;</span> BLACKLIST
				<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span align="left">
					<? include 'tooltips/blacklist' ?>
					</span></a>
				
				</td>
			  </tr>

			  <tr>


			  <tr id="blocklist">
				<td class="tblrsh shade1" nowrap="nowrap" align="center" colspan="5" width="45%">
			<span class="style36">1st priority: allow</span><br/>
				<textarea style="width: 90%;" placeholder="Trusted sender@domain.com or @domain.com" class="style20" wrap="virtual" rows="20" name="OK" id="OK"><?= implode("\n",$ok);  ?></textarea>
				</td>
				
				<td class="tblrsh shade2" nowrap="nowrap" align="center" colspan="5" width="45%">
			<span class="style36">2nd priority: block</span><br/>
				<textarea style="width: 90%;" placeholder="Unwanted sender@domain.com or @domain.com" class="style20" wrap="virtual" rows="20" name="xMESSAGEx" id="xMESSSAGEx"><?= implode("\n",$not_ok); ?></textarea>
				</td>
				
				</tr>
			



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


