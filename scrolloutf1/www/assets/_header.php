<?php

$htmlHeader = <<<HTML
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="author" content="NXT">
    <link rel="icon" href="../../favicon.ico">

    <title>ScrollOut Admin</title>

    <!-- Bootstrap core CSS -->
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">

    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <link href="assets/css/ie10-viewport-bug-workaround.css" rel="stylesheet">


    <!-- NoUiSlider -->
    <link href="assets/nouislider/nouislider.css" rel="stylesheet">


    <!-- Custom styles for this template -->
    <link href="assets/css/style.css" rel="stylesheet">
    <link href="assets/css/settings.css" rel="stylesheet">
	<link href="https://fonts.googleapis.com/css?family=Open+Sans:300i,400,400i,700" rel="stylesheet">
	<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 	crossorigin="anonymous">
  </head>

  <body>

    <nav class="navbar navbar-fixed-top">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="dash.php"><img src="assets/img/logo_v3.png" style="height: 100%"/></a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
            <li><a href="#" onClick="goTo('connection_nxt.php');"><i class="fa fa-plug" aria-hidden="true"></i>&nbsp;&nbsp;CONNECT</a></li>
            <li><a href="#" onClick="goTo('traffic_nxt.php');"><i class="fa fa-exchange" aria-hidden="true"></i>&nbsp;&nbsp;ROUTE</a></li>
            <li><a href="#" onClick="goTo('security_nxt.php#/security');"><i class="fa fa-shield" aria-hidden="true"></i>&nbsp;&nbsp;SECURE</a></li>
            <li><a href="#" onClick="goTo('collector_nxt.php');"><i class="fa fa-recycle" aria-hidden="true"></i>&nbsp;&nbsp;COLLECT</a></li>
            <li><a href="#" onClick="goTo('monitor_nxt.php#/monitor');"><i class="fa fa-eye" aria-hidden="true"></i>&nbsp;&nbsp;MONITOR</a></li>
            <li class="nightmode_li"><i class="fa fa-moon-o" id="night_mode_icon" aria-hidden="true" style=" font-size: 15px; vertical-align: middle;"></i>&nbsp;&nbsp;<input type="checkbox" name="nightmode" class="js-switch" onChange="toggleNightmode(this);" id="nightmode_toggle" /></li>
          </ul>
        </div>
      </div>
    </nav>

HTML;
