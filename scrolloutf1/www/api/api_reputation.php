<?php

define('IPv4_PREF', '/var/www/rbldns/reputation-ip-');	
define('IPv6_PREF', '/var/www/rbldns/reputation-ip6-');	
define('DOMAIN_PREF', '/var/www/rbldns/reputation-domain-');	
define('NS_PREF', '/var/www/rbldns/reputation-ns-');	
	

for($i=0; $i<=100; $i=$i+10){
	$filename = IPv4_PREF.$i;
	if (file_exists($filename)){
	  
		$array = explode("\n", file_get_contents($filename));
		$index_at = false;
		foreach ($array AS $count => $line)
		{
		  if(strpos($line, '# ADD YOUR ENTRIES BELOW:') !== false ) $index_at = $count;  
		}
		//$array[$index_at] = $array[$index_at]."\n";
		$count_lines = count($array);
		for($j=$index_at+1; $j<$count_lines; $j++) unset($array[$j]);
		$new_values = $_POST["rep_ta_".$i."_1"]; 
		$arr_new =  explode("\n", $new_values);
		foreach($arr_new as $line){
			$array[] = $line;
		}
	     
	    file_put_contents($filename, implode("\n", $array));
	}

} 


for($i=0; $i<=100; $i=$i+10){
	$filename = DOMAIN_PREF.$i;
	if (file_exists($filename)){
	  
		$array = explode("\n", file_get_contents($filename));
		$index_at = false;
		foreach ($array AS $count => $line)
		{
		  if(strpos($line, '# ADD YOUR ENTRIES BELOW:') !== false ) $index_at = $count;  
		}
		//$array[$index_at] = $array[$index_at]."\n";
		$count_lines = count($array);
		for($j=$index_at+1; $j<$count_lines; $j++) unset($array[$j]);
		$new_values = $_POST["rep_ta_".$i."_2"]; 
		$arr_new =  explode("\n", $new_values);
		foreach($arr_new as $line){
			$array[] = $line;
		}
	     
	    file_put_contents($filename, implode("\n", $array));
	}

} 
	 
for($i=0; $i<=100; $i=$i+10){
	$filename = NS_PREF.$i;
	if (file_exists($filename)){
	  
		$array = explode("\n", file_get_contents($filename));
		$index_at = false;
		foreach ($array AS $count => $line)
		{
		  if(strpos($line, '# ADD YOUR ENTRIES BELOW:') !== false ) $index_at = $count;  
		}
		//$array[$index_at] = $array[$index_at]."\n";
		$count_lines = count($array);
		for($j=$index_at+1; $j<$count_lines; $j++) unset($array[$j]);
		$new_values = $_POST["rep_ta_".$i."_3"]; 
		$arr_new =  explode("\n", $new_values);
		foreach($arr_new as $line){
			$array[] = $line;
		}
	     
	    file_put_contents($filename, implode("\n", $array));
	}

} 	



?>