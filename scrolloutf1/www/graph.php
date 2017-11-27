
<?php include 'top.php' ?>

 <table width="75%" border="0" align="center" cellpadding="2" cellspacing="0">
			  <tr>
				<th width="100%" nowrap="nowrap">&nbsp;</th>
			  </tr>
			  <tr>
				<td nowrap="nowrap"><span class="style24"><span class="mi">&#xE9D9</span>&nbsp;&nbsp;&nbsp;Stats</span></td>
			  </tr>

			  <tr>
				<td nowrap="nowrap" align="center"><?php echo system('cgi-bin/mailgraph.cgi'); ?></td>
			  </tr>
		  </table>

<script>
setTimeout(function(){
   window.location.reload(1);
}, 300000);
</script>
		  
<? include 'footer.php' ?>

</body>
</html>