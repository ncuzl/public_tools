/*
ip归属查询
by zhongliang
email 8201683@qq.com
*/

package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"strings"
	"sync"
	"time"
)

func httpget(ip string, address string) string {
	u, _ := url.Parse(address)
	q := u.Query()
	q.Set("ip", ip)
	u.RawQuery = q.Encode()
	res, err := http.Get(u.String())
	if err != nil {
		return ""
	}
	result, err := ioutil.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		return ""
	}
	//fmt.Printf("%s", result)
	return string(result)
}

func WriteFile(path string, str string) {
	os.Remove(path)
	var b = []byte(str)
	err := ioutil.WriteFile(path, b, 0666)
	if err != nil {
		fmt.Println(err.Error())
	}
}

func GetIpInfofromServers(b *bytes.Buffer, ch chan int, w *sync.WaitGroup, ip string) (ret string) {
	<-ch
	//get ip from cylan
	msg := httpget(strings.Replace(ip, "\r", "", -1), "http://yf.robotscloud.com/get_ip")

	//fmt.Println("get msg from cylan:" + msg)
	if msg == "" {
		ret = ""
		w.Done()
		return
	}

	r := []byte(msg)
	var j map[string]interface{}
	if err := json.Unmarshal(r, &j); err == nil {
		code := int((j["code"]).(float64))
		if code == 0 {
			var data map[string]interface{}
			data = (j["data"]).(map[string]interface{})
			b.WriteString(fmt.Sprintf("%s,%s,%s", data["ip"], data["country_id"], data["country"]))
			b.WriteString("\n")
			ret = fmt.Sprintf("%s,%s,%s", data["ip"], data["country_id"], data["country"])
			w.Done()
			return
		}
	} else {
		fmt.Println(err.Error())
	}

	//get ip from taobao
	msg = httpget(strings.Replace(ip, "\r", "", -1), "http://ip.taobao.com/service/getIpInfo.php")

	//fmt.Println("get msg from taobao: " + msg)

	r = []byte(msg)
	var k map[string]interface{}
	if err := json.Unmarshal(r, &k); err == nil {
		var data map[string]interface{}
		data = (k["data"]).(map[string]interface{})
		ret = fmt.Sprintf("%s,%s,%s", data["ip"], data["country_id"], data["country"])
		w.Done()
		return
	} else {
		fmt.Println(err.Error())
	}

	ret = ""
	w.Done()
	return
}

func main() {
	//var ip_country_map map[string]string
	f, err := os.Open("ip.txt")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	var output string
	b := bytes.Buffer{}

	rd := bufio.NewReader(f)
	ch := make(chan int, 1000)
	var w sync.WaitGroup
	for {
		line, err := rd.ReadString('\n')
		//fmt.Println("read from file: " + line)
		if err != nil || io.EOF == err {
			//fmt.Println("end of ip file")
			break
		}
		if len(strings.Split(line, ".")) < 4 {
			//fmt.Println("not ip")
			continue
		}
		
		go GetIpInfofromServers(&b, ch, &w, line)
		ch <- 0
		w.Add(1)
	}

	w.Wait()
	time.Sleep(time.Millisecond*30)
	output = b.String()
	WriteFile("./output.csv", output)
}
