/*
读取纯英文文本，每个单词到http://www.dict.cn/去翻译一下，支持过滤太简单的单词
by zhongliang
email 8201683@qq.com
*/
package main

import (
	"bufio"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

//不需要翻译的
var recg = []string{"a", "an", "the", "to", "in", "by", "and", "that", "was", "were", "able", "of", "this", "hide",
	"from", "i", "he", "me", "she", "her", "his", "animal", "room", "zoo", "help"}

func httpGet(url string) string {
	fmt.Println(url)
	resp, err := http.Get(url)
	if err != nil {
		fmt.Println(err.Error())
		return ""
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println(err.Error())
		return ""
	}

	return string(body)
}

func Handler(line string) string {
	words := strings.Fields(line)
	var output string
	for _, v := range words {
		v = strings.Trim(v, "“”’.,\"") //删除单词里的一些杂乱字符
		find := false
		for _, u := range recg {
			if strings.ToLower(v) == u {
				find = true
				break
			}
		}
		if find {
			continue
		}

		doc, err := goquery.NewDocument(fmt.Sprintf("http://www.dict.cn/%s", v))
		if err != nil {
			fmt.Println(err.Error())
		}
		output_line := v

		symbol := doc.Find(".phonetic span bdo").Text()
		output_line = fmt.Sprintf("%-15s %s", output_line, symbol) //15个字符左对齐
		doc.Find(".main .dict-basic-ul li").Each(func(i int, s *goquery.Selection) {
			_, b := s.Attr("style")
			if !b {
				span := s.Find("span")
				strong := s.Find("strong")
				output_line = fmt.Sprintf("%s %s %s", output_line, span.Text(), strong.Text())
			}
		})
		if output == "" {
			output = fmt.Sprintf("%s", output_line)
		} else {
			output = fmt.Sprintf("%s\n%s", output, output_line)
		}
	}
	return output
}

func ReadLine(fileName string, handler func(string) string) error {
	f, err := os.Open(fileName)
	if err != nil {
		return err
	}
	buf := bufio.NewReader(f)

	output_byte := make([]byte, 2000000)
	n, _ := buf.Read(output_byte)
	output := (string)(output_byte[:n])
	output = output + "\n"
	f.Close() //第一遍把所有内容读出来

	f, err = os.Open(fileName)
	if err != nil {
		return err
	}
	buf = bufio.NewReader(f)
	for { //第二遍一行一行读出来
		line, err := buf.ReadString('\n')
		line = strings.TrimSpace(line)
		output_line := handler(line)
		//fmt.Println(output_line)
		if output == "" {
			output = fmt.Sprintf("%s", output_line)
		} else {
			output = fmt.Sprintf("%s\n%s", output, output_line)
		}

		if err != nil {
			if err == io.EOF {
				break
			}
			return err
		}
	}
	f.Close()

	var filename = "output_" + fileName
	var fo *os.File
	if checkFileIsExist(filename) {
		fo, _ = os.OpenFile(filename, os.O_CREATE, 0666)
	} else {
		fo, _ = os.Create(filename)
	}
	fmt.Println(output)
	io.WriteString(fo, output)
	fo.Close()

	return nil
}

func checkFileIsExist(filename string) bool {
	var exist = true
	if _, err := os.Stat(filename); os.IsNotExist(err) {
		exist = false
	}
	return exist
}

func main() {
	arg_num := len(os.Args)
	if arg_num < 2 {
		fmt.Println("请输入要解析的文件")
		return
	}

	ReadLine(os.Args[1], Handler)
}
