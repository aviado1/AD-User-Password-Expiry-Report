<#
.DESCRIPTION
-----------
This script retrieves all enabled Active Directory users and displays their password policy source,
password last set date, expiration status, and days remaining until password expiration.  
The results are sorted by the number of days remaining (DaysLeft) from highest to lowest.  
Users with expired passwords are highlighted in yellow for quick identification.

The output includes row numbering for clarity.

Password policy source is determined by either a Fine-Grained Password Policy (PSO) or the Default Domain Policy.

Columns displayed:
- Row Number
- Username
- Password Policy Source (PSO / Default Domain Policy)
- Password Last Set Date
- Never Expires (True/False)
- Expired (True/False)
- Days Left Until Expiration

#>

# Import Active Directory module
Import-Module ActiveDirectory

# Get all enabled users from the domain
$Users = Get-ADUser -Filter {Enabled -eq $true} -Properties msDS-ResultantPSO, PasswordLastSet, PasswordNeverExpires, PasswordExpired

# Get domain max password age
$DomainMaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Prepare results
$Results = foreach ($User in $Users) {
    if ($User.'msDS-ResultantPSO') {
        $PSO = Get-ADObject -Identity $User.'msDS-ResultantPSO' -Properties *
        $PolicySource = "PSO: $($PSO.Name)"
        $MaxPasswordAge = $PSO.'msDS-MaximumPasswordAge'
    } else {
        $PolicySource = "Default Domain Policy"
        $MaxPasswordAge = $DomainMaxPasswordAge
    }

    $LastSet = $User.PasswordLastSet
    $NeverExpires = $User.PasswordNeverExpires
    $Expired = $User.PasswordExpired

    if (-not $NeverExpires -and $LastSet) {
        $ExpiryDate = $LastSet + $MaxPasswordAge
        $DaysLeft = ($ExpiryDate - (Get-Date)).Days
    } else {
        $DaysLeft = $null
    }

    [PSCustomObject]@{
        Username        = $User.SamAccountName
        PolicySource    = $PolicySource
        PasswordLastSet = $LastSet
        NeverExpires    = $NeverExpires
        Expired         = $Expired
        DaysLeft        = $DaysLeft
    }
}

# Sort by DaysLeft descending
$Results = $Results | Sort-Object DaysLeft -Descending

# Output numbered list with yellow for expired
$Counter = 1
$Results | ForEach-Object {
    $Line = "{0,-3} {1,-20} {2,-30} {3,-25} {4,-10} {5,-10} {6,-10}" -f `
        $Counter, $_.Username, $_.PolicySource, $_.PasswordLastSet, $_.NeverExpires, $_.Expired, $_.DaysLeft

    if ($_.Expired) {
        Write-Host $Line -ForegroundColor Yellow
    } else {
        Write-Host $Line
    }
    $Counter++
}
