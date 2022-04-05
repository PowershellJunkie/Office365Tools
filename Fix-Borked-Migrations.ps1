<#
The purpose of this script is to help automate the fixing of your borked migrations. That said, there are some parts of this that are going to be manual.
Such as the creation of an appropriate Borked.csv
Such as the importing of backup PST's for each borked account back into Exchange.
Automation got you here and automation can help dig you out. But too much of a good thing is a bad thing.
#>

# Get the CSV with borked accounts. Header must be 'User' and you must use the sAMAccountName of the borked accounts
$borked = "\\<your>\<filepath>\Borked.csv"

# Non-Synced OU where the users will go to remove Azure synchronization
$TargetOU = "OU=Your OU,DC=somecompany,DC=com"



# Clear the relevant Active Directory fields
Import-CSV $borked | Foreach-Object{

$user = $_.User

get-aduser $user| set-aduser -clear msExchMailboxGuid,msExchHomeServerName,legacyExchangeDN,mail,mailNickname,msExchMailboxSecurityDescriptor,msExchPoliciesIncluded,msExchRecipientDisplayType,msExchRecipientTypeDetails,msExchUMDtmfMap,msExchUserAccountControl,msExchVersion

$UserDN = (Get-ADUser -Identity $user).distinguishedName
Write-Host "Moving Accounts to Non-Synced OU..."
Move-ADObject -Identity $UserDN -TargetPath $TargetOU

}
Write-Host "Completed Moves. Beginning ADFS Sync."

Sleep (10)

$session = New-PSSession -ComputerName <yourservername>
$script = {Start-ADSyncSyncCycle -PolicyType Delta}
Invoke-Command -Session $session -ScriptBlock $script

Write-Host "Waiting for Sync completion"
Sleep (30)

# This last bit connects to your on-prem Exchange and re-enables the mailbox of the borked user. From here, you can re-attempt the migration or allow them to resume work.
$Credential = Get-Credential -Message "Input your Exchange Admin Creds"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://yourmaildomain.com/PowerShell/" -Authentication Basic -Credential $Credential
Import-PSSession $Session -DisableNameChecking -AllowClobber

Import-CSV $borked | ForEach-Object{

$user = $_.User

Get-User $user | Enable-Mailbox
	
}
