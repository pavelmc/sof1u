<?php

if(isset($_GET["click"])){


	$json = file_get_contents("/var/www/customizer/config.json");
echo $json;

try {
	$arr = json_decode($json);
	$arr->$_GET["click"] = $arr->$_GET["click"] + 1;

} catch (Exception $e) {
	echo $e;
}


	$myfile = fopen("config.json", "w") or die("Unable to open file!");
	fwrite($myfile, json_encode($arr));
	fclose($myfile);
}

?>