<?php
if (stripos($fansub,'tlacatlc6') !== false) {
	$underscore = substr_count($str, "_");
	$str = substr_replace($str, "_-_", strposX($str, "_", $underscore), 1);
}

