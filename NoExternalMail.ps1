<#
The Purpose of this script is to provide the user with some automation to pull employees by type from Active Directory, sort them by employee type, then add them to an Exchange Online distribution group,
excluding those who are members of a particular Active Directory Security group. This has some prerequisites, listed below. As always, use at your own risk.

Prerequisites:
1. A Distribution group (not Microsoft 365 Group, not a Dynamic Distribution list, not a mail-enabled security group) to use with the no external email transport rule

2. A Transport rule, configured as follows (with your domain appropriate details inserted):
  - Apply this rule if
  -- Is sent to a member of group <yourdistributiongroup@yourdomain.com>
  -- and is received from 'Outside the Organization'
  - Do the following
  -- Delete the message without notifying the recipient or sender
  -- And Stop processing more rules
  - Except If
  -- Senders address domain portion belongs to any of these domains: '<authorized@externalsender.com>'

3. A registered application, with the correct Exchange Online permissions delegated to it and a self-signed certificate or secret. This example uses a certificate, rather than a secret.

#>
# Query Active Directory and gather external email blocking members into an array
$groupA = Get-ADUser -SearchBase "OU=Some,OU=Org,DC=your,DC=domain" -Filter {Enabled -eq $true} -Properties name,userprincipalname,employeetype,title,division | Select-Object name,userprincipalname,employeetype,title,division `
| Where {$_.employeetype -like "*Thing1*" -or $_.employeetype -like "*Thing2*"} | Sort-Object -Property name -Descending:$false

# Define Exceptions in an new array
$badlist = Get-ADGroupMember -Identity "Your_Security_Group_Name" | Select name

# Create new array to place final list of additions to be added to the distribution group
$nomail = @()

# Loop to sort between the addition array and the exceptions array, adding each correct member to the empty 'nomail' array created above
ForEach($g in $groupA){if($badlist.name -notcontains $g.name){$nomail += $g}}

#------Connect to Exchange Online using Secure Certificate------

Connect-ExchangeOnline -AppId <The app ID of your Registerd App> -CertificateThumbprint <The thumbprint of your certificate> -Organization "yourorganization.onmicrosoft.com"
$ErrorActionPreference = 'SilentlyContinue'

# Loop to add each member object of the finalized 'nomail' array to the distribution group that the transport rule is configured to use
$nomail | ForEach-Object{
	
	$group = "noexternalmail@yourdomain.com"
	$usr = $_.UserPrincipalName
	Add-DistributionGroupMember -Identity $group -Member $usr -Confirm:$false
	
}

#Remove-PSSession outlook.office365.com
Disconnect-ExchangeOnline -Confirm:$false
