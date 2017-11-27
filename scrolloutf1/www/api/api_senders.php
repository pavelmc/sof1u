<?php 

define('SETUP_FILE_SENDERS', '/var/www/cfg/sndr');
define('POSTFIX_FILE', '/var/www/postfix/sndr');
define('SA_FILE', '/var/www/spamassassin/20_wb.cf');
define('AMAVIS_FILE', '/var/www/amavis/sndr');

$values = $_POST;
/**
 *	Process data
 */
	/**
	 *	Save data to file
	 */
 if (file_put_contents(SETUP_FILE, array2file($_POST)) !== false && file_put_contents(POSTFIX_FILE, array2postfix($_POST)) !== false && le_put_contents(SA_FILE, array2sa($_POST)) !== false && file_put_contents(AMAVIS_FILE, array2amavis($_POST)) !== false )
{
  $message['msg'] = 'Settings saved successfully!';
  $message['type'] = 'message';
}
else
{
  $message['msg'] = 'Can not save data! Collector may be in progress writing the files.';
  $message['type'] = 'error';
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