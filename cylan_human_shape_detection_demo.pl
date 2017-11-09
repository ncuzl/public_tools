#
#cylan人形检测范例，详细接口列表请参考http://yf.robotscloud.com/devdocs/OSR.md
#by zhongliang
#email 8201683@qq.com
#
use LWP;
use Digest::SHA qw(hmac_sha1_hex);
use MIME::Base64;
use URI::Escape;

my $browser = LWP::UserAgent->new();
my $timestamp = time();
my $service_key_secret = "kIbW0CIYlXnPDR7jKE4zqIErsmZKUeoS";
my $base64 = encode_base64(hmac_sha1_hex("/hsr/v3/hsr_detection"."\n".$timestamp, $service_key_secret));
chomp($base64);
my $signature = uri_escape_utf8($base64);

my $response = $browser->post(
	'https://apiyf.robotscloud.com/hsr/v3/hsr_detection',
	[ 'service_key' => 'O86hXeNXTs7ZTSieX0jmA2JbhVNlGpaJ',
		'file' => ["c:/a.jpg"],
		'sn'    => 'xxx',
		'service_code'    => 'xxx',
		'timestamp'    => $timestamp,
		'signature'    => $signature,
	],
	'Content_Type' => 'form-data'
);

print $response->content;