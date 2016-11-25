<?php
	require"/root/app/config.php";
	include "/root/rename/initial.php";

	if($handle=opendir($path)){
		chdir($path);
		echo "initiate rename [".$path."]...\n";
		while(false!==($fileName=readdir($handle))){
			if (file_exists($fileName) && !is_dir($fileName)) {
				if (($fileName != "." && $fileName != ".." && (strtolower(substr($fileName,strrpos($fileName,'.') + 1))=='mkv' || strtolower(substr($fileName,strrpos($fileName,'.') + 1))=='mp4'))){

					echo "file found [".$fileName."]\n";
					$str=$fileName;
					if(strpos($str,'AnimePahe') !== false && strpos($str,'|AnimePahe|') == false){
						echo "> ".$fileName." has been renamed before... moving\n";
						@rename(DOWNLOADS."/".$str, QUEUE."/".$str);
						continue;
						}
						include '/root/rename/main/main.php';
					}
			}
		}
		closedir($handle);
	}
function strposX($haystack,$needle,$number){
	if($number=='1'){
		return strpos($haystack,$needle);
	}elseif($number>'1'){
		return strpos($haystack,$needle,strposX($haystack,$needle,$number-1)+strlen($needle));
	}else{
		return error_log('Error: Value for parameter $number is out of range');
	}
}
?>
