/*
cylan人形检测范例，详细接口列表请参考http://yf.robotscloud.com/devdocs/OSR.md
by zhongliang
email 8201683@qq.com
*/
<?php
function getSignature($str, $key) {
	$signature = "";
	if (function_exists('hash_hmac')) {
		$signature = base64_encode(hash_hmac("sha1", $str, $key, false));
	} else {
		$blocksize = 64;
		$hashfunc = 'sha1';
		if (strlen($key) > $blocksize) {
			$key = pack('H*', $hashfunc($key));
		}
		$key = str_pad($key, $blocksize, chr(0x00));
		$ipad = str_repeat(chr(0x36), $blocksize);
		$opad = str_repeat(chr(0x5c), $blocksize);
		$hmac = pack(
			'H*', $hashfunc(
				($key ^ $opad) . pack(
					'H*', $hashfunc(
						($key ^ $ipad) . $str
					)
				)
			)
		);
		$signature = base64_encode($hmac);
	}
	return $signature;
}

$timestamp=time();
$service_key_secret = "kIbW0CIYlXnPDR7jKE4zqIErsmZKUeoS";
$signature = getSignature("/hsr/v3/hsr_detection"."\n".$timestamp, $service_key_secret);
$postdata=array(
	'service_key'=>'O86hXeNXTs7ZTSieX0jmA2JbhVNlGpaJ',
	'sn'=>'xxx',
	'service_code'=>'xxx',
	'timestamp'=>$timestamp,
	'signature'=>urlencode($signature),
	'file'=>new CURLFile(realpath('C:\\a.jpg'))
);

$ch = curl_init("http://apiyf.robotscloud.com/hsr/v3/hsr_detection");
curl_setopt($ch, CURLOPT_VERBOSE, 1);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION,1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);
$ret = curl_exec($ch);
print_r($ret);
curl_close($ch);
?>