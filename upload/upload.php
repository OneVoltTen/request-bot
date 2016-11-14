<?php

//define('DB_HOST', '185.52.2.96');
//define('DB_PASS', 'MaxumX8208G1!');

@include"/root/app/config.php";

$path = UPLOAD."/";
if ($handle = opendir($path)) {
	chdir($path);
	while (false !== ($fileName = readdir($handle))) {
		if (strpos($fileName, '_encoded'))  {
			$str = $fileName;
			$newName = $str;

			$str = str_replace('.mkv_encoded', '', $str);
			$str = str_replace('.mp4_encoded', '', $str);
			$str = str_replace('.avi_encoded', '', $str);
			$str = str_replace('.mkv.mp4', '', $str);

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

date_default_timezone_set("UTC");
session_start();

require_once"/root/upload/verify.php";

try {
	$uploader = new GwshareUploader(GWSHARE_USER, GWSHARE_PASS);
	$upload	= $uploader->uploadBatch();
	var_dump($upload);
} catch (Exception $e) {
	@rename(UPLOAD."/".$_SESSION['basename1'], UPLOAD."/".$_SESSION['basename']);
	die(var_dump($e->getMessage()));
}

/* -- Nodefiles Uploader -- */

	final class GwshareUploader{
		const URL_SHORTURL				= 'https://lnjt.in/shorten';
		const URL_LOGIN					 = 'https://nodefiles.com/';
		const URL_LOGOUT					= 'https://nodefiles.com/?op=logout';
		const CODE_PARAMETER_TYPE_ERROR	 = 0x10020101;
		const CODE_FILE_READ_ERROR		= 0x10010101;
		const CODE_CURL_ERROR			 = 0x10040101;
		const CODE_LOGIN_ERROR			= 0x10040201;
		const CODE_UPLOAD_ERROR			 = 0x10040401;
		const CODE_CURL_EXTENSION_MISSING = 0x10080101;

		protected $username;
		protected $password;
		protected $loggedIn = false;
		protected $cookies = [];
		
		public function uploadBatch(){
		$ignoreFiles = [
			'.gitignore',
		];
		$encodedFiles = [];
		foreach (new DirectoryIterator(UPLOAD) as $item){
			if (! $item->isDot() && $item->isFile() && ! in_array($item->getFilename(), $ignoreFiles)){
				$encodedFiles[$item->getMTime()] = $item->getPathname();
			}
		}
		asort($encodedFiles);
		foreach ($encodedFiles as $encodedFile) {
			$source = $encodedFile;
			$result[] = $this->upload($source);
		}
		if(!empty($result)){
			//var_dump($result);
			return $result;
		}else{
			die("Upload queue empty!\n");
		}
	}

	public function upload($source){
		if (! is_file($source) or !is_readable($source)) {
			throw new Exception("File '$source' does not exist or is not readable.", self::CODE_FILE_READ_ERROR);
		}
		
		$basename = basename($source);
		$fn=explode(GROUP, $basename, 2);
		$anime=$fn[0];
		$crc32 = hash_file('crc32b', $source);
		$filesize = filesize($source);

		// <5MB abort upload
		if($filesize<5000){
			if (!file_exists(KOMARU.'/5mb')) {
				mkdir(KOMARU.'/5mb');
			}
			rename($source, KOMARU.'/5mb/'.$anime.''.$basename);
			die("filesize less than 5mb ".$basename."\n");
		}
		
		// verify
		if(!isset($fn[0]) || empty($fn[0]) || empty($filesize) || $filesize == 0){
			if (!file_exists(KOMARU.'/0')) {
				mkdir(KOMARU.'/0');
			}
			rename($source, KOMARU.'/0/'.$anime.''.$basename);
			die("unknown id ".KOMARU.'/0/'.$anime.''.$basename."\n");
		}
		
		$basename1 = strstr($basename, GROUP);
		echo "upload ".str_replace(GROUP."_","",$basename1)."...\n";
		$_SESSION['crc32']=$crc32;
		$_SESSION['anime']=$anime;
		$_SESSION['source']=$source;
		$_SESSION['basename']=$basename;
		$_SESSION['basename1']=$basename1;
		
		if(!isset($_SESSION["test"])){
			$source=UPLOAD."/".strstr($basename, GROUP);
			rename(UPLOAD."/".$basename, $source);
			$basename = str_replace($fn[0], "", $basename);
		}
		
		if(!isset($_SESSION["test"])){
			if (! $this->loggedIn) {
				$this->login();
			}
			$getUploadPage = $this->getUploadPage();
			$postData = [
				'sess_id' => $this->loggedIn,
				'utype' => $getUploadPage['utype'],
				'file_descr' => '',
				'file_0' => $this->curlFileCreate($source),
			];
			$upload = $this->request($getUploadPage['formAction'], $postData);
			if (! preg_match('/(?<=file_code\":\")\w+/', $upload, $match)) {
				throw new Exception('Upload failed!', self::CODE_UPLOAD_ERROR);
			}
			$uploadUrl = 'https://nodefiles.com/'.$match[0];
			$shortUrl = $this->shorten($uploadUrl);
			$shortUrl = str_replace("https://lnjt.in/", "", $shortUrl);
		}
		
		//filename
		$disc = "";
		if (stripos($basename, "_BD_") !== false) {
			$disc = "1";
		} elseif (stripos($basename, "_DVD_") !== false) {
			$disc = "2";
		} elseif (strpos($basename, 'OVA') !== false) {
			$episode = "OVA";
		}
		$end=".";
		$resmatch = array("BD_720p", "DVD_720p", "BD_692p","BD_690p","BD_688p","BD_544p","BD_480p","DVD_480p","480p","DVD_576p","BD_576p","576p","420p","396p","DVD_476p","DVD_474p","DVD_352p","544p","540p","DVD_528p","528p","720p","690p","692p","693p","694p","360p");
		foreach($resmatch as $rmatch){
			$rmatch = str_replace("<br>", "", $rmatch);
			if(strpos($basename, $rmatch)){
				$end=$rmatch;
				if(strlen($rmatch)>3 && strlen($rmatch)<6){
					$resolution=$rmatch;
				}
			}
		}
		if(!isset($resolution) && stripos($basename,'p_') !== false){
			if(isset($end) && empty($end)){
				$resolution = str_replace("_", "", $end);
			}else{			
				$explosion = explode("_",$basename); 
				foreach($explosion as $part){
					if(strpos($part,'p') !== false && strpos($part,'p',3)){
						echo $resolution = $part;
					}
				}
				
			}
		}
		$dash = substr_count($basename, '_-_');
		if (stripos($basename, "p_-__-.mkv") !== false) {
			$dash = $dash - 1;
		}
		$start = "_-_";
		$namafile = $basename;
		$ini = $this->strposX($basename, $start, $dash);
		if ($ini == 0) return "";
		$ini += strlen($start);
		$len = strpos($namafile,$end,$ini) - $ini;
		if (substr_count($basename, $start) == "0") {
			$episode = "";
		} else if (substr_count(strtoupper($basename), strtoupper("movie")) != "0") {
			$episode = "";
		} else if (substr_count($basename, $start) == "2") {
			$episoder = explode("_-_", $basename);
			if(!empty($episoder[1])){
				$episode = $episoder[1];
			}else{
				$episode = "";
			}
		} else {
			$episode = substr($namafile,$ini,$len);
		}
		if(substr($episode, -1) == '-' || substr($episode, -1) == '_' ) {
			$episode = substr($episode, 0, -1);
		}
		$episode = str_replace("BD", "", $episode);
		$episode = str_replace("DVD", "", $episode);
		$episode = rtrim($episode, '_');
		$episode = rtrim($episode, 'a');
		$episode = rtrim($episode, 'b');
		if(strlen($episode)==3 && substr_count($episode,"_",1) || strlen($episode)==5 && substr_count($episode,"_",2) || strlen($episode)==7 && substr_count($episode,"_",3)){//_ > 01-02 / 001-002
			$episode = str_replace("_", "-", $episode);
		}else{
			$episode = str_replace("_", "", $episode);
		}
		$episode=preg_replace('/[_]+/','_',$episode);
		$episode = str_replace("_", "", $episode);
		if (!is_numeric($episode) && stripos($episode, "-") == false) {
			$match=0;
			if(ctype_alpha($episode)){
				if (stripos($basename, "OVA") !== false || stripos($basename, "SP") !== false) {
				$episode = substr($namafile,$ini,$len);
				$episode = str_replace("BD", "", $episode);
				$episode = str_replace("DVD", "", $episode);
				$match++;
				}
			}
			$episode = str_replace("OVA", "", $episode);
			$episode = str_replace("ONA", "", $episode);
			if (!is_numeric($episode)){
				$yes = array("v0", "v1", "v2", "v3", "v4", "v5", "movie", "special", "ova", "ona");
				foreach($yes as $allowed){
					if(stripos($episode, $allowed)){
						$match++;
					}
				}
				if($match==0){
					echo "Invalid episode\n";
					$episode="";
				}
			}
		}
		if (is_numeric($episode) && strlen($episode) == 1) {
				$episode="0".$episode;
		}
		if(substr($episode,0,1)==0 && strlen($episode) > 2){
			$episode = substr($episode, 1);
		}
		
		// Revision
		$revision="";
		$list = array("v0_", "v1_", "v2_", "v3_", "v4_", "v5_");
		foreach($list as $revise){
			if(stripos($episode, $revise)){
				$episode=str_ireplace($revise,"",$episode);
				$revision=str_ireplace("v","",$revise);
			}
		}
		
		$fansub = "";
		
		$start = $end;
		$end = ".";
		$namafile = " ".$basename;
		$ini = strpos($namafile,$start);
		if ($ini == 0) return "";
		$ini += strlen($start);
		$len = strpos($namafile,$end,$ini) - $ini;
		$fansub = substr($namafile,$ini,$len);
		$fansub = str_replace("_", "", $fansub);

		if(isset($_SESSION["test"])){
			echo "filename - ".$basename."\n";
			echo "filesize - ".$filesize."\n";
			echo "crc32 - ".$crc32."\n";
			echo "anime - ".$anime."\n";
			echo "episode - ".$episode."\n";
			echo "revision - ".$revision."\n";
			echo "fansub - ".$fansub."\n";
			echo "resolution - ".$resolution."\n";
			echo "disc - ".$disc."\n";
		}else{
			if(empty($filesize) || $filesize == 0 || empty($anime) || $anime == 0){
				if(isset($filesize) && empty($filesize) || $filesize == 0){echo"invalid filesize\n";}
				if(isset($anime) && empty($anime) || $anime == 0){echo"invalid anime id\n";}
				
				if (!file_exists(UPLOAD.'/0/')) {
					mkdir(UPLOAD.'/0/');
				}
				echo "error ".UPLOAD.'/0/'.$anime.''.$basename."\n";
				rename($source, UPLOAD.'/0/'.$anime.''.$basename);
				die();
			}
			
			$data = [
				'filename'		=> $basename,
				'filesize'		=> $filesize,
				'crc32'			=> $crc32,
				'anime'			=> $anime,
				'episode'		=> $episode,
				'revision'		=> $revision,
				'fansub'		=> $fansub,
				'resolution'	=> $resolution,
				'upload_url'	=> $uploadUrl,
				'short_url'		=> $shortUrl,
				'disc'			=> $disc,
			];
			// save to db
			$this->saveToDb($data);
			$this->updateAnime($data);
			
			if (UPLOADED) {
				if (! file_exists(UPLOADED) || ! is_readable(UPLOADED)) {
					throw new Exception('Directory for move file doesn\'t exists or readable');
				}

				if(isset($_SESSION["test"]) && !empty($_SESSION["test"])){
					@rename($source, DOWNLOADS."/".$basename);
					$_SESSION["test"]="";
				}else{
					if(isset($anime) && !empty($anime)){
						if (!file_exists(UPLOADED.'/'.$anime)) {
							mkdir(UPLOADED.'/'.$anime);
						}
						echo "upload success ".UPLOADED.'/'.$anime.'/'.$anime.''.$basename."\n";
						@rename($source, UPLOADED.'/'.$anime.'/'.$anime.''.$basename);
					}else{
						@rename($source, UPLOADED.'/'.$anime.''.$source);
					}
				}
				//rmdir(UPLOAD."/".$crc32);
				@unlink($source);
			} else {
				// delete file
				@unlink($source);
			}

			return $data;

			sleep(2);
		}
	}

	public function __construct($username, $password)
	{
		if (! extension_loaded('curl')) {
			throw new Exception('uploader require the cURL extension\n', self::CODE_CURL_EXTENSION_MISSING);
		}
		if (empty($username) || empty($password)) {
			throw new Exception((empty($username) ? 'Email' : 'Password').' must not be empt\n.', self::CODE_PARAMETER_TYPE_ERROR);
		}
		$this->username	= $username;
		$this->password	= $password;
	}

	public function shorten($url){
		$postData = [
			'url'=> $url,
			'custom'=> '',
			'password'=> '',
			'description'=> '',
			'multiple'=> 0,
		];
		$request = $this->request(self::URL_SHORTURL, $postData);
		if (! preg_match('/{.*}/', $request, $match)) {
			var_dump($json);
			throw new Exception('shorten url failed: '.$url);
		}
		$json = json_decode($match[0]);
		return $json->short;
	}

	protected function login(){
		$postData = [
			'login'	=> (string) $this->username,
			'password' => (string) $this->password,
			'op'		 => 'login',
			'redirect' => '',
		];

		$login = $this->request(self::URL_LOGIN, http_build_query($postData));

		if (stripos($login, 'xfss') === false) {
			throw new Exception('Login failed.', self::CODE_LOGIN_ERROR);
			echo "481x\n";
		}

		// get xfss
		preg_match_all('/^Set-Cookie:\s*([^;]*)/mi', $login, $matches);

		$cookies = [];

		foreach ($matches[1] as $item) {
			parse_str($item, $cookie);

			$cookies = array_merge($cookies, $cookie);
		}

		$this->loggedIn = $cookies['xfss'];
	}

	protected function getUploadPage(){
		if (! $this->loggedIn) {
			$this->login();
		}

		$data = $this->request(self::URL_LOGIN);

		$formAction = null;
		$utype		= null;

		if (! preg_match('/(?<=uploadfile" action=")[^"]*/', $data, $match)) {
			throw new Exception('Unable to get upload URL');
		}

		$formAction = reset($match);

		if (! preg_match('/(?<=utype" value=")[^"]*/', $data, $match)) {
			throw new Exception('Unable to get UTYPE');
		}

		$utype = reset($match);

		return compact('formAction', 'utype');
	}

	protected function logout(){
		$data = $this->request(self::URL_LOGOUT);

		if (! empty($data) && strpos($data, 'HTTP/1.1 302 FOUND') !== false) {
			$this->loggedIn = false;
		}
	}

	protected function request($url, $postData = null){
		$ch = curl_init();

		curl_setopt($ch, CURLOPT_URL, (string) $url);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 2);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
		curl_setopt($ch, CURLINFO_HEADER_OUT, true);
		curl_setopt($ch, CURLOPT_HEADER, true);
		curl_setopt($ch, CURLOPT_HTTPHEADER, ['Expect:']);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

		if ($postData) {
			curl_setopt($ch, CURLOPT_POST, true);
			curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
		}

		// send cookies
		$rawCookies = [];

		foreach ($this->cookies as $k => $v) {
			$rawCookies[] = "$k=$v";
		}

		$rawCookies = implode(';', $rawCookies);

		curl_setopt($ch, CURLOPT_COOKIE, $rawCookies);

		$data	= curl_exec($ch);
		$error = sprintf('Curl error: (#%d) %s', curl_errno($ch), curl_error($ch));
		curl_close($ch);

		if (! $data) {
			echo "error connect ".UPLOAD.'/'.$anime.''.$basename."\n";
			rename($source, UPLOAD.'/'.$anime.''.$basename);
			throw new Exception($error, self::CODE_CURL_ERROR);
			die();
		}

		// store received cookies
		preg_match_all('/Set-Cookie: ([^=]+)=(.*?);/i', $data, $matches, PREG_SET_ORDER);

		foreach ($matches as $match) {
			$this->cookies[$match[1]] = $match[2];
		}

		return $data;
	}

	protected function curlFileCreate($file)
	{
		$filename = basename($file);
		if (function_exists('curl_file_create')) {
			return curl_file_create($file, "video/mp4", $filename);
		}
		// Use the old style if using an older version of PHP
		$value = "@{$this->filename};filename=".$filename;

		return $value;
	}

	protected function saveToDb(array $data){
		try {
			$db = new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8', DB_USER, DB_PASS);

			$sql = 'INSERT INTO releases(filename, filesize, crc32, anime_id, episode, revision, fansub, upload_url, short_url, disc, published, created_at) 
				VALUES (:filename, :filesize, :crc32, :anime, :episode, :revision, :fansub, :upload_url, :short_url, :disc, :published, :created_at)';
			$sql	= $db->prepare($sql);
			$insert = $sql->execute([
				':filename'		=> $data['filename'],
				':filesize'		=> $data['filesize'],
				':crc32'		=> $data['crc32'],
				':anime'		=> $data['anime'],
				':episode'		=> $data['episode'],
				':revision'		=> $data['revision'],
				':fansub'		=> $data['fansub'],
				':upload_url'	=> $data['upload_url'],
				':short_url'	=> $data['short_url'],
				':disc'			=> $data['disc'],
				':published'	=> '1',
				':created_at'	=> date('Y-m-d H:i:s'),
			]);

			return $db->lastInsertId();
		} catch (PDOException $e) {
			throw new Exception($e->getMessage());
		}
	}

	protected function updateAnime(array $data)
	{
		try {
			$db = new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8', DB_USER, DB_PASS);

			if ($data['disc'] !== "") {
				$sql = 'UPDATE animes SET disc = :disc, published = :published, updated_at = :updated_at WHERE id = :anime';
			} else {
				$sql = 'UPDATE animes SET published = :published, updated_at = :updated_at WHERE id = :anime';
			}

			$statement = $db->prepare($sql);

			if (isset($data['status']) && isset($data['completed'])) {
				$statement->bindValue(":status", $data['status']);
				$statement->bindValue(":completed", $data['completed']);
			}
			if ($data['disc'] !== "") {
				$statement->bindValue(":disc", $data['disc']);
			}
			$statement->bindValue(":anime", $data['anime']);
			$statement->bindValue(":published", "1");
			$statement->bindValue(":updated_at", date('Y-m-d H:i:s'));

			$count = $statement->execute();

			$db = null;
			// return $db->lastInsertId();
		} catch (PDOException $e) {
			throw new Exception($e->getMessage());
		}
	}

	protected function strposX($haystack, $needle, $number)
	{
		if($number == '1') {
			return strpos($haystack, $needle);
		} elseif ($number > '1') {
			return strpos($haystack, $needle, $this->strposX($haystack, $needle, $number - 1) + strlen($needle));
		} else {
			return error_log('Error: Value for parameter $number is out of range');
		}
	}

	public function __destruct()
	{
		if ($this->loggedIn) {
			$this->logout();
		}
	}

}
