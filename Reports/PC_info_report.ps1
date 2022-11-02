#Variables which are necessary to check logged user
$quserResult = quser
$quserRegex = $quserResult | ForEach-Object -Process { $_ -replace '\s{2,}',',' }
$quserObject = $quserRegex | ConvertFrom-Csv
$userSession = $quserObject | Where-Object -FilterScript { $_.STATE -eq 'Active' }

Write-Host "Generating raport" -ForegroundColor Blue
$computer = $env:computername
$Date = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
$Username = $userSession.USERNAME
$OS = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Caption
$OSBuild = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber
$InterfaceName = Get-NetAdapter | where status -eq 'up' | Select-Object -ExpandProperty InterfaceDescription
$IP = (Get-CimInstance -computername $computer -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'").IPAddress[0]
$IntefaceMAC =  Get-NetAdapter | where status -eq 'up' | Select-Object -ExpandProperty MacAddress 
$Serialnumber = Get-CimInstance -ClassName Win32_BIOS | Select-Object -ExpandProperty SerialNumber
$Model = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model
$CPU = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty Name
$Motherboard = Get-CimInstance win32_baseboard | Select-Object -ExpandProperty Product
$RAM = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | ForEach-Object { [math]::Round(($_.sum / 1GB),2) }
$Drive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$env:systemdrive'" | ForEach-Object { [math]::Round($_.Size / 1GB,2) }

Write-Host "Date:"  -f green -nonewline; Write-Host "$Date";
Write-Host "Computer:"  -f green -nonewline; Write-Host "$computer";
Write-Host "IP:"  -f green -nonewline; Write-Host "$IP";
Write-Host "User:"  -f green -nonewline; Write-Host "$Username";
Write-Host "Processor:"  -f green -nonewline; Write-Host "$CPU";
Write-Host "Motherboard:"  -f green -nonewline; Write-Host "$Motherboard";
Write-Host "Network card:"  -f green -nonewline; Write-Host "$InterfaceName";
Write-Host "MAC Address:"  -f green -nonewline; Write-Host "$IntefaceMAC";
Write-Host "System:"  -f green -nonewline; Write-Host "$OS";
Write-Host "System's version:"  -f green -nonewline; Write-Host "$OSBuild";
Write-Host "Model:"  -f green -nonewline; Write-Host "$Model";
Write-Host "Serial number:"  -f green -nonewline; Write-Host "$Serialnumber";
Write-Host "Drive (GB):"  -f green -nonewline; Write-Host "$Drive";
Write-Host "RAM (GB):"  -f green -nonewline; Write-Host "$RAM";

[pscustomobject]@{
        Data  = $DData
		Computer = $computer
		IP = $IP
		User = $Username
		Processor = $CPU
		Motherboard = $Motherboard
		System = $OS
		System_version =$OSBuild
		Network_card = "$InterfaceName"
		MAC = "$IntefaceMAC"
		Model = $Model
		Serial_number = $Serialnumber
		Drive_GB = $Drive
		RAM_GB= $RAM
    }|export-csv  "c:\temp\parametry_$computer.csv" -NoTypeInformation -Append -Encoding UTF8
	Write-Host "Raport was created!" -ForegroundColor Blue
