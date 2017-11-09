'设置系统时间
'by zhongliang
'email 8201683@qq.com

On Error Resume Next  '忽略所有的错误.txt

do while 1

Dim i
i=0
Dim httpadd(4)
httpadd(0) = "http://www.baidu.com/"
httpadd(1) = "http://unisearch.sgh.com.cn/"
httpadd(2) = "http://www.soso.com/"
httpadd(3) = "http://17.145.3.21/web/"

ShiJian=""
do while i<=UBound(httpadd)
    Set XmlHttp = CreateObject("Microsoft.XMLHTTP")
    XmlHttp.Open "Get", httpadd(i), False
    XmlHttp.send
    ShiJian = DateAdd("h",8, CDate(mid(XmlHttp.getResponseHeader("Date"),5,21)))
    Set XmlHttp = Nothing
    if ShiJian<>"" then
        i=UBound(httpadd)
    end if
    i=i+1
loop

If shijian="" then
    'MsgBox "网络连接失败"
    'ExitScript
Else          
    'MsgBox "网络时间: "&ShiJian
    set ws=createobject("wscript.shell")
    ws.run "cmd /c date "& Split(ShiJian, " ")(0),vbhide
    ws.run "cmd /c time "& Split(ShiJian, " ")(1),vbhide
    ws.run "taskkill /f /im cmd.exe",vbhide
End If

WScript.Sleep 10000

loop