function Add-DocuSignADUserInfo {
<#
.SYNOPSIS
    Adds Active Directory user attributes to a DocuSign user csv
.DESCRIPTION
    This function looks up the DocuSign user in Active Directory by matching the DocuSign user's UserEmail property with the
    Active Directory user's mail attribute, then it adds selected AD attributes as properties to the PowerShell object in the pipeline.
.EXAMPLE
    PS C:\> Import-Csv "C:\Temp\organization_external_memberships_export.csv" | Add-DocuSignADUserInfo
    Imports the "organization_external_memberships_export.csv" file and adds Active Directory attributes for the DocuSign users contained in the file
.INPUTS
    PowerShell object
.PARAMETER Input
    This parameter is meant to be a PowerShell object and is expected to be input from the pipeline.
.NOTES
    Created: April 10, 2020
    Author: David Bird
#>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True)]
        $Input
    )
        
    begin {
    }
        
    process {
        foreach ($User in $Input) {
            <#
             Lookup the DocuSign user by using DocuSign's UserEmail property and Active Directory's mail attribute
             Note: This is the default SSO configuration for DocuSign with Azure Active Directory. It is possible your organization is using
             a different SSO configuration.
             #>
            Write-Verbose "Looking up $($User.UserEmail) in Active Directory..."
            $ADUserParams = @{
                Properties = 'mail'
                Filter     = "mail -like '*$($User.UserEmail)'"
            }
            $ADUserInfo = Get-ADUser @ADUserParams
    
            # If Else statement needed here to only add the AD attributes if they exist.

            # Add the properties of $ADUserInfo to the object
            $User | Add-Member -NotePropertyName ADUserPrincipalName -NotePropertyValue $ADUserInfo.UserPrincipalName
            $User | Add-Member -NotePropertyName ADName -NotePropertyValue $ADUserInfo.Name
            $User | Add-Member -NotePropertyName ADMail -NotePropertyValue $ADUserInfo.Mail
            $User | Add-Member -NotePropertyName ADEnabled -NotePropertyValue $ADUserInfo.Enabled
    
            # Send the object (which now contains the additional AD user info properties) to the pipeline
            $User
        }
    }
        
    end {
    }
}