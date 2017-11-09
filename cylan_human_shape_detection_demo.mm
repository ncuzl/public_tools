/*
cylan人形检测范例，详细接口列表请参考http://yf.robotscloud.com/devdocs/OSR.md
by zhongliang
email 8201683@qq.com
*/
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@import MobileCoreServices;

- (void)hsr_detec {
	NSString *timestamp = [NSString stringWithFormat: @"%ld", (long)[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue]];
	NSString *service_key_secret=@"kIbW0CIYlXnPDR7jKE4zqIErsmZKUeoS";

	NSString *signature = [self hmacsha1:[NSString stringWithFormat: @"/hsr/v3/hsr_detection\n%@", timestamp] key:service_key_secret];
	NSDictionary *params = @{@"service_key"  : @"O86hXeNXTs7ZTSieX0jmA2JbhVNlGpaJ",
							 @"sn"           : @"xxx",
							 @"service_code" : @"xxx",
							 @"timestamp"    : timestamp,
							 @"signature"    : signature};
	NSString *boundary = [self generateBoundaryString];

	NSString *urlString=@"https://apiyf.robotscloud.com/hsr/v3/hsr_detection";

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];

	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"a" ofType:@"jpg"];
	NSArray *paths = @[filePath];
	NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params paths:paths fieldName:@"file"];
	request.HTTPBody = httpBody;

	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			NSLog(@"error = %@", error);
			return;
		}

		NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"result = %@", result);

	}] resume];
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
						parameters:(NSDictionary *)parameters
							 paths:(NSArray *)paths
						 fieldName:(NSString *)fieldName {
	NSMutableData *httpBody = [NSMutableData data];

	[parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
		[httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
		[httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
	}];

	for (NSString *path in paths) {
		NSString *filename  = [path lastPathComponent];
		NSData   *data      = [NSData dataWithContentsOfFile:path];
		NSString *mimetype  = [self mimeTypeForPath:path];

		[httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
		[httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
		[httpBody appendData:data];
		[httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}

	[httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

	return httpBody;
}


- (NSString *)mimeTypeForPath:(NSString *)path {
	// get a mime type for an extension using MobileCoreServices.framework
	CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
	CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
	assert(UTI != NULL);

	NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
	assert(mimetype != NULL);
	CFRelease(UTI);
	return mimetype;
}

- (NSString *)generateBoundaryString {
	return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (NSString *)base64StringFromText:(NSString *)text {
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64String = [data base64EncodedStringWithOptions:0];
	return base64String;
}

- (NSString *)stringFromBytes:(unsigned char *)bytes length:(int)length
{
	NSMutableString *mutableString = @"".mutableCopy;
	for (int i = 0; i < length; i++)
		[mutableString appendFormat:@"%02x", bytes[i]];
	return [NSString stringWithString:mutableString];
}

- (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret {
	NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
	NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *mutableData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], mutableData.mutableBytes);
	NSString *hmac_str = [self stringFromBytes:(unsigned char *)mutableData.bytes length:(int)mutableData.length];
	NSString *base64EncodedResult = [self base64StringFromText:hmac_str];
	return base64EncodedResult;
}