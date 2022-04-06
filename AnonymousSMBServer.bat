@echo off
if %1 == enable (
	echo [+] enable anonymous smb server...
	if not exist %2 (
		md %2
	)
	icacls %2 /T /grant Everyone:r
	net share smb=%2 /grant:everyone,full
	net user guest /active:yes
	REG ADD "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v NullSessionShares /t REG_MULTI_SZ /d smb /f
	REG ADD "HKLM\System\CurrentControlSet\Control\Lsa" /v EveryoneIncludesAnonymous /t REG_DWORD /d 1 /f
	secedit /export /cfg gp.inf /quiet
	powershell.exe "(Get-Content gp.inf) -replace 'SeDenyNetworkLogonRight = Guest','SeDenyNetworkLogonRight = ' | Set-Content "gp.inf""
	secedit /configure /db gp.sdb /cfg gp.inf /quiet
	gpupdate/force
	del gp.inf
	del gp.sdb
	del gp.jfm
	echo [+] enable successfully!
) else if %1 == disable (
	echo [+] disable anonymous smb server...
	icacls %2 /remove Everyone
	net share %2 /del /y
	net user guest /active:no
	REG DELETE "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v NullSessionShares /f
	REG ADD "HKLM\System\CurrentControlSet\Control\Lsa" /v EveryoneIncludesAnonymous /t REG_DWORD /d 0 /f
	secedit /export /cfg gp.inf /quiet
	powershell.exe "(Get-Content gp.inf) -replace 'SeDenyInteractiveLogonRight = Guest','SeDenyNetworkLogonRight = Guest`r`nSeDenyInteractiveLogonRight = Guest' | Set-Content "gp.inf""
	secedit /configure /db gp.sdb /cfg gp.inf /quiet
	gpupdate/force
	del gp.inf
	del gp.sdb
	del gp.jfm
	echo [+] disable successfully!
)