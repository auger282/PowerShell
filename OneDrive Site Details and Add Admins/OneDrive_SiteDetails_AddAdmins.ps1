<#
.Synopsis
   Script to view a user’s OneDrive SPO site details quickly and add/report site admins
.DESCRIPTION
   During the termination process or general OneDrive site administration it may be required 
   to view a user’s OneDrive SPO site details. Using the user’s email address as input this 
   script displays the number of files stored in the OneDrive SPO site, URL and last content 
   modified date. Additionally the script displays a report of the current site admins and 
   gives the ability to add additional admins as needed.

   **Enter your SharePoint Online Service URL at the top of the script.
   **Run this script in PowerShell ISE to run multiple times and not be prompted for your 
   connection credentials each time.
   **Enter your online admin username at the top of the code so you don’t have to type it in 
   every time.

.NOTES
   Author : Auger282
   GitHub : https://github.com/auger282/
   Version: 1
   Date   : 7/6/18
   Changes: Added SPO site error checking
#>

$onlineAdminUsername = "" # username@company.onmicrosoft.com
$spoServiceURL = "" # https://domain-admin.sharepoint.com

if(!$spoServiceURL){
    Write-Host "Please update SharePoint Online Service URL in Script!!!!!" -ForegroundColor Red
    pause
    Exit
    }

if(!$onlineAdmin){$onlineAdmin = Get-Credential -message "Please supply password for Online Admin" -username $onlineAdminUsername}
cls
Write-Host
Write-Host "Connecting to SharePoint Online..."
Write-Host
Import-Module Microsoft.Online.Sharepoint.PowerShell
Connect-SPOService -url $spoServiceURL -Credential $onlineAdmin
Write-Host
Write-Host
$userEmail = read-host -Prompt "Enter the User's email address"
$userConvertedEmail = $userEmail -replace "\.","_"
$userConvertedEmail = $userConvertedEmail -replace "@","_"
$spoUserURL = $spoServiceURL -replace "admin","my"
$userSite = $spoUserURL + "/personal/" + $userConvertedEmail

write-host
$currentErrorCount = $error.count
Get-SPOSite -Identity $userSite | ft title,StorageUsageCurrent,url,LastContentModifiedDate -AutoSize

# Minor error checking if the SPO site can't be found (Typo or bad email address)
if($error.count -gt $currentErrorCount){
    Write-Host "!!!!! OneDrive SPO Site was not found !!!!!" -ForegroundColor Red
    Exit
}

$loopMonitor = Read-Host -Prompt "Would you like to give access to this OneDrive folder?(y/n)"
while($loopMonitor -eq "y"){
    write-host
    $requestorEmail = read-host -Prompt "Enter email for user getting access"
    write-host
    Set-SPOuser -Site $userSite -LoginName $requestorEmail -IsSiteCollectionAdmin:$true
    Write-Host
    get-spouser -site $usersite | ?{$_.issiteadmin -eq $true} | ft loginname,issiteadmin
    Write-Host
    $loopMonitor = Read-Host -Prompt "Would you like to give access to another user?(y/n)"
    if($loopMonitor -eq "y"){Clear-Variable requestorEmail}
}
write-host
write-host
Write-Host "Report of users listed as OneDrive SiteAdmins:" -ForegroundColor Gray
Write-Host " (This does not include the Site Owner)" -ForegroundColor Gray
write-host
$siteAdmins = get-spouser -site $usersite | ?{$_.issiteadmin -eq $true} | ft loginname,issiteadmin
if(!$siteAdmins){Write-Host " No Additional Site Admins found" -ForegroundColor Gray}
else{Write-Host ($siteAdmins | ft | Out-String) -ForegroundColor Gray}
