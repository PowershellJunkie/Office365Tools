#---Connect to the Security and Compliance Powershell. Connecting unattended requires a more secure setup, which will be convered in another script/documentation---#
Connect-IPPSSession -UserPrincipalName youradmin@yourdomain.com

#---Basic Script to remove an email from all active mailboxes in ExchangeOnline. Before running, you must connect to the compliance powershell---#

$search=New-ComplianceSearch -Name "Remove email" -ExchangeLocation All -ContentMatchQuery '(From:somebody@yourdomain.com) And (Subject:Whatever normal people put in email subjects)'
Start-ComplianceSearch -Identity $search.Identity

#----The following command must be run individually AFTER you have confirmed the search has been completed, either with the 'Get-ComplianceSearch' command or by viewing the portal----#

New-ComplianceSearchAction -SearchName "Remove email" -Purge -PurgeType HardDelete
