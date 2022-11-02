$computer = $env:computername
Write-Host "Generating a report of installed drivers on $computer" -ForegroundColor Blue
Get-CimInstance Win32_PnPSignedDriver | Where-Object DeviceName | Select-Object DeviceName, Manufacturer, DriverVersion | Sort-Object -Property DeviceName, Manufacturer | export-csv  "c:\temp\drivers_$computer.csv" -NoTypeInformation
Get-Content "c:\temp\drivers_$computer.csv"
Write-Host "Report was created." -ForegroundColor Blue
