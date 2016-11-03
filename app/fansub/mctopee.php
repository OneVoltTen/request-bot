<?php
if (stripos($str,'Magical_Girl_Lyrical_Nanoha') !== false) {
	echo "match!\n";
	$str=str_ireplace('Magical_Girl_Lyrical_Nanoha_','Magical_Girl_Lyrical_Nanoha_-_',$str);
	$str=str_ireplace('_-_','_-_BD_720p',$str);
}

