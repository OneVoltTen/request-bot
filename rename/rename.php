<?php
	@require"/root/app/config.php";
	include 'initial.php';

	if($handle=opendir($path)){
		chdir($path);
		while(false!==($fileName=readdir($handle))){
			if (file_exists($fileName) && !is_dir($fileName)) {
				if (($fileName != "." && $fileName != ".." && (strtolower(substr($fileName,strrpos($fileName,'.') + 1))=='mkv' || strtolower(substr($fileName,strrpos($fileName,'.') + 1))=='mp4'))){

					$str=$fileName;
					if (strpos($str,'AnimePahe') !== false && strpos($str,'|AnimePahe|') == false){
						#echo "> ".$str." has been renamed before... moving\n";
						@rename(DOWNLOADS."/".$str, QUEUE."/".$str);
						continue;
						}
					}else {
						include 'main.php';
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
