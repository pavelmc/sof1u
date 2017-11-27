<?php

define('LOGS_FILE', '/var/log/mail.log');

file_put_contents(LOGS_FILE, "");

$message['msg'] = 'Settings saved successfully!';
$message['type'] = 'message';

echo $message;