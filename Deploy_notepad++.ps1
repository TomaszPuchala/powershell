 function Get-Time {
    
    return "[{0:HH:mm:ss} {0:dd/MM/yy}]" -f (Get-Date)
    
}
Write-host "---$(Get-Time)START---"
$computername = Get-Content "$PSScriptRoot\PC.csv"
$installfile = "$PSScriptRoot\npp.8.2.Installer.x64.exe"

foreach ($computer in $computername) 
{
	if (!(Test-Connection -ComputerName $Computer -Count 1 -Quiet))
    {
	Write-host "___ $(Get-Time)Computer Offine:  $computer ___" -ForegroundColor Red
    } 
	else
	{
		Write-host "___ $(Get-Time)Computer Online:  $computer ___" -ForegroundColor Green
   $destinationFolder = "\\$computer\C$\Temp\npp"
   
   if (!(Test-Path -path $destinationFolder))
    {
        New-Item $destinationFolder -Type Directory
    }
	$Logfile = "\\$computer\C$\Windows\temp\Install_notepad++.log"
	Copy-Item -Path $installfile -Destination $destinationFolder
  Invoke-Command -ComputerName $computer -ScriptBlock {
	 
	function Get-Time {
    
		return "[{0:HH:mm:ss} {0:dd/MM/yy}]" -f (Get-Date)
	}
$software = "Notepad++ (64-bit x64)"
$isinstalled = (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where { $_.DisplayName -eq $software }) -ne $null

    if ($isinstalled) {
    Write-host "$(Get-Time) Software $software is already installed on $computer " -ForegroundColor Green
	Remove-Item "c:\temp\npp" -Recurse -Force
	}
    else {
    "$(Get-Time) Software $software IS NOT installed on $computer"

		Write-host "$(Get-Time) Installation file was copied to the $computer"
    	c:\temp\npp\npp.8.2.Installer.x64.exe  /S
		Write-host "$(Get-Time) Starting installation on $computer"
		start-sleep -Seconds 10
		Write-host "$(Get-Time) Installation on PC $computer completed"
		Remove-Item "c:\temp\npp" -Recurse -Force
		$isinstalled = (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where { $_.DisplayName -eq $software }) -ne $null
		if ($isinstalled) {
			Write-host "$(Get-Time) Installation complete" -ForegroundColor Green
	}
	else{
	Write-host "$(Get-Time) Software $software WAS NOT installed" -ForegroundColor Red
	}
  }
}
}
}
Write-host "---$(Get-Time)END---"