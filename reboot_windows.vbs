Set colOperatingSystems = GetObject("winmgmts:{(Shutdown)}").ExecQuery("Select * from Win32_OperatingSystem")
Function Shutdown()
    For Each objOperatingSystem in colOperatingSystems
        ObjOperatingSystem.Win32Shutdown(6)'0ע����4ǿ��ע����1�ر�ϵͳ��5��ǿ�ƹر�ϵͳ��2������6ǿ��������8�رյ�Դ��12ǿ�ƹرյ�Դ
    Next
End function

Do While 1
    '�������޸�����Ҫ�ػ���ʱ��
    If "2010-8-26 18:06:00" < Now() then
        Shutdown()
    End If
	Wscript.Sleep(1000)
Loop