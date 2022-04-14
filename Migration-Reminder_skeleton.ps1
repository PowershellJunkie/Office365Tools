# Get the date and set the attachment location (optional) of any documentation sent to end-users
# You can alter or pass and argument to the ~.AddDays(+/- X) to change the countdown to the actual date of migration. Super helpful.
$migdate = (Get-Date).AddDays(+2).ToString("MM-dd-yyyy")
$attach = "\\server\path\to\your\documentation.docx"

# Here is the email notification that will go to each individual user

$htmlbody = @" 
<html> 
<head></head>
<body style="font-family:verdana;font-size:13">
Hello, <br><br>

As part of our ongoing process for improvement and ease of use, <b>your Mailbox will be migrated on the evening of $migdate after 9PM ET.</b> <br>
Your mailbox will continue to receive mail during this time period, however your mailbox will not be available to you until the migration is completed. <br>
Attached, you will find some documentation on how to set up your new email on your phone once the migration of your email has been completed. <br>
Once the migration is completed, if you need to access your email via the web, you will now use the site https://outlook.office.com and login with your full email address and your network (Windows) password. <br>
<br>
<br>
Thank you,<br>
IT Department<br><br>
</body> 
</html> 
"@  

# Array to get our users from the group. This gets them all from the group, regardless of their migration status.
$grpmem = @()
$grpmemdet = Get-ADGroupMember -Identity "<your migration group>" -Recursive | Get-ADUser -Properties sAMAccountName | Select-Object sAMAccountName
$grpmem += $grpmemdet

# Here, we filter the group array and figure out who needs to actually be migrated based on the attribute 'msExchRemoteRecipientType' in AD (which O365 will set to '4' when the mailbox gets migrated)

$migcheck = $grpmem | ForEach-Object{

$user = $_.sAMAccountName

Get-ADUser -Identity $user -Properties mail,msExchRemoteRecipientType,sAMAccountName | Select-Object mail, msExchRemoteRecipientType,sAMAccountName | Where {$_.msExchRemoteRecipientType -eq $null}

}

# Okay, this array might seem silly, since all we're doing is taking the results of our migration check and dumping it to a new array
# But stay with me here: It's actually shorter (in terms of actually writing code) to simply translate it this way versus creating custom powershell objects 
# and then cross translating them. 
# Programmatically, I personally found no difference, but I didn't ever have to process more than about 200 users per shot. Your mileage may vary.

$remarray = @()
$remarraydet = $migcheck
$remarray += $remarraydet 

# Send the actual end user migration emails
$reminder = $migcheck | ForEach-Object{

$mail = $_.mail

Send-MailMessage -From 'youritdepartment@yourdomain.com' -To "$mail" -Subject "IMPORTANT REMINDER! - Office 365 Migration" -BodyAsHtml $htmlbody -Attachments $attach -Priority High -SmtpServer 'your.smtp.server.yourdomain.com'

}

# Use the REMARRAY above to created a tabled report to shoot to our IT department so they'll know who we're migrating.

$output = $remarray | ConvertTo-Html -as Table -Fragment

# Email for the IT department with table. Didn't do table formatting here. Feel free to go nuts with the formatting.

 $htmlbod2 = @"
<html> 
<head></head>
<body style="font-family:verdana;font-size:13">
Hello, <br><br>

The following list of users has been notified of the upcoming migration on $migdate .<br>
<br>

$output

<br>
<br>
Thank you,<br>
IT Department<br><br>
</body> 
</html> 
"@ 

# Send that mail! Make your helpdesk squirm!
Send-MailMessage -From 'service_account@yourdomain.com' -To 'yourITdepartment@yourdomain.com' -Subject "Office 365 Migration Notification" -BodyAsHtml $htmlbod2 -SmtpServer 'your.smtp.server.yourdomain.com'
