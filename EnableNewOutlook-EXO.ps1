[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
#------Connect to Exchange Online using Secure Certificate------

Connect-ExchangeOnline -AppId <your app id> -CertificateThumbprint <your cert thumbprint> -Organization "<yourdomain>.onmicrosoft.com"
$ErrorActionPreference = 'SilentlyContinue'

$pests = Get-Mailbox -ResultSize Unlimited | Select UserPrincipalName

ForEach($pest in $pests){

Set-CasMailbox -Identity $pest -OneWinNativeOutlookEnabled $true

}

Disconnect-ExchangeOnline -Confirm:$false
