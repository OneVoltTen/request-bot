<?php
	$running = exec("ps aux|grep ". basename(__FILE__) ."|grep -v grep|wc -l");
	if($running > 1) {die("rename already running");}
	
	# Move all non mkv/mp4/avi move to komaru folder
	$ar=array();
	$g=array_diff(scandir(DOWNLOADS."/"), array('..', '.'));
	foreach($g as $x){
		if(is_dir($x))$ar[$x]=scandir($x);
		else $ar[]=$x;
	}
	foreach($ar as &$itemx){
		$supported = array('mkv','mp4','avi');
		$ext = strtolower(pathinfo($itemx, PATHINFO_EXTENSION));
		if (!in_array($ext, $supported) && is_file($itemx)) {
			rename(DOWNLOADS."/".$itemx, KOMARU."/".$itemx);
		}
	}
	if(!isset($argv[1])){die();}
	else{
		if($argv[1]=="downloads"){
			$path=DOWNLOADS."/";
		}elseif($argv[1]=="verify" || $argv[1]=="upload"){
			if($argv[1]=="verify"){
				$path = VERIFY."/";
			}elseif($argv[1]=="upload"){
				$path = UPLOAD."/";
			}

			if ($handle = opendir($path)) {
				chdir($path);
				while (false !== ($fileName = readdir($handle))) {
					if (strpos($fileName, '_encoded'))  {
						$str = $fileName;
						$newName = $str;
						$str = str_replace(array('.mkv_encoded', ".mp4_encoded", ".avi_encoded", ".mkv"), '', $str);
						$str = preg_replace('/\\.[^.\\s]{3,4}$/', '', $str);
						if (strpos($str,'.mkv') !== false) {
							$str = substr($str, 0, strpos($str, ".mkv"));
							$str = $str.".mp4";
						}
						//echo $fileName." => ".$str."\n\n";
						rename($fileName, $str);
						unset($str);unset($fileName);unset($str);
					}
				}
				closedir($handle);
			}
		}else{$path=$argv[1];}
	}