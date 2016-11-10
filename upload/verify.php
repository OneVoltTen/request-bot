<?php

mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME) or die("Unable to connect to ".DB_HOST."\n");

function urlExists($url=NULL){
    if($url == NULL) return false;  
    $ch = curl_init($url);  
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);  
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);  
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);  
    $data = curl_exec($ch);  
    $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);  
    curl_close($ch);  
	return $httpcode;
}
if(urlExists('nodefiles.com')==200 || urlExists('nodefiles.com')==0){
	die("Nodefiles unavailable\n");
}

// verify file extension and contain group before upload
$ar=array();
$g=array_diff(scandir(UPLOAD."/"), array('..', '.'));
foreach($g as $x){
	if(is_dir($x)){
		$ar[$x]=scandir($x);
	}else{
		$ar[]=$x;
	}
}
foreach($ar as &$itemx){
	$supported = array('mkv','mp4');
	$ext = strtolower(pathinfo($itemx, PATHINFO_EXTENSION));
	if (in_array($ext, $supported) && is_file(UPLOAD.'/'.$itemx) && strpos($itemx, GROUP) !== false) {
		//echo "valid ".$itemx."...\n";
	}else{
		echo "invalid ".$itemx."\n";
		rename(UPLOAD.'/'.$itemx, KOMARU.'/'.$itemx);
	}
}
