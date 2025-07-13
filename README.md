# AD-User-Password-Expiry-Report

## Description
This PowerShell script retrieves all enabled Active Directory users and displays key information about their password status. The script identifies the source of each user's password policy (whether from a Fine-Grained Password Policy (PSO) or the Default Domain Policy), shows the date the password was last set, whether the password is set to never expire, whether the password has already expired, and the number of days remaining until expiration.

Expired accounts are visually highlighted in yellow for quick identification.  
The output is presented in a clean, numbered table, sorted by the number of days remaining from highest to lowest.

## Features
- Retrieves all enabled AD users
- Displays password policy source (PSO / Default Domain Policy)
- Shows password last set date
- Indicates if password never expires
- Highlights accounts where the password has expired
- Calculates days remaining until password expiration
- Outputs a numbered list for easy tracking

## Columns Displayed
- Row Number
- Username
- Password Policy Source (PSO / Default Domain Policy)
- Password Last Set Date
- Never Expires (True/False)
- Expired (True/False)
- Days Left Until Expiration

## Example Output
```
1   user01               Default Domain Policy        05/01/2025 09:00:00      False      False      85       
2   user02               PSO: SecurePolicy            06/15/2025 08:00:00      False      False      60       
3   user03               Default Domain Policy        04/20/2025 07:30:00      False      True       0        
```

Accounts with `Expired: True` are displayed in yellow.

## Usage
1. Run the script in a PowerShell session with sufficient permissions to query Active Directory.
2. Ensure the `ActiveDirectory` module is available and imported.
3. Review the output in the PowerShell console.

## Requirements
- Active Directory module for PowerShell
- Permissions to read user attributes in AD
- Domain environment with either Default Domain Policy or Fine-Grained Password Policies in use

## Notes
- Password expiration is calculated based on the user's applicable policy (PSO or Default Domain Policy).
- The script respects accounts marked with `Password Never Expires`.
- Sorting is from the highest to lowest number of days remaining until expiration.
