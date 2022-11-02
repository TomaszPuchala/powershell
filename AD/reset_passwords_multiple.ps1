Import-module ActiveDirectory
 $Users = Get-Content $PSScriptRoot\users.txt
 foreach ($User in $Users) {
     If(Get-ADUser -Filter "SamAccountName -eq '$user'")
     {
     Unlock-ADAccount –Identity $user
     $Password = Read-Host "Enter new password for user "$user"" 
     $Pass = ConvertTo-SecureString $Password -AsPlainText -For
     Set-ADAccountPassword $user -NewPassword $Pass -Reset
     #Force a password change after LogOn
     Set-ADUser -Identity $user -ChangePasswordAtLogon $true
     Write-Host $user, $Password
             [pscustomobject]@{
        User     = $user
        Password = $Password
    } | 
    export-csv "passwords_multiple.csv" -NoTypeInformation -Append
     }
     else
     {
     "User $user doesn't exist"
     }
     }

