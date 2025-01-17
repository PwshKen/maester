<#
.SYNOPSIS
    Checks if Default Authorization Settings - Risk-based step-up consent is set to 'false'

.DESCRIPTION

    Indicates whether user consent for risky apps is allowed. For example, consent requests for newly registered multi-tenant apps that are not publisher verified and require non-basic permissions are considered risky.

    Queries policies/authorizationPolicy
    and returns the result of
     graph/policies/authorizationPolicy.allowUserConsentForRiskyApps -eq 'false'

.EXAMPLE
    Test-MtEidscaAP09

    Returns the result of graph.microsoft.com/beta/policies/authorizationPolicy.allowUserConsentForRiskyApps -eq 'false'
#>

Function Test-MtEidscaAP09 {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $result = Invoke-MtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion beta

    $tenantValue = $result.allowUserConsentForRiskyApps
    $testResult = $tenantValue -eq 'false'

    if($testResult){
        $testResultMarkdown = "Well done. Your tenant has the recommended value of **'false'** for **policies/authorizationPolicy**"
    }
    else {
        $testResultMarkdown = "Your tenant is configured as **$($tenantValue)**.`n`nThe recommended value is **'false'** for **policies/authorizationPolicy**"
    }
    Add-MtTestResultDetail -Result $testResultMarkdown

    return $tenantValue
}
