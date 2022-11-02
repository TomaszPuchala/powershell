$c = $env:COMPUTERNAME
$software = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$software  += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$software  += Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$software  | ?{ $_.DisplayName -ne $null } | sort-object -Property DisplayName -Unique | Export-Csv -path "C:\temp\Installed_Software_$c.csv" -Encoding UTF8

if (test-path '\\tsclient\f\scripts\inventory\Installed_Software_$c.csv -Encoding UTF8')
{
copy-item -path "C:\temp\Installed_Software_$c.csv" -Destination '\\tsclient\f\scripts\inventory\'  -Force
}
if(test-path "\\tsclient\f\scripts\inventory\Installed_Software_$c.csv")
{
Write-host "Report of softwares installed on $c WAS created" -foregroundcolor green
}
else{
Write-host 	"Report of softwares installed on $c WAS NOT created" -foregroundcolor red
}
