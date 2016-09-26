<?php
include"/root/app/config.php";

if(!isset($argv[1])){die("undefined arg\n");}
elseif(!is_numeric($argv[1])){die("unnumeric arg\n");}
elseif(!($argv[1]>0 && $argv[1]<10000)){die("out of range arg\n");}

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
if(urlExists(DB_HOST)==200 || urlExists(DB_HOST)==0){die(DB_HOST." unavailable\n");}

$con=mysqli_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
if($con->connect_error){die("Connection failed: ".$con->connect_error);} 

$datenow=date('Y-m-d H:i:s');
$sql="UPDATE `request` SET `last_sort`='".$datenow."' WHERE `mal`=".$argv[1];
if($con->query($sql) === TRUE) {
	if(mysqli_affected_rows($con)!=0){echo "request last_sort updated\n";}
	else{die("request last_sort failed\n");}
}else{echo "error updating record: ".$cnn->error."\n";}

$sql="UPDATE `animes` SET `published`=1 WHERE `id`=".$argv[1];
if($con->query($sql) === TRUE) {
	echo "animes published updated\n";
}else{echo "error updating record: ".$cnn->error."\n";}

$con->close();

?>
