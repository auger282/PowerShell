<#
.Synopsis
   Launchpad to connect to the varius Microsoft Systems via Powershell
.DESCRIPTION
   Menu driven LaunchPad makes it easier to connect to the different PowerShell
   sessions for Office 365. You must have the correct PowerShell modules installed
   before this launchpad will work properly.

   **Run in PowerShell ISE to keep session open after the connection is established.

   **Enter your usernames for cloud admin and local admin at the top of the code
     so you don't have to type it in every time.

   **Enter your Exchange On Premises ConnectionURI and Sharepoint spoServiceURL
     to use those services.

.NOTES
   Author : Auger282
   GitHub : https://github.com/auger282/
   Version: .6
   Date   : 4/7/17
   Changes: Added Office 365 Security & Compliance Center
#>

#############################################################################
#### Set Variables
####
#############################################################################

# Use these settings to save you from having to type your username every time
$onlineAdminUsername = "" # username@company.onmicrosoft.com
$localAdminUsername = "" # domain\username

# REQUIRED - ConnectionUri for On Premise Exchange Service
$localExchangeSvr = "" # http://server.domain.com/PowerShell/

# REQUIRED - URL for SharePoint Online
$spoServiceURL = "" # https://domain-admin.sharepoint.com

#############################################################################
#### Main
####
#############################################################################

# Check if the script is running in ISE or not
# This script should only be used in ISE to keep the session open after the connection is established
If($psISE -eq $null) {
    cls
    Write-Host
    Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Write-Host "!!!      This Launcher Should Only Be Used      !!!"
    Write-Host "!!!             With PowerShell ISE             !!!"
    Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Write-Host
    pause
    exit
}

do{
    $startingErrorCount = $error.count # Counter to check for login errors
    $menuSelect = 0
    cls
    Write-Host "Microsoft PowerShell LaunchPad"
    Write-Host
    Write-Host
    Write-Host "Please select which system you would like to connect to:"
    Write-Host
    Write-Host "     1 = Active Directory On Premises (current user)"
    Write-Host "     2 = Exchange On Premises"
    Write-Host "     3 = MS On Line"
    Write-Host "     4 = Exchange Online"
    Write-Host "     5 = Skype for Business"
    Write-Host "     6 = SharePoint Online"
    Write-Host "     7 = Office 365 Security & Compliance Center"
    Write-Host
    Write-Host "     9 = Disconnect All Sessions"
    Write-Host "     q = Exit Program"
    Write-Host
    Write-Host
    $menuSelect = Read-Host -prompt "What's your selection?"

    If($menuSelect -eq 1) {
        cls
        Write-Host
        Write-Host "Connecting to On Premise Active Directory..."
        Write-Host
        Import-Module activedirectory
    }
    elseif($menuSelect -eq 2) {
        # Check to make sure a local ConnectionURI is configured before continuing to connect
        If(!$localExchangeSvr){
            cls
            Write-Host
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            Write-Host "!!! `$localExchangeSvr ConnctionURI not set      !!!"
            Write-Host "!!! Please update script                        !!!"
            Write-Host "!!! Before using this option                    !!!"
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            Write-Host
            pause
        }
        else{
            if(!$localAdmin){$localAdmin = Get-Credential -message "Please supply password for Local Admin" -username $localAdminUsername}
            cls
            Write-Host
            Write-Host "Connecting to On Premise Exchange Service..."
            Write-Host
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $localExchangeSvr -Credential $localAdmin -Authentication Kerberos
            Import-PSSession $Session
        }
    }
    elseif($menuSelect -eq 3){
        if(!$onlineAdmin){$onlineAdmin = Get-Credential -message "Please supply password for Online Admin" -username $onlineAdminUsername}
        cls
        Write-Host
        Write-Host "Connecting to MSOL O365..."
        Write-Host
        Connect-MsolService -Credential $onlineAdmin
    }
    elseif($menuSelect -eq 4){
        if(!$onlineAdmin){$onlineAdmin = Get-Credential -message "Please supply password for Online Admin" -username $onlineAdminUsername}
        cls
        Write-Host
        Write-Host "Connecting to Exchange Online..."
        Write-Host
        $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $onlineAdmin -Authentication "Basic" -AllowRedirection
        Import-PSSession $exchangeSession -DisableNameChecking
    }
    elseif($menuSelect -eq 5){
        if(!$onlineAdmin){$onlineAdmin = Get-Credential -message "Please supply password for Online Admin" -username $onlineAdminUsername}
        cls
        Write-Host
        Write-Host "Connecting to Skype for Business Online..."
        Write-Host
        Import-Module LyncOnlineConnector
        $sfboSession = New-CsOnlineSession -Credential $onlineAdmin
        Import-PSSession $sfboSession
    }
    elseif($menuSelect -eq 6){
        # Check to make sure SPOService URL is configured before continuing to connect
        If(!$spoServiceURL){
            cls
            Write-Host
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            Write-Host "!!! `$spoServiceURL is not set                   !!!"
            Write-Host "!!! Please update script                        !!!"
            Write-Host "!!! Before using this option                    !!!"
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            Write-Host
            pause
        }
        else{
            if(!$onlineAdmin){$onlineAdmin = Get-Credential -message "Please supply password for Online Admin" -username $onlineAdminUsername}
            cls
            Write-Host
            Write-Host "Connecting to SharePoint Online..."
            Write-Host
            Import-Module Microsoft.Online.Sharepoint.PowerShell
            Connect-SPOService -url $spoServiceURL -Credential $onlineAdmin
        }
    }
    elseif($menuSelect -eq 7){
        # Check to make sure SPOService URL is configured before continuing to connect
        If(!$spoServiceURL){
            cls
            Write-Host
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            Write-Host "!!! `$spoServiceURL is not set                   !!!"
            Write-Host "!!! Please update script                        !!!"
            Write-Host "!!! Before using this option                    !!!"
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            Write-Host
            pause
        }
        else{
            if(!$onlineAdmin){$onlineAdmin = Get-Credential -message "Please supply password for Online Admin" -username $onlineAdminUsername}
            cls
            Write-Host
            Write-Host "Connecting to Office 365 Security & Compliance Center..."
            Write-Host
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid -Credential $onlineAdmin -Authentication Basic -AllowRedirection 
            Import-PSSession $Session -AllowClobber -DisableNameChecking 
            $Host.UI.RawUI.WindowTitle = $UserCredential.UserName + " (Office 365 Security & Compliance Center)" 
        }
    }
    elseif($menuSelect -eq 9){
        cls
        Write-Host
        Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        Write-Host "!!!        You are now Disconnected from        !!!"
        Write-Host "!!!           all PowerShell Sessions           !!!"
        Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        Write-Host
        Get-PSSession | Remove-PSSession
        pause
    }
    elseif($menuSelect -eq "q"){Exit}

    # Error message if you made an invalid choice
    If("1","2","3","4","5","6","7","9","!" -notcontains $menuSelect) {
        Write-Host
        Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        Write-Host "!!! You have not entered in a valid menu choice !!!"
        Write-Host "!!! Please try again                            !!!"
        Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        Write-Host
        pause
    }

    # Error message if login failed - Clear login variables and loop again
    If($error.count -gt $startingErrorCount){
        Write-Host
        Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        Write-Host "!!! Login Error Encountered                     !!!"                
        Write-Host "!!! You have typed in your password incorrectly !!!"
        Write-Host "!!! Or you're missing the required module       !!!"
        Write-Host "!!! Please try again                            !!!"
        Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        Write-Host
        pause
        $menuSelect = 0
        Clear-Variable onlineAdmin
        Clear-Variable localAdmin
    }
}
# While you have an invalid selection continue looping
while("1","2","3","4","5","6","7","q" -notcontains $menuSelect)
