/*
cylan人形检测范例，详细接口列表请参考http://yf.robotscloud.com/devdocs/OSR.md
by zhongliang
email 8201683@qq.com
*/
package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"mime/multipart"
	"net/http"
	"net/url"
	"encoding/base64"
	"strconv"
	"time"
	"crypto/hmac"
	"crypto/sha1"
)

func main() {
	var buff bytes.Buffer
	writer := multipart.NewWriter(&buff)
	writer.WriteField("service_key", "O86hXeNXTs7ZTSieX0jmA2JbhVNlGpaJ")
	writer.WriteField("sn", "xxx")
	writer.WriteField("service_code", "xxx")
	timestamp := strconv.FormatInt(time.Now().Unix(),10)
	writer.WriteField("timestamp", timestamp)
	service_key_secret := "kIbW0CIYlXnPDR7jKE4zqIErsmZKUeoS"
	mac := hmac.New(sha1.New, []byte(service_key_secret))
	mac.Write([]byte("/hsr/v3/hsr_detection"+"\n"+timestamp))
	hmac := fmt.Sprintf("%x", mac.Sum(nil))
	base64url := base64.StdEncoding.EncodeToString([]byte(hmac))
	signature := url.QueryEscape(base64url)
	writer.WriteField("signature", signature)

	w, _ := writer.CreateFormFile("file", "1r.jpg")
	dat, err := ioutil.ReadFile("f:/aa1.jpg")
	w.Write(dat)
	writer.Close()
	var client http.Client
	resp, err := client.Post("https://apiyf.robotscloud.com/hsr/v3/hsr_detection", writer.FormDataContentType(), &buff)
	if err != nil {
	fmt.Println(err)
	return
	}
	defer resp.Body.Close()
	data, _ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(data))
}