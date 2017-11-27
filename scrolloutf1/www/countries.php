<?
define('SETUP_FILE', '/var/www/countries.cfg');
define('COUNTRIES_FILE', '/var/www/cfg/geo/countries');

function array2file ($data)
{
  if (!empty($_POST) && is_array($_POST))
  {
	$str = '';
	foreach ($_POST AS $key => $value)
	{
	  $str .= $key .'='. $value .";\n";
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
	  $output[substr($line, 0, $position)] = substr($line, $position + 1, -1);
	  unset($position);
	}
	
	return $output;
  }
}
function loadCountries ()
{
  if (file_exists(COUNTRIES_FILE) && is_file(COUNTRIES_FILE))
  {
	$content = file_get_contents(COUNTRIES_FILE);
	$lines = explode("\n", $content);
	$output = Array();
	foreach ($lines AS $count => $line)
	{
#	 $values = explode(',', $line);
#	 $country = str_replace(' ', '_', trim($values[3]));
	$char = array('\\', '\'', ' ');
	  $country = str_replace($char, '_', trim($line));
	  if (!empty($country))
	  {
		array_push($output, $country);
	  }
	  unset($values, $count, $line, $country);
	}
	unset($content, $lines);
	array_multisort($output, SORT_ASC);
	
	return $output;
  }
  else
  {
	error_log("No country file [". COUNTRIES_FILE ." defined!");
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
 *	Load countries from file
 */
$countries = loadCountries();
if (false === $countries)
{
  error_log("Can not load countries!");
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
				<th width="40%" class="style20">&nbsp;</th>
				<th width="20%" class="style20">&nbsp;</th>
				<th width="20%" class="style20">&nbsp;</th>
				<th width="20%" class="style20">&nbsp;</th>
			  </tr>
			  <tr class="bsh">
				<td><span class="style24"><span class="mi">&#xE909</span>&nbsp;&nbsp;&nbsp;Countries</span>
						<a class="tooltip" href="#"><i class="fa fa-info-circle fa-fw" aria-hidden="true"></i><span>
						<b>Bussines area:</b> no score applied<br/>
						<b>Foreign area:</b><br/>
						- a score is applied based on the sender location, relay location and location of the links in the body, depending on the security level.<br/>
						<b>Out of area:</b> (aggressive)<br/>
						- same as Foreign area policy, but it tries to block the message, this time, using 2 Geo methods, one at the connection level, second in the message scoring process.</span></a>
				
				</td>
				 <td><a href="javascript:void(0)" onclick="checkAll('trust_');"><span class="mi">&#xECA7;</span><span class="style36"> Select column</span></a>
				</td>
				 <td><a href="javascript:void(0)" onclick="checkAll('filter_');"><span class="mi">&#xEE57;</span><span class="style36"> Select column</span></a>
				</td>
				 <td><a href="javascript:void(0)" onclick="checkAll('block_');"><span class="mi">&#xE1E0;</span><span class="style36"> Select column</span></a>
				</td>
			  </tr>
		</table>
						  

<div class="countries" id="countries">
	<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">

<?
if (!empty($countries)) :
  $bgcolor = '';
  foreach ($countries AS $count => $country) :
	$bgcolor = 0 == $count % 2 ? '#494949"' : '#393939';
	$style = 0 == $count % 2 ? 'background: linear-gradient(135deg, #414141, #212121)' : 'background: linear-gradient(135deg, #393939, #191919)';
	$class = 0 == $count % 2 ? 'lrsh shade1' : 'lrsh shade2';
		$shortname = str_replace('_', ' ', $country)
?>
			  <tr class="<?= $class ?>">
				<td width="40%"><span class="style15"><?= $shortname ?></span></td>
					<td width="20%"><span class="style20"><input class="with-font" type="radio" name="<?= $country ?>" id="trust_<?= $count ?>" value="0" title="<?= $shortname ?>"<?= empty($values[$country])  && 0 == $values[$country] ? ' checked' : '' ?> /> <label for="trust_<?= $count ?>" title="<?= $shortname ?>">Business area</label>
					</span></td>
					<td width="20%"><span class="style20"><input class="with-font" type="radio" name="<?= $country ?>" id="filter_<?= $count ?>" value="1" title="<?= $shortname ?>"<?= !empty($values[$country]) && 1 == $values[$country] ? ' checked' : '' ?> /> <label for="filter_<?= $count ?>" title="<?= $shortname ?>">Foreign area</label>
					</span></td>
					<td width="20%"><span class="style20"><input class="with-font" type="radio" name="<?= $country ?>" id="block_<?= $count ?>" value="2" title="<?= $shortname ?>"<?= !empty($values[$country]) && 2 == $values[$country] ? ' checked' : '' ?> /> <label for="block_<?= $count ?>" title="<?= $shortname ?>">Out of area</label>
				  </span></td>
			  </tr>
<?
  endforeach ;
endif ;
?>
		  </table>
	  </div>
		

			<div align="center"><br/>
			  <input type="submit" class="mi-l" value=" &#xE10B " title="or Press ENTER" alt="or Press ENTER" />
			  </div>
		</div>
	  </form>
	</div>
<? include 'footer.php' ?>


</body>
</html>

