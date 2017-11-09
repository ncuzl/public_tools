/*
cylan人形检测范例，详细接口列表请参考http://yf.robotscloud.com/devdocs/OSR.md
by zhongliang
email 8201683@qq.com
*/
package javaapplication1;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import javax.activation.MimetypesFileTypeMap;
import java.sql.Timestamp;
import javax.crypto.Mac;  
import javax.crypto.SecretKey;  
import javax.crypto.spec.SecretKeySpec;  
import java.security.InvalidKeyException;  
import java.security.NoSuchAlgorithmException;  
import java.util.Formatter; 

public class JavaApplication1 {

	public static void main(String[] args) {
		String url = "https://apiyf.robotscloud.com/hsr/v3/hsr_detection";
		String fileName = "c:\\a.jpg";
		String service_key_secret = "kIbW0CIYlXnPDR7jKE4zqIErsmZKUeoS";
		Timestamp time1 = new Timestamp(System.currentTimeMillis()); 
		String timestamp = Long.toString((time1.getTime()/1000));

		String base64str = encode((hamcsha1( ("/hsr/v3/hsr_detection"+"\n"+timestamp).getBytes(), service_key_secret.getBytes()).getBytes()));
		String signature = java.net.URLEncoder.encode(base64str);
		Map<String, String> textMap = new HashMap<String, String>();
		textMap.put("service_key", "O86hXeNXTs7ZTSieX0jmA2JbhVNlGpaJ");
		textMap.put("sn", "xxx");
		textMap.put("service_code", "xxx");
		textMap.put("timestamp", timestamp);
		textMap.put("signature", signature);

		Map<String, String> fileMap = new HashMap<String, String>();
		fileMap.put("file", fileName);
		String contentType = "";//image/png
		String ret = formUpload(url, textMap, fileMap,contentType);
		System.out.println(ret);
	}

	public static String encode(byte[] bstr){    
	   return new sun.misc.BASE64Encoder().encode(bstr);    
	}

	private static final String MAC_NAME = "HmacSHA1";    
	private static final String ENCODING = "UTF-8";  
	public static String hamcsha1(byte[] data, byte[] key) 
	{
		  try {
			  SecretKeySpec signingKey = new SecretKeySpec(key, "HmacSHA1");
			  Mac mac = Mac.getInstance("HmacSHA1");
			  mac.init(signingKey);
			  return toHexString(mac.doFinal(data));
		  } catch (NoSuchAlgorithmException e) {
			   e.printStackTrace();
		  } catch (InvalidKeyException e) {
			   e.printStackTrace();
		  }
		 return null;
	 }

	public static String toHexString(byte[] bytes) {        
		 Formatter formatter = new Formatter();             
		 for (byte b : bytes) {         
			 formatter.format("%02x", b);
		 }
		 return formatter.toString();   
	}  

	@SuppressWarnings("rawtypes")
	public static String formUpload(String urlStr, Map<String, String> textMap,
		Map<String, String> fileMap,String contentType) {
		String res = "";
		HttpURLConnection conn = null;
		String BOUNDARY = "---------------------------123821742118716"; 
		try {
			URL url = new URL(urlStr);
			conn = (HttpURLConnection) url.openConnection();
			conn.setConnectTimeout(5000);
			conn.setReadTimeout(30000);
			conn.setDoOutput(true);
			conn.setDoInput(true);
			conn.setUseCaches(false);
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Connection", "Keep-Alive");
			conn.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-CN; rv:1.9.2.6)");
			conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + BOUNDARY);
			OutputStream out = new DataOutputStream(conn.getOutputStream());
			if (textMap != null) {
				StringBuffer strBuf = new StringBuffer();
				Iterator iter = textMap.entrySet().iterator();
				while (iter.hasNext()) {
					Map.Entry entry = (Map.Entry) iter.next();
					String inputName = (String) entry.getKey();
					String inputValue = (String) entry.getValue();
					if (inputValue == null) {
						continue;
					}
					strBuf.append("\r\n").append("--").append(BOUNDARY).append("\r\n");
					strBuf.append("Content-Disposition: form-data; name=\"" + inputName + "\"\r\n\r\n");
					strBuf.append(inputValue);
				}
				out.write(strBuf.toString().getBytes());
			}

			if (fileMap != null) {
				Iterator iter = fileMap.entrySet().iterator();
				while (iter.hasNext()) {
					Map.Entry entry = (Map.Entry) iter.next();
					String inputName = (String) entry.getKey();
					String inputValue = (String) entry.getValue();
					if (inputValue == null) {
						continue;
					}
					File file = new File(inputValue);
					String filename = file.getName();
					contentType = new MimetypesFileTypeMap().getContentType(file);
					if(!"".equals(contentType)){
						if (filename.endsWith(".png")) {
							contentType = "image/png"; 
						}else if (filename.endsWith(".jpg") || filename.endsWith(".jpeg") || filename.endsWith(".jpe")) {
							contentType = "image/jpeg";
						}else if (filename.endsWith(".gif")) {
							contentType = "image/gif";
						}else if (filename.endsWith(".ico")) {
							contentType = "image/image/x-icon";
						}
					}
					if (contentType == null || "".equals(contentType)) {
						contentType = "application/octet-stream";
					}
					StringBuffer strBuf = new StringBuffer();
					strBuf.append("\r\n").append("--").append(BOUNDARY).append("\r\n");
					strBuf.append("Content-Disposition: form-data; name=\"" + inputName + "\"; filename=\"" + filename + "\"\r\n");
					strBuf.append("Content-Type:" + contentType + "\r\n\r\n");
					out.write(strBuf.toString().getBytes());
					DataInputStream in = new DataInputStream(
							new FileInputStream(file));
					int bytes = 0;
					byte[] bufferOut = new byte[1024];
					while ((bytes = in.read(bufferOut)) != -1) {
						out.write(bufferOut, 0, bytes);
					}
					in.close();
				}
			}
			byte[] endData = ("\r\n--" + BOUNDARY + "--\r\n").getBytes();
			out.write(endData);
			out.flush();
			out.close();

			StringBuffer strBuf = new StringBuffer();
			BufferedReader reader = new BufferedReader(new InputStreamReader(
					conn.getInputStream()));
			String line = null;
			while ((line = reader.readLine()) != null) {
				strBuf.append(line).append("\n");
			}
			res = strBuf.toString();
			reader.close();
			reader = null;
		} catch (Exception e) {
			System.out.println("发送POST请求出错。" + urlStr);
			e.printStackTrace();
		} finally {
			if (conn != null) {
				conn.disconnect();
				conn = null;
			}
		}
		return res;
	}
}