
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
    # Documentation notes:
    # Specify SiteCode if you want to override the default
    # Default SiteCode is either automatically detected as the local machine's SiteCode
    # or you can specify it globally using the $SCCMSiteCode environment variable
    #
    # Explicit specification of the $SiteCode parameter lets you, for example, delete a
    # Network Discovery Subnet from one site and add it to another, e.g.:
    #
    # Remove-NetworkDiscoverySubnet -SiteCode S01 -Subnet 10.10.0.0 -Mask 255.255.0.0 -Search Include | Add-NetworkDiscoverySubnet -SiteCode S02
    #
    # Or clone all subnets from one site to another:
    #
    # Get-NetworkDiscoverySubnet -SiteCode S01 | Add-NetworkDiscoverySubnet -SiteCode S02


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
        [string]
        [ValidateSet("Include", "Exclude")]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
            $Search = "Include"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Search -eq "Include") { $text = "$Subnet $Mask (Include in search)" }
        if ($Search -eq "Exclude") { $text = "$Subnet $Mask (Exclude from search)" }
        if ($Force -or $pscmdlet.ShouldProcess($text)) {
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
            # $NetworkDiscoveryConfig = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Configuration -Filter "ItemName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists
            # $propslistconfig = $NetworkDiscoveryConfig.PropLists

            $plcomp_include   = ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Include"}).Values
            $plcomp_exclude   = ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Exclude"}).Values
            # $plconfig_include = ($propslistconfig    | where {$_.PropertyListName -eq "Subnet Include"}).Values
            # $plconfig_exclude = ($propslistconfig    | where {$_.PropertyListName -eq "Subnet Exclude"}).Values

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

            if ($Search -eq "Include") { $plcomp_include += "$Subnet $Mask" }
            if ($Search -eq "Exclude") { $plcomp_exclude += "$Subnet $Mask" }

            # Finally write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Include"}).Values = $plcomp_include
            ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Exclude"}).Values = $plcomp_exclude
            # ($propslistconfig    | where {$_.PropertyListName -eq "Subnet Include"}).Values = $plconfig_include
            # ($propslistconfig    | where {$_.PropertyListName -eq "Subnet Exclude"}).Values = $plconfig_exclude

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null
            # $NetworkDiscoveryConfig.PropLists = $propslistconfig
            # $NetworkDiscoveryConfig.put() > $null

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
        [string]
        [ValidateSet("Both", "Include", "Exclude")]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Search = "Both"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # 1. Check if it already exists (optionally restrict search to Include/Exclude list)
        $existing = Get-NetworkDiscoverySubnet -SiteCode $SiteCode -Subnet $Subnet -Mask $Mask -Search $Search

        if ($existing -eq $null) {
            Write-Warning "The specified Network Discovery Subnet does not exist, and so cannot be deleted"
            # TODO ThrowTerminatingError
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Search -eq "Include") { $text = "$Subnet $Mask (Include in search)" }
        if ($Search -eq "Exclude") { $text = "$Subnet $Mask (Exclude from search)" }
        if ($Search -eq "Both") { $text = "$Subnet $Mask" }
        if ($Force -or $pscmdlet.ShouldProcess($text)) {
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists

            $plcomp_include   = ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Include"}).Values
            $plcomp_exclude   = ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Exclude"}).Values

            if ($Search -eq "Include" -or $Search -eq "Both") {
                $plcomp_include = $plcomp_include | where {$_ -ne "$Subnet $Mask"}
            }
            if ($Search -eq "Exclude" -or $Search -eq "Both") {
                $plcomp_exclude = $plcomp_exclude | where {$_ -ne "$Subnet $Mask"}
            }

            # Finally write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Include"}).Values = $plcomp_include
            ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Exclude"}).Values = $plcomp_exclude

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null

            # Return a subnet type object representing the object just removed
            $existing | Write-Output
        }
    }
}
Function Get-NetworkDiscoverySubnet
{
    # notes for help - any field may contain a * to do wildcard matching on the input field

    # Return a collection of objects which represent the currently configured subnets
    # User can then filter/modify these using builtins, and pipe them to New/Remove
    # Optionally filter by properties
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Subnet = "*",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Mask = "*",
        [string]
        [ValidateSet("Both", "Include", "Exclude")]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Search = "Both"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
        $propslistcomponent = $NetworkDiscoveryComponent.PropLists

        # 1. Look up all items which match the input parameters (or return all if no filtering requested)
        if ($Search -ne "Include") {
            $plcomp_exclude = ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Exclude"}).Values

            # Filter result set
            $plcomp_exclude = $plcomp_exclude | where {$_ -like "$Subnet $Mask"}

            # 2. Return subnet type object for each item
            foreach ($item in $plcomp_exclude) {
                if ($item -ne $null) {
                    New-Object Object | 
                        Add-Member NoteProperty Subnet $item.Split(" ")[0] -PassThru | 
                        Add-Member NoteProperty Mask $item.Split(" ")[1] -PassThru | 
                        Add-Member NoteProperty Search "Exclude" -PassThru | 
                        Write-Output
                }
            }
        }

        if ($Search -ne "Exclude") {
            $plcomp_include = ($propslistcomponent | where {$_.PropertyListName -eq "Subnet Include"}).Values

            # Filter result set
            $plcomp_include = $plcomp_include | where {$_ -like "$Subnet $Mask"}

            # 2. Return subnet type object for each item
            foreach ($item in $plcomp_include) {
                if ($item -ne $null) {
                    New-Object Object | 
                        Add-Member NoteProperty Subnet $item.Split(" ")[0] -PassThru | 
                        Add-Member NoteProperty Mask $item.Split(" ")[1] -PassThru | 
                        Add-Member NoteProperty Search "Include" -PassThru | 
                        Write-Output
                }
            }
        }
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $Domain,
        [string]
        [ValidateSet("Include", "Exclude")]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
            $Search = "Include"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Search -eq "Include") { $text = "$Domain (Include in search)" }
        if ($Search -eq "Exclude") { $text = "$Domain (Exclude from search)" }
        if ($Force -or $pscmdlet.ShouldProcess($text)) {
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists

            $plcomp_include   = ($propslistcomponent | where {$_.PropertyListName -eq "Domain Include"}).Values
            $plcomp_exclude   = ($propslistcomponent | where {$_.PropertyListName -eq "Domain Exclude"}).Values

            # Check uniqueness
            if (-not $OverrideUnique -and $plcomp_include -contains "$Domain") {
                Write-Error "An included domain with Value: `"$Domain`" already exists! This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                # TODO ThrowTerminatingError
                return
            }
            if (-not $OverrideUnique -and $plcomp_exclude -contains "$Domain") {
                Write-Error "An excluded domain with Value: `"$Domain`" already exists! This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                # TODO ThrowTerminatingError
                return
            }

            if ($Search -eq "Include") { $plcomp_include += "$Domain" }
            if ($Search -eq "Exclude") { $plcomp_exclude += "$Domain" }

            # Write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "Domain Include"}).Values = $plcomp_include
            ($propslistcomponent | where {$_.PropertyListName -eq "Domain Exclude"}).Values = $plcomp_exclude

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null

            # Return a domain type object representing the subnet just added
            New-Object Object | 
                Add-Member NoteProperty Domain $Domain -PassThru | 
                Add-Member NoteProperty Search $Search -PassThru | 
                Write-Output
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $Domain,
        [string]
        [ValidateSet("Both", "Include", "Exclude")]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Search = "Both"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # 1. Check if it already exists (optionally restrict search to Include/Exclude list)
        $existing = Get-NetworkDiscoveryDomain -SiteCode $SiteCode -Domain $Domain -Search $Search

        if ($existing -eq $null) {
            Write-Warning "The specified Network Discovery Domain does not exist, and so cannot be deleted"
            # TODO ThrowTerminatingError
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Search -eq "Include") { $text = "$Domain (Include in search)" }
        if ($Search -eq "Exclude") { $text = "$Domain (Exclude from search)" }
        if ($Search -eq "Both") { $text = "$Domain" }
        if ($Force -or $pscmdlet.ShouldProcess($text)) {
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists

            $plcomp_include = ($propslistcomponent | where {$_.PropertyListName -eq "Domain Include"}).Values
            $plcomp_exclude = ($propslistcomponent | where {$_.PropertyListName -eq "Domain Exclude"}).Values

            if ($Search -ne "Exclude") { $plcomp_include = $plcomp_include | where {$_ -notlike "$Domain"} }
            if ($Search -ne "Include") { $plcomp_exclude = $plcomp_exclude | where {$_ -notlike "$Domain"} }

            # Finally write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "Domain Include"}).Values = $plcomp_include
            ($propslistcomponent | where {$_.PropertyListName -eq "Domain Exclude"}).Values = $plcomp_exclude

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null

            # Return a subnet type object representing the object just removed
            $existing | Write-Output
        }
    }
}
Function Get-NetworkDiscoveryDomain
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Domain = "*",
        [string]
        [ValidateSet("Both", "Include", "Exclude")]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Search = "Both"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
        $propslistcomponent = $NetworkDiscoveryComponent.PropLists

        # 1. Look up all items which match the input parameters (or return all if no filtering requested)

        if ($Search -ne "Include") {
            $plcomp_exclude = ($propslistcomponent | where {$_.PropertyListName -eq "Domain Exclude"}).Values

            # Filter result set
            $plcomp_exclude = $plcomp_exclude | where {$_ -like "$Domain"}

            # 2. Return subnet type object for each item
            foreach ($item in $plcomp_exclude) {
                if ($item -ne $null) {
                    New-Object Object | 
                        Add-Member NoteProperty Domain $item -PassThru | 
                        Add-Member NoteProperty Search "Exclude" -PassThru | 
                        Write-Output
                }
            }
        }

        if ($Search -ne "Exclude") {
            $plcomp_include = ($propslistcomponent | where {$_.PropertyListName -eq "Domain Include"}).Values

            # Filter result set
            $plcomp_include = $plcomp_include | where {$_ -like "$Domain"}

            # 2. Return subnet type object for each item
            foreach ($item in $plcomp_include) {
                if ($item -ne $null) {
                    New-Object Object | 
                        Add-Member NoteProperty Domain $item -PassThru | 
                        Add-Member NoteProperty Search "Include" -PassThru | 
                        Write-Output
                }
            }
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $CommunityName
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess($CommunityName)) {
            # SNMP Community names are stored in two places (should be identical)
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
            $NetworkDiscoveryConfig = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Configuration -Filter "ItemName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists
            $propslistconfig = $NetworkDiscoveryConfig.PropLists

            $plcomp = ($propslistcomponent | where {$_.PropertyListName -eq "Community Names"}).Values
            $plconfig = ($propslistconfig | where {$_.PropertyListName -eq "Community Names"}).Values

            # Check uniqueness
            if (-not $OverrideUnique -and $plcomp -contains $CommunityName) {
                Write-Error "An SNMP Community with Name: `"$CommunityName`" already exists! This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                # TODO ThrowTerminatingError
                return
            }

            $plcomp += $CommunityName
            $plconfig += $CommunityName

            # Write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "Community Names"}).Values = $plcomp
            ($propslistconfig | where {$_.PropertyListName -eq "Community Names"}).Values = $plconfig

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null
            $NetworkDiscoveryConfig.PropLists = $propslistconfig
            $NetworkDiscoveryConfig.put() > $null

            # Return an SNMP community type object representing the subnet just added
            New-Object Object | 
                Add-Member NoteProperty CommunityName $CommunityName -PassThru | 
                Write-Output
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $CommunityName
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # 1. Check if it already exists
        $existing = Get-NetworkDiscoverySNMPCommunity -SiteCode $SiteCode -CommunityName $CommunityName

        if ($existing -eq $null) {
            Write-Warning "The specified Network Discovery SNMP Community Name does not exist, and so cannot be deleted"
            # TODO ThrowTerminatingError
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Force -or $pscmdlet.ShouldProcess($CommunityName)) {
            # SNMP Community names are stored in two places (should be identical)
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
            $NetworkDiscoveryConfig = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Configuration -Filter "ItemName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists
            $propslistconfig = $NetworkDiscoveryConfig.PropLists

            $plcomp = ($propslistcomponent | where {$_.PropertyListName -eq "Community Names"}).Values | where {$_ -ne $CommunityName}
            $plconfig = ($propslistconfig | where {$_.PropertyListName -eq "Community Names"}).Values | where {$_ -ne $CommunityName}

            # Finally write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "Community Names"}).Values = $plcomp
            ($propslistconfig | where {$_.PropertyListName -eq "Community Names"}).Values = $plconfig

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null
            $NetworkDiscoveryConfig.PropLists = $propslistconfig
            $NetworkDiscoveryConfig.put() > $null

            # Return a subnet type object representing the object(s) just removed
            $existing | Write-Output
        }
    }
}

# Filter (and save) a PropList
Function Filter-PropList
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropListName,
        $Filter
    )

    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter

    # Apply filter
    $proplists = $WmiObject.PropLists
    $proplist = ($proplists | where {$_.PropertyListName -eq $PropListName}).Values | where {$_ -ne $Filter}
    ($proplists | where {$_.PropertyListName -eq $PropListName}).Values = $proplist

    # Finally write changes back to the object
    $WmiObject.PropLists = $proplists
    $WmiObject.put() > $null
}

# Check if item exists in PropList
Function Item-IsInPropList
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropListName,
        $CheckItem
    )

    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter

    # Add item to proplist
    $proplists = $WmiObject.PropLists
    $proplist = ($proplists | where {$_.PropertyListName -eq $PropListName}).Values
    if ($plcomp -contains $CommunityName) {
        $true
    } else {
        $false
    }
}

# Append item to PropList
Function Add-ItemToPropList
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropListName,
        $NewItem
    )

    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter

    # Add item to proplist
    $proplists = $WmiObject.PropLists
    $proplist = ($proplists | where {$_.PropertyListName -eq $PropListName}).Values
    $proplist += $NewItem
    ($proplists | where {$_.PropertyListName -eq $PropListName}).Values = $proplist

    # Finally write changes back to the object
    $WmiObject.PropLists = $proplists
    $WmiObject.put() > $null
}

Function Get-NetworkDiscoverySNMPCommunity
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $CommunityName = "*",
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"

        # Obtain filtered result set
        $plcomp = ($NetworkDiscoveryComponent.PropLists | where {$_.PropertyListName -eq "Community Names"}).Values | where {$_ -like $CommunityName}

        foreach ($item in $plcomp) {
            if ($item -ne $null) {
                New-Object Object | 
                    Add-Member NoteProperty CommunityName $item -PassThru | 
                    Write-Output
            }
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $DeviceAddress
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess($DeviceAddress)) {
            # Check uniqueness
            if (-not $OverrideUnique -and (($Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress) -or ($Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress))) {
                Write-Error "An SNMP Device with address: `"$DeviceAddress`" already exists!"
                Write-Error "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                # TODO ThrowTerminatingError
                return
            }

            # SNMP Devices are stored in two places (should be identical)
            Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress
            Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress

            # Return an SNMP community type object representing the subnet just added
            New-Object Object | 
                Add-Member NoteProperty DeviceAddress $DeviceAddress -PassThru | 
                Write-Output
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $DeviceAddress
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # 1. Check if it already exists
        $existing = Get-NetworkDiscoverySNMPDevice -SiteCode $SiteCode -DeviceAddress $DeviceAddress

        if ($existing -eq $null) {
            Write-Warning "The specified Network Discovery SNMP Device does not exist, and so cannot be deleted"
            # TODO ThrowTerminatingError
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Force -or $pscmdlet.ShouldProcess($DeviceAddress)) {
            # SNMP Community names are stored in two places (should be identical)
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
            $NetworkDiscoveryConfig = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Configuration -Filter "ItemName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists
            $propslistconfig = $NetworkDiscoveryConfig.PropLists

            $plcomp = ($propslistcomponent | where {$_.PropertyListName -eq "Address Include"}).Values | where {$_ -ne $DeviceAddress}
            $plconfig = ($propslistconfig | where {$_.PropertyListName -eq "Address Include"}).Values | where {$_ -ne $DeviceAddress}

            # Finally write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "Address Include"}).Values = $plcomp
            ($propslistconfig | where {$_.PropertyListName -eq "Address Include"}).Values = $plconfig

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null
            $NetworkDiscoveryConfig.PropLists = $propslistconfig
            $NetworkDiscoveryConfig.put() > $null

            # Return a subnet type object representing the object(s) just removed
            $existing | Write-Output
        }
    }
}
Function Get-NetworkDiscoverySNMPDevice
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $DeviceAddress = "*",
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"

        # Obtain filtered result set
        $plcomp = ($NetworkDiscoveryComponent.PropLists | where {$_.PropertyListName -eq "Address Include"}).Values | where {$_ -like $DeviceAddress}

        foreach ($item in $plcomp) {
            if ($item -ne $null) {
                New-Object Object | 
                    Add-Member NoteProperty DeviceAddress $item -PassThru | 
                    Write-Output
            }
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $DHCPServer
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess($DHCPServer)) {
            # SNMP Devices are stored in two places (should be identical)
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
            $NetworkDiscoveryConfig = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Configuration -Filter "ItemName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists
            $propslistconfig = $NetworkDiscoveryConfig.PropLists

            $plcomp = ($propslistcomponent | where {$_.PropertyListName -eq "DHCP Include"}).Values
            $plconfig = ($propslistconfig | where {$_.PropertyListName -eq "DHCP Include"}).Values

            # Check uniqueness
            if (-not $OverrideUnique -and $plcomp -contains $CommunityName) {
                Write-Error "A DHCP server with address: `"$DHCPServer`" already exists! This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                # TODO ThrowTerminatingError
                return
            }

            $plcomp += $DHCPServer
            $plconfig += $DHCPServer

            # Write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "DHCP Include"}).Values = $plcomp
            ($propslistconfig | where {$_.PropertyListName -eq "DHCP Include"}).Values = $plconfig

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null
            $NetworkDiscoveryConfig.PropLists = $propslistconfig
            $NetworkDiscoveryConfig.put() > $null

            # Return an SNMP community type object representing the subnet just added
            New-Object Object | 
                Add-Member NoteProperty DHCPServer $DHCPServer -PassThru | 
                Write-Output
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
            $DHCPServer
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # 1. Check if it already exists
        $existing = Get-NetworkDiscoveryDHCP -SiteCode $SiteCode -DHCPServer $DHCPServer

        if ($existing -eq $null) {
            Write-Warning "The specified Network Discovery DHCP Server does not exist, and so cannot be deleted"
            # TODO ThrowTerminatingError
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Force -or $pscmdlet.ShouldProcess($DHCPServer)) {
            # SNMP Community names are stored in two places (should be identical)
            $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"
            $NetworkDiscoveryConfig = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Configuration -Filter "ItemName='SMS_NETWORK_DISCOVERY'"

            $propslistcomponent = $NetworkDiscoveryComponent.PropLists
            $propslistconfig = $NetworkDiscoveryConfig.PropLists

            $plcomp = ($propslistcomponent | where {$_.PropertyListName -eq "DHCP Include"}).Values | where {$_ -ne $DHCPServer}
            $plconfig = ($propslistconfig | where {$_.PropertyListName -eq "DHCP Include"}).Values | where {$_ -ne $DHCPServer}

            # Finally write changes back to the object
            ($propslistcomponent | where {$_.PropertyListName -eq "DHCP Include"}).Values = $plcomp
            ($propslistconfig | where {$_.PropertyListName -eq "DHCP Include"}).Values = $plconfig

            $NetworkDiscoveryComponent.PropLists = $propslistcomponent
            $NetworkDiscoveryComponent.put() > $null
            $NetworkDiscoveryConfig.PropLists = $propslistconfig
            $NetworkDiscoveryConfig.put() > $null

            # Return a subnet type object representing the object(s) just removed
            $existing | Write-Output
        }
    }
}
Function Get-NetworkDiscoveryDHCP
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $DHCPServer = "*",
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        $NetworkDiscoveryComponent = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_NETWORK_DISCOVERY'"

        # Obtain filtered result set
        $plcomp = ($NetworkDiscoveryComponent.PropLists | where {$_.PropertyListName -eq "DHCP Include"}).Values | where {$_ -like $DHCPServer}

        foreach ($item in $plcomp) {
            if ($item -ne $null) {
                New-Object Object | 
                    Add-Member NoteProperty DHCPServer $item -PassThru | 
                    Write-Output
            }
        }
    }
}

# Schedules
# Stored as a Property, not a PropertyList
# Property is a single string made by concatenating Schedule strings together
# (each schedule string is 16chars long, so you can split them up based on that)
# Should return Schedule objects, and take the same
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
    Process {
        # TODO
        # Read string, split into 16 character sections
        # Convert the supplied schedule into a string
        ## Compare against each of the split sections (uniqueness check)
        # If unique, add new schedule string to the end of the list
        # Write back
        ## Else prompt/error
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
    Process {
        # TODO
        # Read string, split into 16 character sections
        # Convert supplied schedule into a string
        ## Filter split sections based on input string to remove matching (exact match only)
        # Write back
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
    Process {
        # TODO
        # Read string, split into 16 character sections
        # Return either a list of all the schedules
        ## Or just a single match (exact match only)
        ### TODO extend this to permit matching based on schedule attributes?
    }
}
