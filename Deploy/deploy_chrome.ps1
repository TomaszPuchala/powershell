#FUNCTION TO CREATE LOG
function Write-log {
   
   [CmdletBinding()]
    Param(
          [parameter(Mandatory=$true)]
          [String]$Message,

          [parameter(Mandatory=$false)]
          [String]$Component,

          [Parameter(Mandatory=$true)]
          [ValidateSet("Info", "Warning", "Error")]
          [String]$Type
    )

    #LOG FILE PATH
    $Logfile = "$env:windir\temp\Chrome\Install_chromex64.log"
    #MAPPING TYPE ON NUMBER
    switch ($Type) {
        "Info" { [int]$Type = 1 }
        "Warning" { [int]$Type = 2 }
        "Error" { [int]$Type = 3 }
    }

    #CREATE LOG ENTRY
    $Content = "<![LOG[$Messagetolog]LOG]!>" +`
        "<time=`"$(Get-Date -Format "HH:mm:ss.ffffff")`" " +`
        "date=`"$(Get-Date -Format "M-d-yyyy")`" " +`
        "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
        "type=`"$Type`" " +`
        "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " +`
        #"file=`"`
        ">"

    #LOG OUTPUT
    If ($Logfile) {
        Add-Content $Logfile -Value $Content
    }
    Else {
        Write-Output $Content
        }
}

#FUNCTION TO INSTALL
function InstallApp {

    #INSTALATOR NAME
    $Installfile = "GoogleChromeStandaloneEnterprise64.msi"

    #INSTALLER TEST EXISTENCE AND START INSTALLATION
    If (Test-Path -Path ("$PSScriptRoot\$Installfile") -PathType Leaf) {
        Write-Log -Type "Info" -Message "Find installation file"
        Start-Process -FilePath ("$PSScriptRoot\$Installfile") -Wait -ArgumentList '/quiet'
        Write-Log -Type "Info"-Message "Starting installation"
    }
    else {
        Write-Log -Type "Error" -Message "Installation file not found"
    }
    #CHECK AFTER INSTALLATION
    $afterinstall=(Get-childItem -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall) | Get-ItemProperty | Where-Object { $_.displayname -eq "$programtoinstallname" }
    if ($afterinstall.DisplayName -eq "$programtoinstallname") {
    Write-Log -Type "Info"-Message "Installation copleted"}
    else {
        Write-Log -Type "Error"-Message "Installation failed"
        }
}

#FUNCTION TO UNINSTALL
function UninstallApp {

    #UNINSTALL
    #zmienić Win32_product
    Write-Log -Type "Info" -Message "Deinstaluje"
    $MyApp = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$programtoinstallname*" }
    $MyApp.Uninstall()

    $afterdeinstall=(Get-childItem -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall) | Get-ItemProperty | Where-Object { $_.displayname -eq "$programtoinstallname" }
    if ($afterdeinstall) {
    Write-Log -Type "Error"-Message "Uninstallation failed"}
    else {
        Write-Log -Type "Info"-Message "Uninstallation completed"
        }
}


#MAIN
Write-Log -Type "Info" -Message 'START'
#TARGET
$programtoinstallname = "Google Chrome"
[version]$programtoinstallversion = "97.0.4692.71"

#CHECK EXISTANCE VERSION
$program = (Get-childItem -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall) | Get-ItemProperty | Where-Object { $_.displayname -eq "$programtoinstallname" }
if ($program.DisplayName -eq "$programtoinstallname") {
    Write-Log -Type "Info" -Message "$($program.Displayname) $($program.DisplayVersion) is already installed"
    $programpath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe").Path
    
    #CONVERT TO VERSION TYPE
    [version]$programversion = $program.DisplayVersion

    #NEW VERSION CHECK
    if ($programtoinstallversion -gt $programversion) 
    {
        Write-Log -Type "Warning" -Message "Software version is newer"
        UninstallApp
        InstallApp
    }
    if ($programtoinstallversion -eq $programversion) 
    {
        Write-Log -Type "Info" -Message "Software version is correct"

        #CHECK RIGHT DIRECTORY
        if ([Environment]::Is64BitOperatingSystem -eq $true -AND $programpath -eq "C:\Program Files (x86)\Google\Chrome\Application" ) {
            Write-Log -Type "Warning" -Message "Software was installed on bad registry path"
            Write-Log -Type "Warning" -Message "$programpath"
            UninstallApp
            InstallApp
        }
    }
    else
    {
        Write-Log -Type "Info" -Message "Software version is newer"
    }
}

else {
    Write-Log -Type "Warning" -Message "Software doesn't exist"
    InstallApp
}
Write-Log -Type "Info" -Message 'END'