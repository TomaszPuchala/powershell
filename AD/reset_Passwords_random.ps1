Import-module ActiveDirectory
 $Users = Get-Content $PSScriptRoot\users.txt
 foreach ($User in $Users) {
     #Generate random password
     $Password = -join ((33..126) | Get-Random -Count 15 | ForEach-Object { [char]$_ })
     $Pass = ConvertTo-SecureString $Password -AsPlainText -Force
	 Unlock-ADAccount -Identity $user
     Set-ADAccountPassword $user -NewPassword $Pass -Reset
     #Force a password change after LogOn
     Set-ADUser -Identity $user -ChangePasswordAtLogon $true
     Write-Host $user, $Password
        [pscustomobject]@{
        User     = $user
        Password = $Password
    } | 
    export-csv "passwords_random.csv" -NoTypeInformation -Append
 }