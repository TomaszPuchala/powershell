 Import-module ActiveDirectory
     $user = Read-Host "Enter username"
     If(Get-ADUser -Filter "SamAccountName -eq '$user'")
     {
      Unlock-ADAccount -Identity $user
     $Password = Read-Host "Enter new password for user "$user"" 
     $Pass = ConvertTo-SecureString $Password -AsPlainText -Force
     Set-ADAccountPassword $user -NewPassword $Pass -Reset
     #Force a password change
     Set-ADUser -Identity $user -ChangePasswordAtLogon $true
     Write-Host $user, $Password
     }
     else
     {
     "Username $user doesn't exist"
     }