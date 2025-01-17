<#
.SYNOPSIS
    Checks if Default Settings - Password Rule Settings - Password Protection - Mode is set to 'Enforce'

.DESCRIPTION

    If set to Enforce, users will be prevented from setting banned passwords and the attempt will be logged. If set to Audit, the attempt will only be logged.

    Queries settings
    and returns the result of
     graph/settings.values | where-object name -eq 'BannedPasswordCheckOnPremisesMode' | select-object -expand value -eq 'Enforce'

.EXAMPLE
    Test-MtEidscaPR01

    Returns the result of graph.microsoft.com/beta/settings.values | where-object name -eq 'BannedPasswordCheckOnPremisesMode' | select-object -expand value -eq 'Enforce'
#>

Function Test-MtEidscaPR01 {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $result = Invoke-MtGraphRequest -RelativeUri "settings" -ApiVersion beta

    $tenantValue = $result.values | where-object name -eq 'BannedPasswordCheckOnPremisesMode' | select-object -expand value
    $testResult = $tenantValue -eq 'Enforce'

    if($testResult){
        $testResultMarkdown = "Well done. Your tenant has the recommended value of **'Enforce'** for **settings**"
    }
    else {
        $testResultMarkdown = "Your tenant is configured as **$($tenantValue)**.`n`nThe recommended value is **'Enforce'** for **settings**"
    }
    Add-MtTestResultDetail -Result $testResultMarkdown

    return $tenantValue
}
