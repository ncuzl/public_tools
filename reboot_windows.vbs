Set colOperatingSystems = GetObject("winmgmts:{(Shutdown)}").ExecQuery("Select * from Win32_OperatingSystem")
Function Shutdown()
    For Each objOperatingSystem in colOperatingSystems
        ObjOperatingSystem.Win32Shutdown(6)'0注销，4强制注销，1关闭系统，5，强制关闭系统，2重启，6强制重启，8关闭电源，12强制关闭电源
    Next
End function

Do While 1
    '在这里修改你需要关机的时间
    If "2010-8-26 18:06:00" < Now() then
        Shutdown()
    End If
	Wscript.Sleep(1000)
Loop