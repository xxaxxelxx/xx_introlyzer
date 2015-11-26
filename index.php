<?php

echo "AAA";
echo "BBB".getenv('HTTP_HOST')."BBB";
echo "CCC".getenv('REMOTE_USER')."CCC";


#echo ZUUUPPPIII;
#header("Location: http://".getenv('HTTP_HOST')."/".getenv('REMOTE_USER'));
#header("Location: http://".getenv('HTTP_HOST').":81/bbradio");
exit;




$ip = getenv('REMOTE_ADDR');
$agent = getenv('HTTP_USER_AGENT');
$mountpoint = $_GET['mnt'];
include("functions.php");
init_db();

$tstampnow = time();

# static switches
switch ($mountpoint) {
    case 'bbr_master.mp3':
	header("Location: http://141.16.141.4/bbr_master.mp3");
        exit;
    case 'tdy_master.mp3':
	header("Location: http://141.16.141.4/tdy_master.mp3");
        exit;
    case 'bbr_cable.mp3':
	header("Location: http://141.16.141.4/bbr_cable.mp3");
        exit;
    case 'rt_cable.mp3':
	header("Location: http://141.16.141.4/rt_cable.mp3");
        exit;
    case 'rt_bremen.mp3':
	header("Location: http://141.16.141.3/rt_bremen.mp3");
        exit;
    case 'rt_kassel.mp3':
	header("Location: http://141.16.141.3/rt_kassel.mp3");
        exit;
    case 'rt_koblenz.mp3':
	header("Location: http://141.16.141.3/rt_koblenz.mp3");
        exit;
    case 'rt_schwerin.mp3':
	header("Location: http://141.16.141.3/rt_schwerin.mp3");
        exit;
# very special | rewrite some stuff
    case 'egal.mp3':
	header("Location: http://".getenv('HTTP_HOST')."/bbradio.mp3");
        exit;
}

# within which time in seconds clients will be assumed as alive and selectable
$tmaxage = 10;
$tstampoldest = $tstampnow - $tmaxage;

error_reporting(E_ALL);

# maximum accepted load of a player
$maxload = 90;

# within which time in seconds clients will stay in pool
$maxage = 3600;
$maxagelimitstamp = $tstampnow - $maxage; 
cleanup_listeners($maxagelimitstamp);

if ( ! isset($ip,$agent,$mountpoint) ) exit;

$fingerprint = md5($ip.$agent.$mountpoint);

$db = new SQLite3('load.db');
$result = $db->query("SELECT * FROM t_pool WHERE mountpoint LIKE '/$mountpoint' AND load <= $maxload AND timestamp > $tstampoldest ORDER BY bandwidth ASC LIMIT 1");
#echo $db->lastErrorMsg();

$wellknown = $db->query("SELECT * FROM t_listeners WHERE fingerprint = '$fingerprint'");

$errortext = "this stream is not available";
$errorspeech = urlencode($errortext);

$redirect = "Location: http://translate.google.com/translate_tts?tl=en&q=".$errorspeech;
$prefix = "/intro.";

while ( $wrow = $wellknown->fetchArray() ) {
    $prefix = "/";
}
while ( $row = $result->fetchArray() ) {
    $mount = ltrim($row['mountpoint'],'/');
    $redirect = "Location: http://".$row['machineip'].$prefix.$mount;
}

$db->exec("REPLACE INTO t_listeners (
	fingerprint,
	timestamp) VALUES (
	'$fingerprint',
	$tstampnow)");

$db->close();

header($redirect);

?>

