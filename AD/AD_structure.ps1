Import-Module ActiveDirectory
 
#Create a main OU
$DomainName = "DC=TPUCHALA,DC=LOCAL"
$OU = "OU=Pracownicy"
$OUstring = $OU + "," + $DomainName
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OUstring'") {
    Write-Host "OU $OUstring already exists."
  } else {
    New-ADOrganizationalUnit -Name $OU -Path $DomainName
  }
 
 
#Create an OUs
$OUs = @("Zarząd","IT","Kadry","Księgowość","Sprzedaż")

foreach ($OUcreate in $OUs) {
    $fullOUstring = "OU=" + $OUCreate + "," + $OUstring
    Write-Output $fullOUstring
    if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$fullOUstring'") {
        Write-Host "OU $OUcreate already exists."
      } else {
        New-ADOrganizationalUnit -Name $OUcreate -Path $OUstring
      }
}
 
#Read users from csv file
$UsersAD = Import-csv -Delimiter ";" -Path ADUsers.csv
 
foreach ($User in $UsersAD)
{
	$Username 	= $User.Username
	$Password 	= $User.Password
	$Firstname 	= $User.First
	$Lastname 	= $User.Last
    $EmailAddress = $User.EmailAddress
    $streetaddress = $User.StreetAddress
    $state      = $User.State
    $city       = $User.City
    $zipcode    = $User.Zipcode
    $telephone  = $User.Telephone
    $jobtitle   = $User.JobTitle
    $company    = $User.Company
    $department = $User.Department
    $country    = $User.Country
    $OU 		= $User.ou
 
	#Checking user already exist 
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #Write warning,if user exists
		 Write-Warning "User $Username already exists."
	}
	else
	{
		#Create AD users in specific OU
		New-ADUser `
                -SamAccountName "$Username" `
                -UserPrincipalName "$Username@tpuchala.local" `
                -Name "$Firstname $Lastname" `
                -GivenName "$Firstname" `
	            -Surname "$Lastname" `
	            -DisplayName "$Firstname $Lastname" `
	            -Path "$OU" `
	            -City "$city" `
                -Title "$jobtitle" `
	            -Department "$department" `
	            -Company "$company" `
	            -State "$state" `
	            -StreetAddress "$streetaddress" `
	            -PostalCode "$zipcode" `
	            -OfficePhone "$telephone" `
	            -EmailAddress "$EmailAddress" `
                -Country "$country"`
                -Enabled $True `
                -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -ChangePasswordAtLogon $True -CannotChangePassword $False

                  Write-Host "ADAccound $username was created." -ForegroundColor Green
	}
}