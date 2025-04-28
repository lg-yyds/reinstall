@echo off
mode con cp select=437 >nul

rem Windows Deferder 会误报，因此要添加白名单
powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath '%SystemDrive%\frpc\frpc.exe'"

rem ---------- DEBUG ----------
rem 检查服务状态
rem sc query Schedule >%SystemDrive%\x.txt 2>&1

rem 启用日志
rem wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true
rem ---------- DEBUG ----------

rem 创建计划任务并立即运行
schtasks /Create /TN "frpc" /XML "%SystemDrive%\frpc\frpc.xml"
schtasks /Run /TN "frpc"
del "%SystemDrive%\frpc\frpc.xml"

rem win11 在首次登录后计划任务才有效
rem 即使手动重启，计划任务也没有运行
rem 因此如果连续 10 秒都没找到 frpc 进程，则运行 frpc-workaround.bat
for /L %%i in (1,1,10) do (
    timeout 1
    tasklist /FI "IMAGENAME eq frpc.exe" | find /I "frpc.exe" && goto :end
)

rem 后台运行 frpc-workaround.bat
rem 需要加 cmd /c，不然 frpc-workaround.bat 结束后有 cmd 窗口残留
start cmd /c "%SystemDrive%\frpc\frpc-workaround.bat"

:end
rem 删除此脚本
del "%~f0"
