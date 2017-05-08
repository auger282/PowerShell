<#
.Synopsis
   Monitor Active Directory Users and Email Password Expiring Soon Notifications
.DESCRIPTION
   This script will get a list of all users who are enabled, mail enabled, not expired,
   not set for PasswordNeverExpires calculate how many days left until their password expires
   and send an email for 10,5,1 days left till their password expires.

   It also generates an admin report that is sent to $reportDistribution

   NOTE: PowerShell ActiveDirectory Module must be installed on the server running this script

   This script does not monitor fine grained password policies and retreives the MaxPasswordAge
   from "(Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge"

.NOTES
   Author : Auger282
   GitHub : https://github.com/auger282/
   Version: .5
   Date   : 5/8/17
   Changed: Cleaned for uploading
#>

import-module activedirectory

#############################################################################
#### Set Variables
####
#############################################################################

# Search base for get-aduser cmdlet - Must be in DistinguishedName format
$searchBase = "" # eg. "DC=domain,DC=com"

# Setup Email Settings for send-mailmessage
$smtpServer = "" # eg. "mailrelay.domain.com"
$from = "" # eg. "Password Administrator <Password.Administrator@DOMAIN.com>"
$reportDistribution = "" # What email addresses or DL should receive the report?

# Setup File Report path
$file = "c:\scripts\PasswordExpiringSoon_Report.txt"

# If the Output File Already Exists - Delete It
# Only the last report is stored in the file location
If (Test-Path $file){Remove-Item $file}

#############################################################################
#### Main
####
#############################################################################

# Get array of all enabled users within $searchBase
$users = get-aduser -SearchBase $searchBase -filter {(Enabled -eq $true)} -properties Name, `
  PasswordNeverExpires,PasswordExpired,PasswordLastSet,EmailAddress | where {$_.PasswordNeverExpires -eq $false} `
  | where {$_.passwordexpired -eq $false} | where {$_.emailaddress -ne $null}

# Store the MaxPasswordAge from the Default Domain Policy
$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

$count = @()

foreach($user in  $users){
  $userObject = Get-ADUser $user -properties passwordlastset
  $Name = (Get-ADUser $user | foreach { $_.givenname}) # Store first name for use in email body
  $emailAddress = $user.emailaddress
  $passwordSetDate = $userObject.passwordlastset
  
  # Calculate how many days till password expires for this specific user (rounded to days)
  $expiresOn = $passwordSetDate + $maxPasswordAge
  $today = (get-date)
  $daystoExpire = (New-TimeSpan -Start $today -End $expiresOn).Days
  
  # Build Email - Configure Subject and use HTML to format body for email notification
  $subject="Your login password will expire in $daystoExpire days"
  $body ="<font face=$([char]34)calibri$([char]34)>
  <p>Dear $name,</p>
  <p></p>
  <p>Please be advised that your login password will expire in $daystoExpire days.</p>
  <p>Thank You.</p></font>"

  #Send normal priority email to users with 10,5 days to go
  if (($daystoExpire -eq "10") -or ($daystoExpire -eq "5")){
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailAddress -subject $subject -body $body -bodyasHTML
    add-content $file ($emailAddress + " " + $daystoExpire.ToString())
    $count += $user
  }
  
  #Send high priority email to users with 1 days to go
  elseif ($daystoExpire -eq "1"){
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailAddress -subject $subject -body $body -bodyasHTML -priority High
    add-content $file ($emailAddress + " " + $daystoExpire.ToString())
    $count += $user
  }
}

#Finish File Report with total count
Add-Content $file ("Total Emails Sent: " + $count.count)
#Send Email Report to $reportDistribution users
Send-Mailmessage -smtpServer $smtpServer -from $from -to $reportDistribution -subject "Password Administrator Report" `
  -body ("Total Emails Sent: " + $count.count) -bodyasHTML -Attachments $file