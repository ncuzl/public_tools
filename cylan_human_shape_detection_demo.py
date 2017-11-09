'''
cylan人形检测范例，详细接口列表请参考http://yf.robotscloud.com/devdocs/OSR.md
by zhongliang
email 8201683@qq.com
'''
from poster.encode import multipart_encode  
from poster.streaminghttp import register_openers  
import time
import urllib2
from hashlib import sha1
import hmac
import base64
from urllib import quote

register_openers()
timestamp = str(int(time.time()))
service_key_secret = "kIbW0CIYlXnPDR7jKE4zqIErsmZKUeoS"
signature = quote(base64.b64encode(hmac.new(service_key_secret, "/hsr/v3/hsr_detection"+"\n"+timestamp, sha1).hexdigest()))
datagen, headers = multipart_encode({"file": open("f:/aa1.jpg", "rb"), 'service_key': 'O86hXeNXTs7ZTSieX0jmA2JbhVNlGpaJ', 'sn': 'xxx',
									'service_code': 'xxx', 'timestamp': timestamp, 'signature': signature})  
request = urllib2.Request("https://apiyf.robotscloud.com/hsr/v3/hsr_detection", datagen, headers)
print urllib2.urlopen(request).read()