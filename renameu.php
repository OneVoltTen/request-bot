<?php

# Move all non mkv/mp4/avi move to kmoaru folder
$ar=array();
$g=array_diff(scandir('/var/www/downloads/'), array('..', '.'));
foreach($g as $x){
	if(is_dir($x))$ar[$x]=scandir($x);
	else $ar[]=$x;
}
foreach($ar as &$itemx){
	$supported = array('mkv','mp4','avi');
	$ext = strtolower(pathinfo($itemx, PATHINFO_EXTENSION));
	if (!in_array($ext, $supported) && is_file($itemx)) {
		rename('/var/www/downloads/'.$itemx, '/var/www/komaru/'.$itemx);
	}
}

?>
