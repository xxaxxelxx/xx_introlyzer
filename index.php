<?php
$cuser = getenv('REMOTE_USER');
if (empty($cuser)) {
    header("Location: http://".getenv('HTTP_HOST')."/index.php");
} else {
    header("Location: http://".getenv('HTTP_HOST')."/".getenv('REMOTE_USER'));
}
?>
