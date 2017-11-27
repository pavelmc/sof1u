<?php


global $htmlFooter;

$htmlFooter = <<<HTML


    <footer class="footer">
    Copyright 2017 ScrollOutF1. All rights reserved. <a href="#" onClick="launchFullscreen(document.documentElement);" title="Go fullscreen"><i class="fa fa-arrows-alt"></i></a>
    </footer>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="../../assets/js/vendor/jquery.min.js"><\/script>')</script>
    <script src="assets/js/bootstrap.min.js"></script>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="assets/js/ie10-viewport-bug-workaround.js"></script>

    <!-- Routing with Sammy NXT -->
    <script src="assets/js/sammy/sammy.js"></script>
    <script src="assets/js/sammy/script.js"></script>


    <!-- Switchery -->
    <script src="assets/switchery/dist/switchery.min.js"></script>
    <link href="assets/switchery/dist/switchery.min.css" rel="stylesheet">

    <!-- PNotify -->
    <link href="assets/pnotify/dist/pnotify.css" rel="stylesheet">
    <link href="assets/pnotify/dist/pnotify.buttons.css" rel="stylesheet">
    <link href="assets/pnotify/dist/pnotify.nonblock.css" rel="stylesheet">
    <script src="assets/pnotify/dist/pnotify.js"></script>
    <script src="assets/pnotify/dist/pnotify.buttons.js"></script>
    <script src="assets/pnotify/dist/pnotify.nonblock.js"></script>
    <script src="assets/pnotify/dist/pnotify.confirm.js"></script>

    <!-- NoUISlider -->
    <script src="assets/nouislider/nouislider.js"></script>
    <script src="https://refreshless.com/nouislider/documentation/assets/wNumb.js"></script>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/3.1.2/rollups/md5.js"></script>


    $htmlEndScripts


    <script src="assets/js/script.js"></script>

  </body>
</html>

HTML;
