<?php
if (stripos($fansub,'horriblesubs') !== false) {
	$underscore = substr_count($str, "_");
	$str = substr_replace($str, "_-_", strposX($str, "_", $underscore), 1);
}
$str=str_replace('CR','',$str);
$fansub="HorribleSubs";
//Mahoutsukai_no_Yome_-_Hoshi_Matsu_Hito
$str=str_replace("Mahoutsukai_no_Yome_-_Hoshi_Matsu_Hito","Mahoutsukai_no_Yome",$str);
$str=str_replace("The_Ancient_Magus'_Bride_-_Those_Awaiting_a_Star_-_","",$str);

