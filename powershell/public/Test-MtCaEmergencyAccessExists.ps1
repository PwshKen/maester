<#
 .Synopsis
  Checks if the tenant has at least one emergency/break glass account or account group excluded from all conditional access policies

 .Description
  It is recommended to have at least one emergency/break glass account or account group excluded from all conditional access policies.
  This allows for emergency access to the tenant in case of a misconfiguration or other issues.

  Learn more:
  https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access

 .Example
  Test-MtCaEmergencyAccessExists
#>

Function Test-MtCaEmergencyAccessExists {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Exists is not a plural.')]
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    # Only check policies that are not related to authentication context
    $policies = Get-MtConditionalAccessPolicy | Where-Object { -not $_.conditions.applications.includeAuthenticationContextClassReferences }

    $result = $false
    $PolicyCount = $policies | Measure-Object | Select-Object -ExpandProperty Count
    $ExcludedUserObjectGUID = $policies.conditions.users.excludeUsers | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -First 1 -ExpandProperty Name
    $ExcludedUsers = $policies.conditions.users.excludeUsers | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Count
    $ExcludedGroupObjectGUID = $policies.conditions.users.excludeGroups | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -First 1 -ExpandProperty Name
    $ExcludedGroups = $policies.conditions.users.excludeGroups | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Count
    # If the number of enabled policies is not the same as the number of excluded users or groups, there is no emergency access
    if ($PolicyCount -eq $ExcludedUsers -or $PolicyCount -eq $ExcludedGroups) {
        $result = $true
    } else {
        # If the number of excluded users is higher than the number of excluded groups, check the user object GUID
        $CheckId = $ExcludedGroupObjectGUID
        if ($ExcludedUsers -gt $ExcludedGroups) { $CheckId = $ExcludedUserObjectGUID }
        Write-Verbose "Emergency access account or group: $CheckId"

        $policiesWithoutEmergency = $policies | Where-Object { $CheckId -notin $_.conditions.users.excludeUsers -and $CheckId -notin $_.conditions.users.excludeGroups }

        $policiesWithoutEmergency | Select-Object -ExpandProperty displayName | Sort-Object | ForEach-Object {
            Write-Verbose "Conditional Access policy $_ does not exclude emergency access account or group"
        }
    }

    Add-MtTestResultDetail -GraphObjects $policiesWithoutEmergency -GraphObjectType ConditionalAccess
    return $result
}