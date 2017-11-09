/*
cylan人形检测范例，详细接口列表请参考http://yf.robotscloud.com/devdocs/OSR.md
by zhongliang
email 8201683@qq.com
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.IO;

namespace ConsoleApp1
{
	public static class FormUpload
	{
		private static readonly Encoding encoding = Encoding.UTF8;
		public static HttpWebResponse MultipartFormDataPost(string postUrl, string userAgent, Dictionary<string, object> postParameters)
		{
			string formDataBoundary = String.Format("----------{0:N}", Guid.NewGuid());
			string contentType = "multipart/form-data; boundary=" + formDataBoundary;

			byte[] formData = GetMultipartFormData(postParameters, formDataBoundary);

			return PostForm(postUrl, userAgent, contentType, formData);
		}
		private static HttpWebResponse PostForm(string postUrl, string userAgent, string contentType, byte[] formData)
		{
			HttpWebRequest request = WebRequest.Create(postUrl) as HttpWebRequest;

			if (request == null)
			{
				throw new NullReferenceException("request is not a http request");
			}

			request.Method = "POST";
			request.ContentType = contentType;
			request.UserAgent = userAgent;
			request.CookieContainer = new CookieContainer();
			request.ContentLength = formData.Length;

			using (Stream requestStream = request.GetRequestStream())
			{
				requestStream.Write(formData, 0, formData.Length);
				requestStream.Close();
			}

			return request.GetResponse() as HttpWebResponse;
		}

		private static byte[] GetMultipartFormData(Dictionary<string, object> postParameters, string boundary)
		{
			Stream formDataStream = new System.IO.MemoryStream();
			bool needsCLRF = false;

			foreach (var param in postParameters)
			{
				if (needsCLRF)
					formDataStream.Write(encoding.GetBytes("\r\n"), 0, encoding.GetByteCount("\r\n"));

				needsCLRF = true;

				if (param.Value is FileParameter)
				{
					FileParameter fileToUpload = (FileParameter)param.Value;

					string header = string.Format("--{0}\r\nContent-Disposition: form-data; name=\"{1}\"; filename=\"{2}\"\r\nContent-Type: {3}\r\n\r\n",
						boundary,
						param.Key,
						fileToUpload.FileName ?? param.Key,
						fileToUpload.ContentType ?? "application/octet-stream");

					formDataStream.Write(encoding.GetBytes(header), 0, encoding.GetByteCount(header));

					formDataStream.Write(fileToUpload.File, 0, fileToUpload.File.Length);
				}
				else
				{
					string postData = string.Format("--{0}\r\nContent-Disposition: form-data; name=\"{1}\"\r\n\r\n{2}",
						boundary,
						param.Key,
						param.Value);
					formDataStream.Write(encoding.GetBytes(postData), 0, encoding.GetByteCount(postData));
				}
			}

			string footer = "\r\n--" + boundary + "--\r\n";
			formDataStream.Write(encoding.GetBytes(footer), 0, encoding.GetByteCount(footer));

			formDataStream.Position = 0;
			byte[] formData = new byte[formDataStream.Length];
			formDataStream.Read(formData, 0, formData.Length);
			formDataStream.Close();

			return formData;
		}

		public class FileParameter
		{
			public byte[] File { get; set; }
			public string FileName { get; set; }
			public string ContentType { get; set; }
			public FileParameter(byte[] file) : this(file, null) { }
			public FileParameter(byte[] file, string filename) : this(file, filename, null) { }
			public FileParameter(byte[] file, string filename, string contenttype)
			{
				File = file;
				FileName = filename;
				ContentType = contenttype;
			}
		}
	}

	class Program
	{
		static string ToHexString(byte[] array)
		{
			StringBuilder hex = new StringBuilder(array.Length * 2);
			foreach (byte b in array)
			{
				hex.AppendFormat("{0:x2}", b);
			}
			return hex.ToString();
		}

		static string HmacSha1Sign(string secret, string strOrgData)
		{
			var hmacsha1 = new HMACSHA1(Encoding.UTF8.GetBytes(secret));
			var dataBuffer = Encoding.UTF8.GetBytes(strOrgData);
			var hashBytes = hmacsha1.ComputeHash(dataBuffer);
			return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(ToHexString(hashBytes)));
		}

		static void Main(string[] args)
		{
			string service_key_secret = "kIbW0CIYlXnPDR7jKE4zqIErsmZKUeoS";
			string filepath = "f:\\1.jpg";
			string service_key = "O86hXeNXTs7ZTSieX0jmA2JbhVNlGpaJ";
			string sn = "xxx";
			string service_code = "xxx";

			System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
			string timeStamp = ((long)(DateTime.Now - startTime).TotalSeconds).ToString();
			string signature = Uri.EscapeDataString(HmacSha1Sign(service_key_secret, "/hsr/v3/hsr_detection" + "\n" + timeStamp));
			string postURL = "https://apiyf.robotscloud.com/hsr/v3/hsr_detection";

			FileStream fs = new FileStream(filepath, FileMode.Open, FileAccess.Read);
			byte[] data = new byte[fs.Length];
			fs.Read(data, 0, data.Length);
			fs.Close();

			Dictionary<string, object> postParameters = new Dictionary<string, object>();

			postParameters.Add("service_key", service_key);
			postParameters.Add("sn", sn);
			postParameters.Add("service_code", service_code);
			postParameters.Add("timestamp", timeStamp);
			postParameters.Add("signature", signature);

			postParameters.Add("filename", "1.jpg");
			postParameters.Add("fileformat", "jpg");
			postParameters.Add("file", new FormUpload.FileParameter(data, "1.jpg", "application/x-jpg"));

			string userAgent = "Someone";
			HttpWebResponse webResponse = FormUpload.MultipartFormDataPost(postURL, userAgent, postParameters);

			StreamReader responseReader = new StreamReader(webResponse.GetResponseStream());
			string fullResponse = responseReader.ReadToEnd();
			webResponse.Close();
			Console.Write(fullResponse);
			System.Threading.Thread.Sleep(-1);
		}
	}
}