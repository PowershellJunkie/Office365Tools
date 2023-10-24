<# 
The purpose of this simple script is to assist with Licensing cutovers.

This script assumes the following:
1. That you are syncing on-prem Active Directory to Azure AD (Microsoft 'Entra', at time of writing)
2. That you are syncing Security Groups to Azure AD
3. That you are assigning Office 365 licenses via synced Security groups
4. That you've already created the requisite group(s), synced them and assigned the appropriate license(s)

Note: Looney Tunes are funny, which is why several variables are named after them. If you don't like it, feel free to rewrite it. You break it, you bought it
#>
#-- The 'daffyduck' variable is the old group, the one we don't want people in --#
$daffyduck = "<Old License Group Name>"

#-- This variable is the new group we do want people in --#
$elmerfudd = "<New License Group Name>"

#-- The loop that does the work; Add to the new, remove from the old --#
ForEach($member in $daffyduck){

Add-ADGroupMember -Identity $elmerfudd -Members $member -Confirm:$false
Remove-ADGroupMember -Identity $daffyduck -Members $member -Confirm:$false

}
