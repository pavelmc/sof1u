
<?php
$path = $_SERVER['REQUEST_URI'];
$file = basename($path);         // $file is set to "index.php"
$file = basename($path, ".php"); // $file is set to "index"
$file = $file.".cfg";
?>

	<table id="footer" cellpadding="0" cellspacing="0" border="0">
	<tr><td colspan="4">&nbsp;</td></tr>
	<tr><td colspan="4">&nbsp;</td></tr>
	<tr><td colspan="4">&nbsp;</td></tr>
	<tr class="bsh"><td colspan="4"> &copy; 2010 - <?= exec('date -u +%Y') ?> <a href="mailto:marius.gologan@gmail.com">Marius Gologan</a>. 
	All rights reserved. 
	| <a  href="javascript:void(0)" id="br_btn"><span class="mi-s">&#xE118;</span></a>
	| <a  href="javascript:void(0)" id="donate_btn" >DONATE</a> 
	| <a href="https://sourceforge.net/projects/scrollout/reviews/" target="_blank">REVIEW</a> 
	| <a href="http://www.scrolloutf1.com/contact" target="_blank">SUPPORT</a> 
	| <a href="http://www.scrolloutf1.com/credits" target="_blank">CREDITS</a> 
	| <?= exec('date -u') ?> 
	| Release: <?= shell_exec('head -1 version') ?></td></tr>

	<tr><td colspan="4">


		<div id="br" style="display: none; border: 0px dotted gray; margin:15px 15px; border-radius:5px;">
			<table width="50%" align="center" cellpadding="5" cellspacing="5" border="0" style="border-left:thin dotted;">

			    <tr><td align="right" width="25%">

			    <span class="mi">&#xE118</span>

			    </td>
			    <td align="left" width="75%">
				<span class="style98">Download
				<a href="<? echo $file; ?>" download><? echo $file; ?></a>
				file
				</span>
			    </td></tr>

			    <tr><td align="right" width="25%">

				<span class="mi">&#xE11C</span>

			    </td>
			    <td align="left" width="75%">

			    <form action="/upload.php"
    			    class="dropzone"
    			    id="my-awesome-dropzone">
			    <div class="dz-message" data-dz-message style="text-align:left">
			    <span  class="style98">
			    <li>Upload <strong><? echo $file?></strong> file to restore this panel only.</li>
			    <li>Upload multiple .CFG files to restore multiple panels.</li>
			    </span></div>
			    </form>

			    </td></tr>

			</table>
    		</div>



		<div id="donate" style="display: none; border: 0px dotted gray; margin:15px 15px; border-radius:5px;">
			<table width="50%" align="center" cellpadding="5" cellspacing="5" border="0" style="border-left:thin dotted;">

			    <tr><td align="right" width="25%">
			    <i class="fa fa-credit-card fa-3x" aria-hidden="true"></i>
			    </td>
			    <td align="left" width="75%">
				<span class="style98">
				Ing Bank: INGBROBU
				RO71INGB0000999900926953
				</span>
			    </td></tr>

			    <tr><td align="right" width="25%">

				<i class="fa fa-cc-paypal fa-3x" aria-hidden="true"></i>
			    </td>
			    <td align="left" width="75%">
				<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=H392JXKWPSNGY" target="_blank"><i class="fa fa-euro fa-2x" aria-hidden="true"></i></a>
				<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TSGC9M53JPVCQ" target="_blank"><i class="fa fa-usd fa-fw fa-2x" aria-hidden="true"></i></a>
			    </td></tr>

			</table>
    		</div>

	    </td>
	</tr>

                        <script type="text/javascript">
			$(document).ready(function(){
			    var $this = $("#bitcoin");

			    $("#bitcoin_btn").click(function() {
			    $this.slideToggle("fast");
			    });
			});
                         </script>

                        <script type="text/javascript">
			$(document).ready(function(){
			    var $donate = $("#donate");

			    $("#donate_btn").click(function() {
			    $donate.slideToggle("fast");
			    });

			    var $br = $("#br");
			    $("#br_btn").click(function() {
			    $br.slideToggle("fast");
			    });

			});
                         </script>

	    <tr><td colspan="4">

	    <div id="tips">
		<script src="js/tips.js"></script>
	    </div>

	    </td></tr>
	</table>
