<?php
	@require"/root/app/config.php";
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

	if(isset($argv[1])){
		if($argv[1]=="downloads"||$argv[1]=="downloads"){
			$path=DOWNLOADS."/";
		}elseif($argv[1]=="2"){
		$path = ENCODED."/";

		if ($handle = opendir($path)) {
			chdir($path);
			while (false !== ($fileName = readdir($handle))) {
				if (strpos($fileName, '_encoded'))  {
					$str = $fileName;
					$newName = $str;

					$str = str_ireplace("_Cant_", "_Can't_", $str);
					$str = str_ireplace("_I_ll_", "_I'll_", $str);
					$str = str_replace('_I_ve', "_I've", $str);

					$str = str_replace("TV_720p", "720p", $str);
					$str = str_replace("542p", "720p", $str);

					$str = str_replace('.mkv_encoded', '', $str);
					$str = str_replace('.mp4_encoded', '', $str);
					$str = str_replace('.avi_encoded', '', $str);
					$str = str_replace('.mkv', '', $str);

					$str = preg_replace('/\\.[^.\\s]{3,4}$/', '', $str);
					if (strpos($str,'.mkv') !== false) {
						$str = substr($str, 0, strpos($str, ".mkv"));
						$str = $str.".mp4";
					}
					$newName = str_replace(".mkv", ".mp4", $newName);
					$newName = str_replace(".mp4_encoded", "", str_replace(".mkv_encoded", "", str_replace(".avi_encoded", "", $newName)));
					//echo $fileName." => ".$newName."\n\n";
					rename($fileName, $newName);

					unset($str);
					unset($fileName);
					unset($newName);
				}
			}
			closedir($handle);
		}
		die('end2');
		# End 2
		}elseif($argv[1]=="renametest"){
			# Start renametest
			
			$path = UPLOADED."/";
			if ($handle = opendir($path)) {
				chdir($path);
				while (false !== ($fileName = readdir($handle))) {
					if (($fileName != "." && $fileName != ".." && (strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mkv' || strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mp4'))) {
						$str = $fileName;

						// Replaces all spaces with an underscore
						$str = str_replace('AnimePahe_', '', $str);
						$str = str_replace('mp4', 'mkv', $str);
						$newName = $str;
						//echo $fileName." => ".$newName."\n\n";
						rename($fileName, $newName);

						unset($str);
					}
				}
			}

			$path = DOWNLOADS."/";
			if ($handle = opendir($path)) {
				chdir($path);
			while (false !== ($fileName = readdir($handle))) {
					if (($fileName != "." && $fileName != ".." && (strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mkv' || strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mp4'))) {
						$str = $fileName;

						// Replaces all spaces with an underscore
						$str = str_replace('AnimePahe_', '', $str);
						$str = str_replace('mp4', 'mkv', $str);
						$newName = $str;
						//echo $fileName." => ".$newName."\n\n";
						rename($fileName, $newName);

						unset($str);
					}
				}
			}

			closedir($handle);
			die('11end');
			# End renametest
		
		}elseif($argv[1]=="00"){
			$path=DOWNLOADS."/.00/";
		}else{
			$path=$argv[1];
		}
	}else{
		$path=QUEUE."/";
	}
	if($handle=opendir($path)){
		chdir($path);
		while(false!==($fileName=readdir($handle))){

			if (($fileName != "." && $fileName != ".." && (strtolower(substr($fileName,strrpos($fileName,'.') + 1))=='mkv' || strtolower(substr($fileName,strrpos($fileName,'.') + 1))=='mp4'))){

				$str=$fileName;
				if (strpos($str,'AnimePahe') !== false && strpos($str,'|AnimePahe|') == false){
					//echo "> ".$str." has been renamed before...\n";
				} else {
					// Remove extension
					$extension=substr($str,-3,3);
					$str=substr($str,0,-4);

					// Linux filename dupe/copy test remove (tests)
					$str = str_replace('(1)', '', $str);
					$str = str_replace('(2)', '', $str);
					$str = str_replace('(copy)', '', $str);
					$str = str_replace('x264', '', $str);
					$str = str_replace('856x480', '', $str);
					$str = str_replace('x2', '', $str);
					$str = str_replace('é', 'e', $str);
					$str = str_replace('à', 'a', $str);

					// Check if file name contains CRC32 and remove it
					// Only works if crc32 is at end of filename
					if (substr($str,-1,1)=="]" && substr($str,-10,-9)=="["){
						$str=substr($str,0,-10);
					}
					if (substr($str,-1,1)==")" && substr($str,-10,-9)=="("){
						$str=substr($str,0,-10);
					}
					
					// Remove text between 'text' (typically episode names)
					$str=preg_replace("/'[\s\S]+?'/", '', $str);

					// Strip whitespaces
					$str=ltrim(rtrim($str));

					$str = str_replace('~', '_', $str);
					$str = str_replace(' ', '_', $str);
					$str = str_replace('.', '_', $str);
					$str = str_replace(',', '_', $str);
					$str = str_ireplace('_ep', '_', $str);
					$str = str_ireplace('OVA_0', 'OVA0', $str);
					$str = str_ireplace('OVA_1', 'OVA1', $str);
					if(!empty(file_get_contents($fileName))){
						$baseid = basename($str); // filename
						$fn=explode('|', $baseid);
						if(!empty($fn[0])){
							$anime=$fn[0];
							//echo $anime."\n";
						}else{
							echo "id not set [".$fileName."]\n";
							rename(DOWNLOADS."/".$fileName, KOMARU."/0".$fileName);
						}
						$fansub=$fn[1];
						//$str = str_replace($fn[0], '', $str);
						//$str = str_replace($fn[1], '', $str);
						$str = strstr($str, '|');#1
						$str = strstr($str, '|');#2
						# Get metadata
						# Both metadata methods have been disabled due to high ram usage
						/*
						echo "read meta => ".$fileName."\n";
						$output = shell_exec('/root/meta.sh '.DOWNLOADS.'/'.$fileName);
						echo "output => ".$output."\n";
						if(strpos($output, '|') !== false){
							$metadata=array_filter(explode('|', $output));
							$anime=$metadata[0];
							$title=$metadata[1];
							if(!isset($metadata[2]) || empty($metadata[2]) || $metadata[2]==" "){$fansub="";}else{$fansub=$metadata[2];$fansub=ucfirst($fansub);}
							if(empty($metadata[3])){$aud=0;}else{$aud=$metadata[3];}
							if(empty($metadata[4])){$sub=0;}else{$sub=$metadata[4];}
							echo "[".$anime."] [".$title."] [".$fansub."] [".$aud."] [".$sub."]\n";
						}else{
							die("invalid metadata\n");
						}
						*/
						/*
						require_once('/root/app/getid3/getid3.php');
						$getID3=new getID3;
						$path=realpath(DOWNLOADS.'/'.$fileName);
						$ThisFileInfo=$getID3->analyze($path);
						getid3_lib::CopyTagsToComments($ThisFileInfo);		$metadata=htmlentities(!empty($ThisFileInfo['comments_html']['title'])?implode('<br>',$ThisFileInfo['comments_html']['title']):chr(160));
						$metadata=array_filter(explode('|', $metadata));
						if(empty($metadata[0]) || empty($metadata[1])){
							var_dump($metadata);
							rename(DOWNLOAS."/".$fileName, KOMARU."/".$fileName);
							echo"CRITICAL > Metadata not set - ".$fileName."\n";
						}else{# Set metadata
							$anime=$metadata[0];
							$title=$metadata[1];
							if(!isset($metadata[2]) || empty($metadata[2]) || $metadata[2]==" "){
								$fansub="";
							}else{
								$fansub=$metadata[2];
								$fansub=ucfirst($fansub);
							}
							if(empty($metadata[3])){$aud=0;}else{$aud=$metadata[3];}
							if(empty($metadata[4])){$sub=0;}else{$sub=$metadata[4];}
							echo "[".$anime."] [".$title."] [".$fansub."] [".$aud."] [".$sub."]\n";
						}
						*/
						// Remove fansub text
						echo "Before fansub [ ".$str." ]\n";
						$str=str_ireplace($fansub,'',$str);
						$fansubpath='/root/app/fansub/'.$fansub.'.php';
						$fansubpath=strtolower($fansubpath);
						if(file_exists($fansubpath) && !empty(file_get_contents($fansubpath) && !empty($fansub))){
							echo "Yatta!\n";
							
							// Replace invalid fansub character
							$fansub = str_replace('μ', 'u', $fansub);
							
							include $fansubpath;
							$str = str_ireplace($fansub, '', $str);					
						}else{
							echo "Undefined fansub meta\n";
							//get list of all fansub titles
							$ar=array();
							$g=array_diff(scandir('/root/app/fansub/'), array('..', '.'));
							foreach($g as $x){
								if(is_dir($x))$ar[$x]=scandir($x);
								else $ar[]=$x;
							}
							$ar=str_replace(".php","",$ar);
							//print_r($ar);
							$counter=0;
							echo $str."\n";
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
								rename(DOWNLOADS."/".$fileName, KOMARU."/".$fileName);
								die("No fansub rewrite rule exists for ".$fileName."\n");
							}elseif($counter>1){
								echo"Counter ".$counter." over one fansub rewrite!\n";
							}
						}
					}else{
						die("No file found");
					}

					// Check video resolution
					if (strpos($str,'720p')==true || strpos($str,'x720')==true){
						$resolution="720p";
					} else if (strpos($str,'540p')==true || strpos($str,'x540')==true){
						$resolution="540p";
					} else if (strpos($str,'576p')==true || strpos($str,'x576')==true){
						$resolution="576p";
					} else if (strpos($str,'480p')==true || strpos($str,'x480')==true || strpos($str,'DVD')==true){
						$resolution="480p";
					} else if (strpos($str,'360p')==true || strpos($str,'x360')==true){
						$resolution="360p";
					} else if (strpos($str,'420p')==true || strpos($str,'x420')==true){
						$resolution="420p";
					} else {
						$resolution="720p";
					}
					
					// Replaces final
					$str=str_ireplace('final','',$str);

					// Replaces 24fps
					$str=str_ireplace('24fps','',$str);
					
					// Replaces multiple spaces with a space
					$str=preg_replace('/\s+/',' ',$str);

					// Replaces all spaces with an underscore
					$str=str_replace(' ','_',$str);

					// Replaces long dash with normal dash
					$str=str_replace('‒','-',$str);

					// Replaces all & with an "and"
					$str=str_replace('&','and',$str);
					
					// Remove delimiter
					$dash=substr_count($str,'_-_');

					// Replaces all weird characters with an underscore
					$str=preg_replace('/[^A-Za-z0-9@\_+.,-]/','_',$str);

					// Check BD version
					if (strpos($str,'_BD')==true || stripos($str,'bluray')==true || stripos($str,'blu-ray')==true || stripos($str,'bdrip')==true || stripos($str,'brip')==true || stripos($str,'brrip')==true || stripos($str,'bray')==true){
						$disc="BD";

					// Removes BD
					$str=str_ireplace('bray','',$str);
					$str=str_ireplace('brrip','',$str);
					$str=str_ireplace('brip','',$str);
					$str=str_ireplace('bdrip','',$str);
					$str=str_ireplace('blu-ray','',$str);
					$str=str_ireplace('bluray','',$str);
					$str=str_ireplace('blu_ray','',$str);
					$str=str_replace('BD','',$str);
					} else if (strpos($str,'DVD')==true){
						$disc="DVD";
						// Removes DVD
						$str=str_ireplace('dvd','',$str);
						$str=str_ireplace('dvdrip','',$str);
					}

					// Removes video resolutions
					$str=str_ireplace('360p','',$str);
					$str=str_ireplace('396p','',$str);
					$str=str_ireplace('480p','',$str);
					$str=str_ireplace('640x480','',$str);
					$str=str_ireplace('704x480','',$str);
					$str=str_ireplace('720x480','',$str);
					$str=str_ireplace('848x480','',$str);
					$str=str_ireplace('864x480','',$str);
					$str=str_ireplace('540p','',$str);
					$str=str_ireplace('576p','',$str);
					$str=str_ireplace('768x576','',$str);
					$str=str_ireplace('1024x576','',$str);
					$str=str_ireplace('720p','',$str);
					$str=str_ireplace('960x720','',$str);
					$str=str_ireplace('1280x720','',$str);
					$str=str_ireplace('1600x900','',$str);
					$str=str_ireplace('1440x1080','',$str);
					$str=str_ireplace('1920x1080','',$str);
					$str=str_ireplace('1080p','',$str);
					
					// Removes year
					$str=str_ireplace('2001','',$str);
					$str=str_ireplace('2002','',$str);
					$str=str_ireplace('2003','',$str);
					$str=str_ireplace('2004','',$str);
					$str=str_ireplace('2005','',$str);
					$str=str_ireplace('2006','',$str);
					$str=str_ireplace('2007','',$str);
					$str=str_ireplace('2008','',$str);
					$str=str_ireplace('2009','',$str);
					$str=str_ireplace('2010','',$str);
					$str=str_ireplace('2011','',$str);
					$str=str_ireplace('2012','',$str);
					$str=str_ireplace('2013','',$str);
					$str=str_ireplace('2014','',$str);
					$str=str_ireplace('2015','',$str);
					$str=str_ireplace('2016','',$str);
					$str=str_ireplace('2017','',$str);
					$str=str_ireplace('2018','',$str);
					
					// Removes video depth
					$str=str_ireplace('8bit','',$str);
					$str=str_ireplace('8-bit','',$str);
					$str=str_ireplace('10bit','',$str);
					$str=str_ireplace('10-bit','',$str);
					$str=str_ireplace('Hi10p','',$str);
					$str=str_ireplace('Hi10','',$str);
					$str=str_ireplace('H10P','',$str);
					$str=str_ireplace('Hi444PP','',$str);

					// Removes video codec
					$str=str_ireplace('h264','',$str);
					$str=str_ireplace('h.264','',$str);
					$str=str_ireplace('h_264','',$str);
					$str=str_ireplace('x264','',$str);
					$str=str_ireplace('x.264','',$str);
					$str=str_ireplace('x_264','',$str);
					$str=str_ireplace('h265','',$str);
					$str=str_ireplace('h.265','',$str);
					$str=str_ireplace('h_265','',$str);
					$str=str_ireplace('h_265','',$str);
					$str=str_ireplace('x265','',$str);
					$str=str_ireplace('hevc','',$str);

					// Removes audio codec
					$str=str_ireplace('aac','',$str);
					$str=str_ireplace('flac','',$str);
					$str=str_ireplace('ac3','',$str);
					$str=str_ireplace('opus','',$str);
					$str=str_ireplace('ogg','',$str);
					$str=str_ireplace('vorbis','',$str);

					// Removes tv station
					$str=str_ireplace('BS11','',$str);
					$str=str_ireplace('_Web_','',$str);

					// Remove all weird characters
					$fansub=preg_replace('/[^A-Za-z0-9@&\_+.,-]/','',$fansub);

					// Replaces all weird characters with an underscore
					$str=preg_replace('/[^A-Za-z0-9@\_+.,-]/','_',$str);

					// Replaces multiple underscores with an underscore
					$str=preg_replace('/[_]+/','_',$str);

					// Strip underscores
					$str=ltrim(rtrim($str,"_"),"_");

					// Strip dash
					$str=ltrim(rtrim($str,"-"),"-");

					// Strip underscores
					$str=ltrim(rtrim($str,"_"),"_");

					// Strip dash
					$str=ltrim(rtrim($str,"-"),"-");

					// Strip underscores
					$str=ltrim(rtrim($str,"_"),"_");
					
					// Replaces multiple
					//$str=preg_replace('/[_-_]+/','_-_',$str);

					if (isset($disc) || (isset($argv[2]) && $argv[2]=="noV")){
						if (substr($str,-2,2)=="v2" || substr($str,-2,2)=="v3" || substr($str,-2,2)=="v4"){
							$str=str_ireplace('v2','',str_ireplace('v3','',str_ireplace('v4','',$str)));
						}
					}
					
					// Replaces revision with spaces
					$str=str_replace('_v0','v0',$str);
					$str=str_replace('_v1','v1',$str);
					$str=str_replace('_v2','v2',$str);
					$str=str_replace('_v3','v3',$str);
					$str=str_replace('_v4','v4',$str);
					$str=str_replace('_v5','v5',$str);
					$str=str_replace('_v6','v6',$str);
					$str=str_replace('_v7','v7',$str);
					$str=str_replace('_v8','v8',$str);
					
					$str = str_replace("_s_", "s_", $str);

					if (isset($disc)){
						$str=$anime."AnimePahe_".$str."_".$disc."_".$resolution."_".$fansub.".".$extension;
					} else {
						$str=$anime."AnimePahe_".$str."_".$resolution."_".$fansub.".".$extension;
					}

					//echo "Video resolution: ".$resolution."\n";
					$newName=$str;
					echo $fileName." =>\n".$newName."\n";
					rename($fileName,$newName);

					unset($str);
					unset($disc);
					unset($resolution);
					unset($resX);
					unset($resY);
					unset($scaledResX);
					unset($scaledResY);
					unset($extension);
					sleep(1);
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
