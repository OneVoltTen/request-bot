<?php
	if(!isset($anime) || !isset($fansub)){
		# Get metadata if not named properly
		echo "read meta => ".$fileName."\n";
		$output = shell_exec('/root/rename/meta.sh "'.DOWNLOADS.'/'.$fileName.'"');
		#echo "output => ".$output."\n";
		if(strpos($output, '|') !== false){
			$metadata=array_filter(explode('|', $output));
			$anime=$metadata[0];
			#$title=$metadata[1];
			if(!isset($metadata[2]) || empty($metadata[2]) || $metadata[2]==" "){$fansub="";}else{$fansub=$metadata[2];$fansub=ucfirst($fansub);}
			echo "id [".$anime."] fansub [".$fansub."]\n";
		}else{
			rename(DOWNLOADS."/".$fileName, KOMARU."/0".$fileName);
			die("invalid metadata and incorrect filename\n");
		}
	}
	// Remove fansub text
	$str=str_ireplace($fansub,'',$str);
	$fanpath="/root/rename/fansub";
	$fansubpath=$fanpath.'/'.$fansub.'.php';
	$fansubpath=strtolower($fansubpath);
	if(file_exists($fansubpath) && !empty(file_get_contents($fansubpath) && !empty($fansub))){
		echo "Yatta!\n";
		include $fansubpath;
		$str = str_ireplace($fansub, '', $str);					
	}else{
		echo "Undefined fansub meta\n";
		//get list of all fansub titles
		$ar=array();
		$g=array_diff(scandir($fanpath), array('..', '.'));
		foreach($g as $x){
			if(is_dir($x))$ar[$x]=scandir($x);
			else $ar[]=$x;
		}
		$ar=str_replace(".php","",$ar);
		//print_r($ar);
		$counter=0;
		#echo $str."\n";
		foreach($ar as &$fansubx){
			if (stripos($str,'_'.$fansubx) !== false || stripos($str,$fansubx.'_') !== false || stripos($str,'['.$fansubx.']') !== false || stripos($str,'-'.$fansubx) !== false || stripos($str,$fansubx.'-') !== false){
				if ($counter==0){
					echo "Yatta!! \n";
					$str = str_ireplace($fansubx, '', $str);
					$fansub=ucfirst($fansubx);
					include "/root/app/fansub/".$fansubx.".php";
					$counter++;
				}else{
					$counter++;
					echo $counter." Removing 2nd fansub\n";
					$str = str_ireplace("-".$fansubx, '', $str);
					$str = str_ireplace($fansubx."-", '', $str);
					$str = str_ireplace($fansubx, '', $str);
				}
			}
		}
		if($counter==0){
			echo"No fansub rewrite rule exists for fansub ".$fansub." [".$fileName."]\n";
		}elseif($counter>1){
			echo"Counter ".$counter." over one fansub rewrite!\n";
		}
	}

	if(!isset($fansub)){
		rename(DOWNLOADS."/".$fileName, KOMARU."/".$fileName);
		continue;
	}