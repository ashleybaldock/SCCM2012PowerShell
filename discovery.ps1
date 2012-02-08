
# Functions associated with SCCM 2012 Discovery Methods




#########################
#  AD Forest Discovery  #
#########################

#  Auto create site boundaries (on/off)
#  Auto create IP subnet boundaries (on/off)
#  Schedule

# Configuration
Function Enable-ADForestDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADForestDiscovery -SiteCode $SiteCode -Enable $true -Force
        }
    }
}
Function Disable-ADForestDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADForestDiscovery -SiteCode $SiteCode -Enable $false -Force
        }
    }
}
Function Set-ADForestDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [switch]
            $Enabled = $null,
        [string]
            $Schedule,
        [switch]
            $CreateSiteBoundaries = $null,
        [switch]
            $CreateSubnetBoundaries = $null
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            $ADForestDiscoveryManager = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_AD_FOREST_DISCOVERY_MANAGER'"

            $propstemp = $ADForestDiscoveryManager.Props

            foreach ($prop in $propstemp) {
                if ($Enable -ne $null -and $prop.PropertyName -eq "SETINGS") {
                    if ($Enable -eq $true) { $prop.Value1 = "ACTIVE" }
                    if ($Enable -eq $false) { $prop.Value1 = "INACTIVE" }
                }
                if ($Schedule -ne "" -and $prop.PropertyName -eq "Startup Schedule") {
                    $prop.Value1 = $Schedule
                }
                if ($CreateSiteBoundaries -ne $null -and $Prop.PropertyName -eq "Enable AD Site Boundary Creation") {
                    if ($CreateSiteBoundaries -eq $true) { $prop.Value = 1 }
                    if ($CreateSiteBoundaries -eq $false) { $prop.Value = 0 }
                }
                if ($CreateSubnetBoundaries -ne $null -and $Prop.PropertyName -eq "Enable Subnet Boundary Creation") {
                    if ($CreateSubnetBoundaries -eq $true) { $prop.Value = 1 }
                    if ($CreateSubnetBoundaries -eq $false) { $prop.Value = 0 }
                }
            }

            # Finally write changes back to the object
            $ADForestDiscoveryManager.Props = $propstemp
            $ADForestDiscoveryManager.put()
        }
    }
}



########################
#  AD Group Discovery  #
########################

#  Discovery scopes
#   Add AD Group
#   Config AD Group
#   Remove AD Group
#   Add AD Location
#   Config AD Location
#   Remove AD Location
#  Discovery polling schedule
#  Delta discovery (enable/disable)
#   Delta discovery interval
#  Option: Only discover machines logged onto domain in last X days
#  Option: Only discover machines which have updated machine account password in last X days
#  Option: Discover membership of distribution groups

# Configuration
Function Enable-ADGroupDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADGroupDiscovery -SiteCode $SiteCode -Enable $true -Force
        }
    }
}
Function Disable-ADGroupDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADGroupDiscovery -SiteCode $SiteCode -Enable $false -Force
        }
    }
}
Function Set-ADGroupDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [switch]
            $Enabled = $null,
        [string]
            $FullSyncSchedule = "None",
        [switch]
            $EnableDelta = $null,
        [int] # mins
        [ValidateRange(5,60)]
            $DeltaInterval = $null,
        [switch]
            $FilterExpiredLogon = $null,
        [int] # days
        [ValidateRange(14,720)]
            $DaysSinceLastLogon = $null,
        [switch]
            $FilterExpiredPassword = $null,
        [int] # days
        [ValidateRange(30,720)]
            $DaysSinceLastPassword = $null,
        [switch]
            $DistributionGroupDiscover = $null
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }

        # If $DeltaInterval is not $null, create a new schedule object from it
        if ($DeltaInterval -ne $null) {
            # TODO explore the strings which SCCM creates to find what the other parameters ought to be
            #  set to (especially UTC/Unzoned)
            $td = Get-Date
            $DeltaInterval = New-IntervalString -Start $td -MinuteSpan $DeltaInterval
        }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            $ADGroupDiscoveryManager = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'"

            $propstemp = $ADGroupDiscoveryManager.Props

            foreach ($prop in $propstemp) {
                # Basic settings
                if ($Enable -ne $null -and $prop.PropertyName -eq "SETINGS") {
                    if ($Enable -eq $true) { $prop.Value1 = "ACTIVE" }
                    if ($Enable -eq $false) { $prop.Value1 = "INACTIVE" }
                }
                if ($FullSyncSchedule -ne "None" -and $prop.PropertyName -eq "Full Sync Schedule") {
                    $prop.Value1 = $FullSyncSchedule
                }

                # Delta discovery
                if ($EnableDelta -ne $null -and $Prop.PropertyName -eq "Enable Incremental Sync") {
                    if ($EnableDelta -eq $true) { $prop.Value = 1 }
                    if ($EnableDelta -eq $false) { $prop.Value = 0 }
                }
                if ($DeltaInterval -ne $null -and $prop.PropertyName -eq "Startup Schedule") {
                    $prop.Value1 = $DeltaInterval
                }

                # Last logon filter
                if ($FilterExpiredLogon -ne $null -and $Prop.PropertyName -eq "Enable Filtering Expired Logon") {
                    if ($FilterExpiredLogon -eq $true) { $prop.Value = 1 }
                    if ($FilterExpiredLogon -eq $false) { $prop.Value = 0 }
                }
                if ($DaysSinceLastLogon -ne $null -and $prop.PropertyName -eq "Days Since Last Logon") {
                    $prop.Value = $DaysSinceLastLogon
                }

                # Machine account password expiry filter
                if ($FilterExpiredPassword -ne $null -and $Prop.PropertyName -eq "Enable Filtering Expired Password") {
                    if ($FilterExpiredPassword -eq $true) { $prop.Value = 1 }
                    if ($FilterExpiredPassword -eq $false) { $prop.Value = 0 }
                }
                if ($DaysSinceLastPassword -ne $null -and $prop.PropertyName -eq "Days Since Last Password Set") {
                    $prop.Value = $DaysSinceLastPassword
                }

                # Distribution group discovery
                if ($DistributionGroupDiscover -ne $null -and $Prop.PropertyName -eq "Discover DG Membership") {
                    if ($DistributionGroupDiscover -eq $true) { $prop.Value = 1 }
                    if ($DistributionGroupDiscover -eq $false) { $prop.Value = 0 }
                }
            }

            # Finally write changes back to the object
            $ADGroupDiscoveryManager.Props = $propstemp
            $ADGroupDiscoveryManager.put()
        }
    }
}
# AD Group Scopes
Function Add-ADGroupDiscoveryGroupScope
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# Name (arbitrary)
# Domain + Forest
# Groups[] (strings)
# Account for discovery
Function Remove-ADGroupDiscoveryGroupScope
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [somekindaobject[]] # TODO object?
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            $GroupScope
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($GrpScope in $GroupScope) {
            if ($Force -or $pscmdlet.ShouldProcess()) {
                # TODO
            }
        }
    }
}
Function Get-ADGroupDiscoveryGroupScope
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-ADGroupDiscoveryGroupScope
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# AD Location Scopes
Function Add-ADGroupDiscoveryLocationScope
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# Name (arbitrary)
# Location (LDAP path)
#  Option: Recursive search
# Discovery account
Function Remove-ADGroupDiscoveryLocationScope
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [somekindaobject[]] # TODO object?
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            $LocationScope
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($LocScope in $LocationScope) {
            if ($Force -or $pscmdlet.ShouldProcess()) {
                # TODO
            }
        }
    }
}
Function Get-ADGroupDiscoveryLocationScope
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-ADGroupDiscoveryLocationScope
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}



#########################
#  AD System Discovery  #
#########################

#  AD Containers
#   Add AD Container
#   Config AD Container
#   Remove AD Container
#  Polling schedule
#  Delta discovery (enable/disable)
#   Delta discovery interval (mins)
#  Active directory attributes
#   Add attribute
#   Remove attribute
#   Custom attributes
#  Option: Only discover machines logged onto domain in last X days
#  Option: Only discover machines which have updated machine account password in last X days

# Configuration
Function Enable-ADSystemDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADSystemDiscovery -SiteCode $SiteCode -Enable $true -Force
        }
    }
}
Function Disable-ADSystemDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADSystemDiscovery -SiteCode $SiteCode -Enable $false -Force
        }
    }
}
Function Set-ADSystemDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [switch]
            $Enabled = $null,
        [string]
            $FullSyncSchedule = "None",
        [switch]
            $EnableDelta = $null,
        [int] # mins
        [ValidateRange(5,60)]
            $DeltaInterval = $null,
        [switch]
            $FilterExpiredLogon = $null,
        [int] # days
        [ValidateRange(14,720)]
            $DaysSinceLastLogon = $null,
        [switch]
            $FilterExpiredPassword = $null,
        [int] # days
        [ValidateRange(30,720)]
            $DaysSinceLastPassword = $null
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }

        # If $DeltaInterval is not $null, create a new schedule object from it
        if ($DeltaInterval -ne $null) {
            # TODO explore the strings which SCCM creates to find what the other parameters ought to be
            #  set to (especially UTC/Unzoned)
            $td = Get-Date
            $DeltaInterval = New-IntervalString -Start $td -MinuteSpan $DeltaInterval
        }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            $ADSystemDiscoveryManager = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'"
            $propstemp = $ADSystemDiscoveryManager.Props

            foreach ($prop in $propstemp) {
                # Basic settings
                if ($Enable -ne $null -and $prop.PropertyName -eq "SETINGS") {
                    if ($Enable -eq $true) { $prop.Value1 = "ACTIVE" }
                    if ($Enable -eq $false) { $prop.Value1 = "INACTIVE" }
                }
                if ($FullSyncSchedule -ne "None" -and $prop.PropertyName -eq "Full Sync Schedule") {
                    $prop.Value1 = $FullSyncSchedule
                }

                # Delta discovery
                if ($EnableDelta -ne $null -and $Prop.PropertyName -eq "Enable Incremental Sync") {
                    if ($EnableDelta -eq $true) { $prop.Value = 1 }
                    if ($EnableDelta -eq $false) { $prop.Value = 0 }
                }
                if ($DeltaInterval -ne $null -and $prop.PropertyName -eq "Startup Schedule") {
                    $prop.Value1 = $DeltaInterval
                }

                # Last logon filter
                if ($FilterExpiredLogon -ne $null -and $Prop.PropertyName -eq "Enable Filtering Expired Logon") {
                    if ($FilterExpiredLogon -eq $true) { $prop.Value = 1 }
                    if ($FilterExpiredLogon -eq $false) { $prop.Value = 0 }
                }
                if ($DaysSinceLastLogon -ne $null -and $prop.PropertyName -eq "Days Since Last Logon") {
                    $prop.Value = $DaysSinceLastLogon
                }

                # Machine account password expiry filter
                if ($FilterExpiredPassword -ne $null -and $Prop.PropertyName -eq "Enable Filtering Expired Password") {
                    if ($FilterExpiredPassword -eq $true) { $prop.Value = 1 }
                    if ($FilterExpiredPassword -eq $false) { $prop.Value = 0 }
                }
                if ($DaysSinceLastPassword -ne $null -and $prop.PropertyName -eq "Days Since Last Password Set") {
                    $prop.Value = $DaysSinceLastPassword
                }
            }

            # Finally write changes back to the object
            $ADSystemDiscoveryManager.Props = $propstemp
            $ADSystemDiscoveryManager.put()
        }
    }
}
# AD Containers
Function Add-ADSystemDiscoveryContainer
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-ADSystemDiscoveryContainer
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-ADSystemDiscoveryContainer
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-ADSystemDiscoveryContainer
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# AD Attributes
Function Add-ADSystemDiscoveryAttribute
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-ADSystemDiscoveryAttribute
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-ADSystemDiscoveryAttribute
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-ADSystemDiscoveryAttribute
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}



#######################
#  AD User Discovery  #
#######################

#  AD Containers (same as for system discovery)
#   Add AD Container
#   Config AD Container
#   Remove AD Container
#  Polling schedule
#  Delta discovery (enable/disable)
#   Delta discovery interval (mins)
#  Active directory attributes (same as for system discovery)
#   Add attribute
#   Remove attribute
#   Custom attributes

# Configuration
Function Enable-ADUserDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADUserDiscovery -SiteCode $SiteCode -Enable $true -Force
        }
    }
}
Function Disable-ADUserDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADUserDiscovery -SiteCode $SiteCode -Enable $false -Force
        }
    }
}
Function Set-ADUserDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [switch]
            $Enabled = $null,
        [string]
            $FullSyncSchedule = "None",
        [switch]
            $EnableDelta = $null,
        [int] # mins
        [ValidateRange(5,60)]
            $DeltaInterval = $null
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }

        # If $DeltaInterval is not $null, create a new schedule object from it
        if ($DeltaInterval -ne $null) {
            # TODO explore the strings which SCCM creates to find what the other parameters ought to be
            #  set to (especially UTC/Unzoned)
            $td = Get-Date
            $DeltaInterval = New-IntervalString -Start $td -MinuteSpan $DeltaInterval
        }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            $ADUserDiscoveryManager = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'"

            $propstemp = $ADUserDiscoveryManager.Props

            foreach ($prop in $propstemp) {
                # Basic settings
                if ($Enable -ne $null -and $prop.PropertyName -eq "SETINGS") {
                    if ($Enable -eq $true) { $prop.Value1 = "ACTIVE" }
                    if ($Enable -eq $false) { $prop.Value1 = "INACTIVE" }
                }
                if ($FullSyncSchedule -ne "None" -and $prop.PropertyName -eq "Full Sync Schedule") {
                    $prop.Value1 = $FullSyncSchedule
                }

                # Delta discovery
                if ($EnableDelta -ne $null -and $Prop.PropertyName -eq "Enable Incremental Sync") {
                    if ($EnableDelta -eq $true) { $prop.Value = 1 }
                    if ($EnableDelta -eq $false) { $prop.Value = 0 }
                }
                if ($DeltaInterval -ne $null -and $prop.PropertyName -eq "Startup Schedule") {
                    $prop.Value1 = $DeltaInterval
                }
            }

            # Finally write changes back to the object
            $ADUserDiscoveryManager.Props = $propstemp
            $ADUserDiscoveryManager.put()
        }
    }
}
# AD Containers
Function Add-ADUserDiscoveryContainer
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-ADUserDiscoveryContainer
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-ADUserDiscoveryContainer
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-ADUserDiscoveryContainer
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# AD Attributes
Function Add-ADUserDiscoveryAttribute
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-ADUserDiscoveryAttribute
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-ADUserDiscoveryAttribute
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-ADUserDiscoveryAttribute
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}



#########################
#  Heartbeat Discovery  #
#########################

Function Enable-HeartbeatDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-HeartbeatDiscovery -SiteCode $SiteCode -Enable $true -Force
        }
    }
}
Function Disable-HeartbeatDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-HeartbeatDiscovery -SiteCode $SiteCode -Enable $false -Force
        }
    }
}
Function Set-HeartbeatDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [switch]
            $Enabled = $null,
        [string]
            $Schedule = "None"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # First configure under SMS_SCI_Component -> ComponentName='SMS_SITE_CONTROL_MANAGER'
            $ADHeartbeatDiscovery = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_SITE_CONTROL_MANAGER'"
            $propstemp = $ADHeartbeatDiscovery.Props

            foreach ($prop in $propstemp) {
                if ($Schedule -ne "None" -and $prop.PropertyName -eq "Heartbeat Site Control File Schedule") {
                    $prop.Value1 = $Schedule
                }
            }

            $ADHeartbeatDiscovery.Props = $propstemp
            $ADHeartbeatDiscovery.put()

            # Second configure under SMS_SCI_ClientConfig -> ItemName='Client Properties'
            $ADHeartbeatDiscovery = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_ClientConfig -Filter "ItemName='Client Properties'"
            $propstemp = $ADHeartbeatDiscovery.Props

            foreach ($prop in $propstemp) {
                if ($Enable -ne $null -and $prop.PropertyName -eq "Enable Heartbeat DDR") {
                    if ($Enable -eq $true) { $prop.Value = 1 }
                    if ($Enable -eq $false) { $prop.Value = 0 }
                }
                if ($Schedule -ne "None" -and $prop.PropertyName -eq "DDR Refresh Interval") {
                    $prop.Value2 = $Schedule
                }
            }

            $ADHeartbeatDiscovery.Props = $propstemp
            $ADHeartbeatDiscovery.put()
        }
    }
}



#######################
#  Network Discovery  #
#######################

#  Type:
#   Topology
#   Topology & Client
#   Topology, Client & Client OS
#  Network speed (enable(slow)/disable(fast))
#  Subnets
#   Add Subnet
#   Remove Subnet
#   Config Subnet
#    Subnet search (enable/disable)
#   Option: Search local subnets
#  Domains
#   Add Domain
#   Remove Domain
#   Config Domain
#    Domain search (enable/disable)
#   Option: Search local domain
#  SNMP community names
#   Add SNMP community name (name)
#   Remove SNMP community name
#   Config SNMP community name (change name)
#   Option: Maximum hops (0-10)
#  SNMP devices
#   Add SNMP device (IP address)
#   Remove SNMP device
#   Config SNMP device (change IP address)
#  DHCP servers
#   Add DHCP server (IP address or server name)
#   Remove DHCP server
#   Config DHCP server (change address/name)
#   Option: Include DHCP server that site server is configured to use
#  Schedules (multiple)

# Configuration
Function Enable-NetworkDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-NetworkDiscovery -SiteCode $SiteCode -Enable $true -Force
        }
    }
}
Function Disable-NetworkDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-NetworkDiscovery -SiteCode $SiteCode -Enable $false -Force
        }
    }
}
Function Set-NetworkDiscovery
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [switch]
            $Enabled = $null,
        [ValidateCount(0,1)]
        [ValidateSet("Topology", "TopologyAndClient", "ToplologyClientAndOS")]
            $Type = "None",
        [switch]
            $SlowNetwork = $null,
        [switch]
            $SearchLocalSubnets = $null,
        [switch]
            $SearchLocalDomain = $null,
        [int]
        [ValidateRange(0,10)]
            $SNMPMaxHops = $null,
        [switch]
            $SearchLocalDHCP = $null
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
            $NetworkDiscoveryConfig = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Configuration -Filter "ItemName='SMS_NETWORK_DISCOVERY'"

            $propstempcomponent = $NetworkDiscoveryComponent.Props
            $propstempconfig = $NetworkDiscoveryConfig.Props

            # Set enabled (may be null)
            if ($Enabled -eq $true) {
                ($propstempcomponent | where {$_.PropertyName -eq "Discovery Enabled"}).Value1 = "TRUE"
                ($propstempconfig | where {$_.PropertyName -eq "Discovery Enabled"}).Value1 = "TRUE"
            }
            if ($Enabled -eq $false) {
                ($propstempcomponent | where {$_.PropertyName -eq "Discovery Enabled"}).Value1 = "FALSE"
                ($propstempconfig | where {$_.PropertyName -eq "Discovery Enabled"}).Value1 = "FALSE"
            }

            # Topology discovery type
            if ($Type -eq "Topology") {
                ($propstempconfig | where {$_.PropertyName -eq "Discovery Type"}).Value1 = "Topology"
                ($propstempcomponent | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = "DISABLED"
            }
            if ($Type -eq "TopologyAndClient") {
                ($propstempconfig | where {$_.PropertyName -eq "Discovery Type"}).Value1 = "Topology And Client"
            }
            if ($Type -eq "TopologyClientAndOS") {
                ($propstempconfig | where {$_.PropertyName -eq "Discovery Type"}).Value1 = "Topology Client And Client OS"
            }
            if ($Type -eq "TopologyClientAndOS" -or $Type -eq "TopologyAndClient") {
                if (($propstempconfig | where {$_.PropertyName -eq "Network Speed"}).Value1 -eq "Slow") {
                    ($propstempcomponent | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval - SLOW"}).Value1
                    ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval - SLOW"}).Value1
                } else {
                    ($propstempcomponent | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval - FAST"}).Value1
                    ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval - FAST"}).Value1
                }
            }

            # Local subnet search
            if ($SearchLocalSubnets -eq $true) {
                ($propstempcomponent | where {$_.PropertyName -eq "Subnet Include Local"}).Value1 = "TRUE"
                ($propstempconfig | where {$_.PropertyName -eq "Subnet Include Local"}).Value1 = "TRUE"
            }
            if ($SearchLocalSubnets -eq $false) {
                ($propstempcomponent | where {$_.PropertyName -eq "Subnet Include Local"}).Value1 = "FALSE"
                ($propstempconfig | where {$_.PropertyName -eq "Subnet Include Local"}).Value1 = "FALSE"
            }

            # Local domain search
            if ($SearchLocalDomain -eq $true) {
                ($propstempcomponent | where {$_.PropertyName -eq "Domain Include Local"}).Value1 = "TRUE"
                ($propstempconfig | where {$_.PropertyName -eq "Domain Include Local"}).Value1 = "TRUE"
            }
            if ($SearchLocalDomain -eq $false) {
                ($propstempcomponent | where {$_.PropertyName -eq "Domain Include Local"}).Value1 = "FALSE"
                ($propstempconfig | where {$_.PropertyName -eq "Domain Include Local"}).Value1 = "FALSE"
            }

            # Local DHCP search
            if ($SearchLocalDHCP -eq $true) {
                ($propstempcomponent | where {$_.PropertyName -eq "DHCP Include Local"}).Value1 = "TRUE"
                ($propstempconfig | where {$_.PropertyName -eq "DHCP Include Local"}).Value1 = "TRUE"
            }
            if ($SearchLocalDHCP -eq $false) {
                ($propstempcomponent | where {$_.PropertyName -eq "DHCP Include Local"}).Value1 = "FALSE"
                ($propstempconfig | where {$_.PropertyName -eq "DHCP Include Local"}).Value1 = "FALSE"
            }

            # SNMP max hops
            if ($SNMPMaxHops -ne $null) {
                ($propstempcomponent | where {$_.PropertyName -eq "Router Hop Count"}).Value1 = $SNMPMaxHops
                ($propstempconfig | where {$_.PropertyName -eq "Router Hop Count"}).Value1 = $SNMPMaxHops
            }

            # Set multiple options for network speed
            if ($SlowNetwork -eq $true) {
                ($propstempconfig | where {$_.PropertyName -eq "Network Speed"}).Value1 = "Slow"

                ($propstempcomponent | where {$_.PropertyName -eq "ICMP Ping Timeout"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "ICMP Ping Timeout - SLOW"}).Value1
                ($propstempconfig | where {$_.PropertyName -eq "ICMP Ping Timeout"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "ICMP Ping Timeout - SLOW"}).Value1

                ($propstempcomponent | where {$_.PropertyName -eq "Maximum Number Outstanding ICMP Pings"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "Maximum Number Outstanding ICMP Pings - SLOW"}).Value1 
                ($propstempconfig | where {$_.PropertyName -eq "Maximum Number Outstanding ICMP Pings"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "Maximum Number Outstanding ICMP Pings - SLOW"}).Value1 

                ($propstempcomponent | where {$_.PropertyName -eq "Number Concurrent Device Sessions"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "Number Concurrent Device Sessions - SLOW"}).Value1
                ($propstempconfig | where {$_.PropertyName -eq "Number Concurrent Device Sessions"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "Number Concurrent Device Sessions - SLOW"}).Value1

                ($propstempcomponent | where {$_.PropertyName -eq "SNMP Retry Count"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Count - SLOW"}).Value1
                ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Count"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Count - SLOW"}).Value1

                ($propstempcomponent | where {$_.PropertyName -eq "SNMP Retry Timeout"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Timeout - SLOW"}).Value1
                ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Timeout"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Timeout - SLOW"}).Value1

                if (($propstempconfig | where {$_.PropertyName -eq "Discovery Type"}).Value1 -ne "Topology") {
                    ($propstempcomponent | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval - SLOW"}).Value1
                    ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval - SLOW"}).Value1
                }
            }
            if ($SlowNetwork -eq $false) {
                ($propstempconfig | where {$_.PropertyName -eq "Network Speed"}).Value1 = "Fast"

                ($propstempcomponent | where {$_.PropertyName -eq "ICMP Ping Timeout"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "ICMP Ping Timeout - FAST"}).Value1
                ($propstempconfig | where {$_.PropertyName -eq "ICMP Ping Timeout"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "ICMP Ping Timeout - FAST"}).Value1

                ($propstempcomponent | where {$_.PropertyName -eq "Maximum Number Outstanding ICMP Pings"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "Maximum Number Outstanding ICMP Pings - FAST"}).Value1 
                ($propstempconfig | where {$_.PropertyName -eq "Maximum Number Outstanding ICMP Pings"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "Maximum Number Outstanding ICMP Pings - FAST"}).Value1 

                ($propstempcomponent | where {$_.PropertyName -eq "Number Concurrent Device Sessions"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "Number Concurrent Device Sessions - FAST"}).Value1
                ($propstempconfig | where {$_.PropertyName -eq "Number Concurrent Device Sessions"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "Number Concurrent Device Sessions - FAST"}).Value1

                ($propstempcomponent | where {$_.PropertyName -eq "SNMP Retry Count"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Count - FAST"}).Value1
                ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Count"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Count - FAST"}).Value1

                ($propstempcomponent | where {$_.PropertyName -eq "SNMP Retry Timeout"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Timeout - FAST"}).Value1
                ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Timeout"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "SNMP Retry Timeout - FAST"}).Value1

                if (($propstempconfig | where {$_.PropertyName -eq "Discovery Type"}).Value1 -ne "Topology") {
                    ($propstempcomponent | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval - FAST"}).Value1
                    ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval"}).Value1 = ($propstempconfig | where {$_.PropertyName -eq "NetToMediaTable Retrieval - FAST"}).Value1
                }
            }

            # Finally write changes back to the object
            $NetworkDiscoveryComponent.Props = $propstempcomponent
            $NetworkDiscoveryComponent.put()
            $NetworkDiscoveryConfig.Props = $propstempconfig
            $NetworkDiscoveryConfig.put()
        }
    }
}
# Method to set the default values for slow/fast network settings
Function Set-NetworkDiscoveryDefaults
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    Param (
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# Show the network discovery configuration defaults (as currently configured)
Function Get-NetworkDiscoveryDefaults
{
    [CmdletBinding()]
    Param (
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
# Subnets
Function Add-NetworkDiscoverySubnet
{
    # Add a new subnet, error if matching subnet already exists
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    # May also pass a subnet-type object via pipeline, these objects have the $Subnet, $Mask and $Search properties
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $OverrideUnique,
        [switch]
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $Subnet,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $Mask,
        [switch]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
            $Search = $true
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Search -eq $true) { $text = "$Subnet $Mask (Include in search)" }
        if ($Search -eq $false) { $text = "$Subnet $Mask (Exclude from search)" }
        if ($Force -or $pscmdlet.ShouldProcess($text)) {
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
            $NetworkDiscoveryConfig = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Configuration -Filter "ItemName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists
            $propslistconfig = $NetworkDiscoveryConfig.PropLists

            $plcomp_include   = ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Include"}).Values
            $plconfig_include = ($propslistconfig    | where {$_.PropertyListName -eq "Subnet Include"}).Values
            $plcomp_exclude   = ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Exclude"}).Values
            $plconfig_exclude = ($propslistconfig    | where {$_.PropertyListName -eq "Subnet Exclude"}).Values

            # Check uniqueness
            if (-not $OverrideUnique -and $plcomp_include -contains "$Subnet $Mask") {
                Write-Error "An included subnet with Value: `"$Subnet $Mask`" already exists! This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                # TODO ThrowTerminatingError
                return
            }
            if (-not $OverrideUnique -and $plcomp_exclude -contains "$Subnet $Mask") {
                Write-Error "An excluded subnet with Value: `"$Subnet $Mask`" already exists! This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                # TODO ThrowTerminatingError
                return
            }

            if ($Search -eq $true) {
                $plcomp_include += "$Subnet $Mask"
            } else {
                $plcomp_exclude += "$Subnet $Mask"
            }

            # Finally write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Include"}).Values = $plcomp_include
            ($propslistconfig    | where {$_.PropertyListName -eq "Subnet Include"}).Values = $plconfig_include
            ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Exclude"}).Values = $plcomp_exclude
            ($propslistconfig    | where {$_.PropertyListName -eq "Subnet Exclude"}).Values = $plconfig_exclude

            $NetworkDiscoveryComponent.Props = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null
            $NetworkDiscoveryConfig.Props = $propslistconfig
            $NetworkDiscoveryConfig.put() > $null

            # Return a subnet type object representing the subnet just added
            New-Object Object | 
                Add-Member NoteProperty Subnet $Subnet -PassThru | 
                Add-Member NoteProperty Mask $Mask -PassThru | 
                Add-Member NoteProperty Search $Search -PassThru | 
                Write-Output
        }
    }
}
Function Remove-NetworkDiscoverySubnet
{
    # Remove an existing subnet, warn if subnet doesn't exist
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $Subnet,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $Mask,
        [switch]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Search = $null
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess("$Subnet $Mask")) {
            # TODO
            # 1. Check if it already exists (optionally restrict search to Include/Exclude list)
            # 2. Confirm processing + proceed to remove
            # 3. Return subnet type object with properties of removed object (including list it was on)
        }
    }
}
Function Get-NetworkDiscoverySubnet
{
    # Return a collection of objects which represent the currently configured subnets
    # User can then filter/modify these using builtins, and pipe them to New/Remove
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
        # for each item in each list, create subnet type object and write it to output
        New-Object Object | 
            Add-Member NoteProperty Subnet $sn -PassThru | 
            Add-Member NoteProperty Mask $msk -PassThru | 
            Add-Member NoteProperty Search $srch -PassThru | 
            Write-Output
    }
}

# Domains
Function Add-NetworkDiscoveryDomain
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-NetworkDiscoveryDomain
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-NetworkDiscoveryDomain
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-NetworkDiscoveryDomain
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# SNMP Communities
Function Add-NetworkDiscoverySNMPCommunity
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-NetworkDiscoverySNMPCommunity
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-NetworkDiscoverySNMPCommunity
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-NetworkDiscoverySNMPCommunity
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# SNMP Devices
Function Add-NetworkDiscoverySNMPDevice
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-NetworkDiscoverySNMPDevice
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-NetworkDiscoverySNMPDevice
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-NetworkDiscoverySNMPDevice
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# DHCP Servers
Function Add-NetworkDiscoveryDHCP
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-NetworkDiscoveryDHCP
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-NetworkDiscoveryDHCP
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-NetworkDiscoveryDHCP
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
# Schedules
Function Add-NetworkDiscoverySchedule
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Remove-NetworkDiscoverySchedule
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
Function Get-NetworkDiscoverySchedule
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # TODO
    }
}
Function Set-NetworkDiscoverySchedule
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Force
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # TODO
        }
    }
}
