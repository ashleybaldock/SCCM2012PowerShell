
# Functions associated with SCCM 2012 Discovery Methods


#######################
#  Utility Functions  #
#######################

# Return an array containing the elements of a PropList
Function Get-PropListValues
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropListName
    )
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    ($WmiObject.PropLists | where {$_.PropertyListName -eq $PropListName}).Values
}

# Set the values of the specified propslist
Function Set-PropListValues
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropListName,
        $PropListValues
    )

    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter

    # Add item to proplist
    $proplists = $WmiObject.PropLists
    ($proplists | where {$_.PropertyListName -eq $PropListName}).Values = $PropListValues

    # Finally write changes back to the object
    $WmiObject.PropLists = $proplists
    $WmiObject.put() > $null
}

# Remove the PropList specified entirely
Function Remove-PropList
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropListName
    )
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    $WmiObject.PropLists = [System.Management.ManagementBaseObject[]] ($proplists | where {$_.PropertyListName -ne $PropListName})
    $WmiObject.put() > $null
}

# Add a PropList
Function Add-PropList
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropListName,
        $PropListValues
    )
    $newprop = ([WMIClass] "$($WmiObjectNamespace):SMS_EmbeddedPropertyList").CreateInstance()
    $newprop.PropertyListName = $PropListName
    foreach ($item in $PropListValues) {
        $newprop.Values += $item
    }
    # Convert to base type to avoid errors
    $newprop = [System.Management.ManagementBaseObject] $newprop
    # Add new item
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    $WmiObject.PropLists += $newprop
    # Finally write changes back to the object
    $WmiObject.put() > $null
}

# Return $true if PropList specified exists, $false otherwise
Function Check-PropListExists
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropListName
    )
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    if (($WmiObject.PropLists | where {$_.PropertyListName -eq $PropListName}) -eq $null) {
        $false
    } else {
        $true
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

    $proplists = $WmiObject.PropLists
    $proplist = ($proplists | where {$_.PropertyListName -eq $PropListName}).Values
    if ($proplist -contains $CommunityName) {
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

# Get the current value of a Property
Function Get-WmiPropValue
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropName
    )
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    ($WmiObject.Props | where {$_.PropertyName -eq $PropName}).Value
}
# Get the current value of a Property
Function Get-WmiPropValue1
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropName
    )
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    ($WmiObject.Props | where {$_.PropertyName -eq $PropName}).Value1
}
# Get the current value of a Property
Function Get-WmiPropValue2
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropName
    )
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    ($WmiObject.Props | where {$_.PropertyName -eq $PropName}).Value2
}

# Set the current value of a Property
Function Set-WmiPropValue
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropName,
        $NewPropValue
    )
    $props = Get-WmiProps $WmiObjectNamespace $WmiObjectClass $WmiObjectFilter
    ($props | where {$_.PropertyName -eq $PropName}).Value = $NewPropValue
    Set-WmiProps $WmiObjectNamespace $WmiObjectClass $WmiObjectFilter $props
}
# Set the current value of a Property
Function Set-WmiPropValue1
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropName,
        $NewPropValue
    )
    $props = Get-WmiProps $WmiObjectNamespace $WmiObjectClass $WmiObjectFilter
    ($props | where {$_.PropertyName -eq $PropName}).Value1 = $NewPropValue
    Set-WmiProps $WmiObjectNamespace $WmiObjectClass $WmiObjectFilter $props
}
# Set the current value of a Property
Function Set-WmiPropValue2
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $PropName,
        $NewPropValue
    )
    $props = Get-WmiProps $WmiObjectNamespace $WmiObjectClass $WmiObjectFilter
    ($props | where {$_.PropertyName -eq $PropName}).Value2 = $NewPropValue
    Set-WmiProps $WmiObjectNamespace $WmiObjectClass $WmiObjectFilter $props
}

# Get the Props list associated with a Wmi object
Function Get-WmiProps
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter
    )
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    $WmiObject.Props
}

# Set the Props list associated with a Wmi object
Function Set-WmiProps
{
    Param (
        $WmiObjectNamespace,
        $WmiObjectClass,
        $WmiObjectFilter,
        $NewProps
    )
    $WmiObject = Get-WmiObject -Namespace $WmiObjectNamespace -Class $WmiObjectClass -Filter $WmiObjectFilter
    $WmiObject.Props = $NewProps
    $WmiObject.Put()
}


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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADForestDiscovery -SiteCode $SiteCode -Enabled "Yes" -Force
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADForestDiscovery -SiteCode $SiteCode -Enabled "No" -Force
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
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $Enabled = "Ignore",
        [string]
            $Schedule = "None",
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $CreateSiteBoundaries = "Ignore",
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $CreateSubnetBoundaries = "Ignore"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            # Basic settings
            if ($Enabled -eq "Yes") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_FOREST_DISCOVERY_MANAGER'" "SETTINGS" "ACTIVE"
            }
            if ($Enabled -eq "No") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_FOREST_DISCOVERY_MANAGER'" "SETTINGS" "INACTIVE"
            }
            if ($Schedule -ne "None") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_FOREST_DISCOVERY_MANAGER'" "Startup Schedule" $Schedule
            }

            # Site Boundary Creation
            if ($CreateSiteBoundaries -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_FOREST_DISCOVERY_MANAGER'" "Enable AD Site Boundary Creation" 1
            }
            if ($DiscoverDistributionGroups -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_FOREST_DISCOVERY_MANAGER'" "Enable AD Site Boundary Creation" 0
            }

            # Subnet Boundary Creation
            if ($CreateSubnetBoundaries -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_FOREST_DISCOVERY_MANAGER'" "Enable Subnet Boundary Creation" 1
            }
            if ($DiscoverDistributionGroups -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_FOREST_DISCOVERY_MANAGER'" "Enable Subnet Boundary Creation" 0
            }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADGroupDiscovery -SiteCode $SiteCode -Enabled "Yes" -Force
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADGroupDiscovery -SiteCode $SiteCode -Enabled "No" -Force
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
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $Enabled = "Ignore",
        [string]
            $FullSyncSchedule = "None",
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $DeltaEnabled = "Ignore",
        [int] # mins
        [ValidateRange(5,60)]
            $DeltaInterval = $null,
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $FilterExpiredLogons = "Ignore",
        [int] # days
        [ValidateRange(14,720)]
            $DaysSinceLastLogon = $null,
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $FilterExpiredPasswords = "Ignore",
        [int] # days
        [ValidateRange(30,720)]
            $DaysSinceLastPassword = $null,
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $DiscoverDistributionGroups = "Ignore"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }

        # If $DeltaInterval is not $null, create a new schedule object from it
        if ($DeltaInterval -ne $null) {
            # TODO explore the strings which SCCM creates to find what the other parameters ought to be
            #  set to (especially UTC/Unzoned)
            $td = Get-Date
            $DeltaInterval = New-IntervalString -Start $td -MinuteSpan $DeltaInterval
        }

        if ($Force -or $pscmdlet.ShouldProcess()) {
            # Basic settings
            if ($Enabled -eq "Yes") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "SETTINGS" "ACTIVE"
            }
            if ($Enabled -eq "No") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "SETTINGS" "INACTIVE"
            }
            if ($FullSyncSchedule -ne "None") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Full Sync Schedule" $FullSyncSchedule
            }

            # Delta discovery
            if ($DeltaEnabled -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Enable Incremental Sync" 1
            }
            if ($DeltaEnabled -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Enable Incremental Sync" 0
            }
            if ($DeltaInterval -ne $null) {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Startup Schedule" $DeltaInterval
            }

            # Last logon filter
            if ($FilterExpiredLogons -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Enable Filtering Expired Logon" 1
            }
            if ($FilterExpiredLogons -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Enable Filtering Expired Logon" 0
            }
            if ($DaysSinceLastLogon -ne $null) {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Days Since Last Logon" $DaysSinceLastLogon
            }

            # Machine account password expiry filter
            if ($FilterExpiredPasswords -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Enable Filtering Expired Password" 1
            }
            if ($FilterExpiredPasswords -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Enable Filtering Expired Password" 0
            }
            if ($DaysSinceLastPassword -ne $null) {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Days Since Last Password Set" $DaysSinceLastPassword
            }

            # Distribution group discovery
            if ($DiscoverDistributionGroups -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Discover DG Membership" 1
            }
            if ($DiscoverDistributionGroups -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Discover DG Membership" 0
            }
        }
    }
}


# System/User discovery

# DName: LDAP distinguished name
# Recursive: Yes or No
# DiscoverGroups: Yes or No
# Account: string


# Same object type can be used for AD Group, System and User discovery

# Name: Any, but unique
# Type: Location OR Group (Ignored for System/User discovery)
# Recursion: Yes or No (Location/System/User discovery only
# Account: string
# SearchBase(s): One or more LDAP paths
Function Add-ADGroupDiscoveryScope
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
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
            $Name,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Location", "Group")]
            $Type,
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Yes", "No")]
            $Recursion,
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Account = "",
        [string]
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
            $SearchBase
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }

        if ($Account -ne "") {
            Write-Warning "Setting Account information for new Group Discovery Scopes is not yet supported!"
            Write-Error "Not Implemented Yet"
            return
        }

        # Check that scope with name exists (else we can't modify it)
        $existing = Get-ADGroupDiscoveryScope -SiteCode $SiteCode -Name $Name -Exact

        if ($existing -ne $null) {
            Write-Warning "An AD Group Discovery Scope with the same name exists, this parameter must be unique! If you want to modify the existing item use Set-ADGroupDiscoveryScope"
            Write-Error "Duplicate item exists"
            return
        }

        if ($Force -or $pscmdlet.ShouldProcess($Name)) {
            $propvals = Get-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Containers"

            $propvals += $Name

            # Type setting
            if ($Type -eq "Location") { $propvals += 0 }
            if ($Type -eq "Group") { $propvals += 1 }
            # Recursion setting
            if ($Recursion -eq "Yes") { $propvals += 0 }
            if ($Recursion -eq "No") { $propvals += 1 }
            # And one more item
            $propvals += 1

            Set-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Containers" $propvals

            # Account setting
            if ($Account -eq "") {
                if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)") -eq $true) {
                    Remove-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)"
                }
            } else {
                if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)") -eq $true) {
                    Set-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)" $Account
                } else {
                    Add-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)" $Account
                }
            }

            # Search Base setting
            if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($Name)") -eq $true) {
                Set-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($Name)" $SearchBase
            } else {
                Add-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($Name)" $SearchBase
            }
        }
    }
}

Function Remove-ADGroupDiscoveryScope
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
            $Name
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }

        $existing = Get-ADGroupDiscoveryScope -SiteCode $SiteCode -Name $Name -Exact

        if ($existing -eq $null) {
            Write-Warning "The specified AD Group Discovery Scope does not exist, and so cannot be deleted"
            Write-Error "Item not found"
            return
        }

        if ($Force -or $pscmdlet.ShouldProcess($Name)) {
            # TODO
            # Create an object for each one
            # Filter the objects
            $propvals = Get-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Containers"

            $propvalsout = @()
            $ind = 0

            # Filter matching items (and the 3 properties which follow the key)
            while ($sub = $propvals[$ind..($ind + 3)]) {
                if ($sub[0] -ne $Name) {
                    foreach ($item in $sub) {
                        $propvalsout += $item
                    }
                }
                $ind += 4
            }

            # Remove other proplists if needed
            if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)") -eq $true) {
                Remove-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)"
            }

            if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($Name)") -eq $true) {
                Remove-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($Name)"
            }

            Set-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Containers" $propvalsout

        }
    }
}

# Search for scopes based on their parameters
Function Get-ADGroupDiscoveryScope
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $Exact,
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Name = "*",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Location", "Group", "*")]
            $Type = "*",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Yes", "No", "*")]
            $Recursion = "*",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Account = "*",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $SearchBase = "*"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # TODO

        # Create an object for each one
        # Filter the objects
        $propvals = Get-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Containers"

        # Returns the item requested and its properties
        #$propvals[[array]::IndexOf($propvals, $Name)..3]

        $objects = @()

        $ind = 0

        # Build list of objects
        while ($sub = $propvals[$ind..($ind + 3)]) {
            $obj = New-Object Object | Add-Member NoteProperty Name $sub[0] -PassThru

            if ($sub[1] -eq 0) {
                $obj = $obj | Add-Member NoteProperty Type "Location" -PassThru
            } else {
                $obj = $obj | Add-Member NoteProperty Type "Group" -PassThru
            }
            if ($sub[2] -eq 0) {
                $obj = $obj | Add-Member NoteProperty Recursion "Yes" -PassThru
            } else {
                $obj = $obj | Add-Member NoteProperty Recursion "No" -PassThru
            }

            if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($obj.Name)") -eq $true) {
                $obj = $obj | Add-Member NoteProperty Account (Get-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($obj.Name)") -PassThru
            } else {
                $obj = $obj | Add-Member NoteProperty Account "" -PassThru
            }

            if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($obj.Name)") -eq $true) {
                $searchbases = Get-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($obj.Name)"
                $obj = $obj | Add-Member NoteProperty SearchBase $searchbases -PassThru
            } else {
                $obj = $obj | Add-Member NoteProperty SearchBase "" -PassThru
            }

            $objects += $obj
            $ind += 4
        }

        # Next filter objects by input parameters + return

        if ($Exact -eq $true) {
            $objects | where {$_.Name -eq $Name}
        } else {
            $objects | where {$_.Name -like $Name} |
                       where {$_.Type -like $Type} |
                       where {$_.Recursion -like $Recursion} |
                       where {$_.Account -like $Account} |
                       where {$_.SearchBase -like $SearchBase}
        }
    }
}

# Modify the Group Discovery Scope with specified Name, setting properties
Function Set-ADGroupDiscoveryScope
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
            $Name,
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Location", "Group", "Ignore")]
            $Type = "Ignore",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Yes", "No", "Ignore")]
            $Recursion = "Ignore",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Account = "Ignore",
        [string[]]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $SearchBase = "Ignore"
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # Check for non-implemented setting
        if ($Account -ne "Ignore") {
            Write-Warning "Setting Account information for Group Discovery Scopes is not yet supported!"
            Write-Error "Not Implemented Yet"
            return
        }

        # Check that scope with name exists (else we can't modify it)
        $existing = Get-ADGroupDiscoveryScope -SiteCode $SiteCode -Name $Name -Exact

        if ($existing -eq $null) {
            Write-Warning "The specified AD Group Discovery Scope does not exist, and so cannot be modified - try the Add-ADGroupDiscoveryScope command instead"
            Write-Error "Item not found"
            return
        }

        if ($Force -or $pscmdlet.ShouldProcess($Name)) {
            $propvals = Get-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Containers"
            # Modify properties as needed
            # Get proplist, lookup name index, offset + modify, write proplist back

            # Type setting
            if ($Type -eq "Location") {
                $propvals[[array]::IndexOf($propvals, $Name) + 1] = 0
            }
            if ($Type -eq "Group") {
                $propvals[[array]::IndexOf($propvals, $Name) + 1] = 1
            }
            # Recursion setting
            if ($Recursion -eq "Yes") {
                $propvals[[array]::IndexOf($propvals, $Name) + 2] = 0
            }
            if ($Recursion -eq "No") {
                $propvals[[array]::IndexOf($propvals, $Name) + 2] = 1
            }

            Set-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Containers" $propvals

            # Account setting
            if ($Account -ne "Ignore") {
                # TODO - check if account exists (need to find out where these are stored...)
                if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)") -eq $true) {
                    Set-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)" $Account
                } else {
                    Add-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "AD Accounts:$($Name)" $Account
                }
            }

            # Search Base setting
            if ($SearchBase -ne "Ignore") {
                if ((Check-PropListExists "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($Name)") -eq $true) {
                    Set-PropListValues "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($Name)" $SearchBase
                } else {
                    Add-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Search Bases:$($Name)" $SearchBase
                }
            }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADSystemDiscovery -SiteCode $SiteCode -Enabled "Yes" -Force
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADSystemDiscovery -SiteCode $SiteCode -Enabled "No" -Force
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
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $Enabled = "Ignore",
        [string]
            $FullSyncSchedule = "None",
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $DeltaEnabled = "Ignore",
        [int] # mins
        [ValidateRange(5,60)]
            $DeltaInterval = $null,
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $FilterExpiredLogons = "Ignore",
        [int] # days
        [ValidateRange(14,720)]
            $DaysSinceLastLogon = $null,
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $FilterExpiredPasswords = "Ignore",
        [int] # days
        [ValidateRange(30,720)]
            $DaysSinceLastPassword = $null
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }

        # If $DeltaInterval is not $null, create a new schedule object from it
        if ($DeltaInterval -ne $null) {
            # TODO explore the strings which SCCM creates to find what the other parameters ought to be
            #  set to (especially UTC/Unzoned)
            $td = Get-Date
            $DeltaInterval = New-IntervalString -Start $td -MinuteSpan $DeltaInterval
        }

        if ($Force -or $pscmdlet.ShouldProcess()) {
            # Basic settings
            if ($Enabled -eq "Yes") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "SETTINGS" "ACTIVE"
            }
            if ($Enabled -eq "No") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "SETTINGS" "INACTIVE"
            }
            if ($FullSyncSchedule -ne "None") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Full Sync Schedule" $FullSyncSchedule
            }

            # Delta discovery
            if ($DeltaEnabled -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Enable Incremental Sync" 1
            }
            if ($DeltaEnabled -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Enable Incremental Sync" 0
            }
            if ($DeltaInterval -ne $null) {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Startup Schedule" $DeltaInterval
            }

            # Last logon filter
            if ($FilterExpiredLogons -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Enable Filtering Expired Logon" 1
            }
            if ($FilterExpiredLogons -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Enable Filtering Expired Logon" 0
            }
            if ($DaysSinceLastLogon -ne $null) {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Days Since Last Logon" $DaysSinceLastLogon
            }

            # Machine account password expiry filter
            if ($FilterExpiredPasswords -eq "Yes") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Enable Filtering Expired Password" 1
            }
            if ($FilterExpiredPasswords -eq "No") {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Enable Filtering Expired Password" 0
            }
            if ($DaysSinceLastPassword -ne $null) {
                Set-WmiPropValue "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" "Days Since Last Password Set" $DaysSinceLastPassword
            }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADUserDiscovery -SiteCode $SiteCode -Enabled "Yes" -Force
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-ADUserDiscovery -SiteCode $SiteCode -Enabled "No" -Force
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
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $Enabled = "Ignore",
        [string]
            $FullSyncSchedule = "None",
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $DeltaEnabled = "Ignore",
        [int] # mins
        [ValidateRange(5,60)]
            $DeltaInterval = $null
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }

        # If $DeltaInterval is not $null, create a new schedule object from it
        if ($DeltaInterval -ne $null) {
            # TODO explore the strings which SCCM creates to find what the other parameters ought to be
            #  set to (especially UTC/Unzoned)
            $td = Get-Date
            $DeltaInterval = New-IntervalString -Start $td -MinuteSpan $DeltaInterval
        }

        if ($Force -or $pscmdlet.ShouldProcess()) {
            # Basic settings
            if ($Enabled -eq "Yes") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "SETINGS" "ACTIVE"
            }
            if ($Enabled -eq "No") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "SETINGS" "INACTIVE"
            }
            if ($FullSyncSchedule -ne "None") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Full Sync Schedule" $FullSyncSchedule
            }

            # Delta discovery
            if ($DeltaEnabled -eq "Yes") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Enable Incremental Sync" 1
            }
            if ($DeltaEnabled -eq "No") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Enable Incremental Sync" 0
            }
            if ($DeltaInterval -ne $null) {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'" "Startup Schedule" $DeltaInterval
            }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-HeartbeatDiscovery -SiteCode $SiteCode -Enabled "Yes" -Force
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-HeartbeatDiscovery -SiteCode $SiteCode -Enabled "No" -Force
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
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $Enabled = "Ignore",
        [string]
            $Schedule = "None"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {

            # First configure schedule under SMS_SCI_Component -> ComponentName='SMS_SITE_CONTROL_MANAGER'
            if ($Schedule -ne "None") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" -Class SMS_SCI_Component -Filter "ComponentName='SMS_SITE_CONTROL_MANAGER'" "Heartbeat Site Control File Schedule" $Schedule
            }

            # Second configure under SMS_SCI_ClientConfig -> ItemName='Client Properties'
            if ($Enabled -eq "Yes") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_ClientConfig "ItemName='Client Properties'" "Enable Heartbeat DDR" 1
            }
            if ($Enabled -eq "No") {
                Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_ClientConfig "ItemName='Client Properties'" "Enable Heartbeat DDR" 0
            }
            if ($Schedule -ne "None") {
                Set-WmiPropValue2 "root\SMS\site_$($SiteCode)" SMS_SCI_ClientConfig "ItemName='Client Properties'" "DDR Refresh Interval" $Schedule
            }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-NetworkDiscovery -SiteCode $SiteCode -Enabled "Yes" -Force
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            Set-NetworkDiscovery -SiteCode $SiteCode -Enabled "No" -Force
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
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $Enabled = "Ignore",
        [ValidateCount(0,1)]
        [ValidateSet("Topology", "TopologyAndClient", "ToplologyClientAndOS")]
            $Type = "None",
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $SlowNetwork = "Ignore",
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $SearchLocalSubnets = "Ignore",
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $SearchLocalDomain = "Ignore",
        [int]
        [ValidateRange(0,10)]
            $SNMPMaxHops = -1,
        [string]
        [ValidateCount(0,1)]
        [ValidateSet("Yes", "No", "Ignore")]
            $SearchLocalDHCP = "Ignore"
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        if ($Force -or $pscmdlet.ShouldProcess()) {
            $propstempcomponent = Get-WmiProps "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'"
            $propstempconfig = Get-WmiProps "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'"

            # Set enabled (may be null)
            if ($Enabled -eq "Yes") {
                ($propstempcomponent | where {$_.PropertyName -eq "Discovery Enabled"}).Value1 = "TRUE"
                ($propstempconfig | where {$_.PropertyName -eq "Discovery Enabled"}).Value1 = "TRUE"
            }
            if ($Enabled -eq "No") {
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
            if ($SearchLocalSubnets -eq "Yes") {
                ($propstempcomponent | where {$_.PropertyName -eq "Subnet Include Local"}).Value1 = "TRUE"
                ($propstempconfig | where {$_.PropertyName -eq "Subnet Include Local"}).Value1 = "TRUE"
            }
            if ($SearchLocalSubnets -eq "No") {
                ($propstempcomponent | where {$_.PropertyName -eq "Subnet Include Local"}).Value1 = "FALSE"
                ($propstempconfig | where {$_.PropertyName -eq "Subnet Include Local"}).Value1 = "FALSE"
            }

            # Local domain search
            if ($SearchLocalDomain -eq "Yes") {
                ($propstempcomponent | where {$_.PropertyName -eq "Domain Include Local"}).Value1 = "TRUE"
                ($propstempconfig | where {$_.PropertyName -eq "Domain Include Local"}).Value1 = "TRUE"
            }
            if ($SearchLocalDomain -eq "No") {
                ($propstempcomponent | where {$_.PropertyName -eq "Domain Include Local"}).Value1 = "FALSE"
                ($propstempconfig | where {$_.PropertyName -eq "Domain Include Local"}).Value1 = "FALSE"
            }

            # Local DHCP search
            if ($SearchLocalDHCP -eq "Yes") {
                ($propstempcomponent | where {$_.PropertyName -eq "DHCP Include Local"}).Value1 = "TRUE"
                ($propstempconfig | where {$_.PropertyName -eq "DHCP Include Local"}).Value1 = "TRUE"
            }
            if ($SearchLocalDHCP -eq "No") {
                ($propstempcomponent | where {$_.PropertyName -eq "DHCP Include Local"}).Value1 = "FALSE"
                ($propstempconfig | where {$_.PropertyName -eq "DHCP Include Local"}).Value1 = "FALSE"
            }

            # SNMP max hops
            if ($SNMPMaxHops -gt -1) {
                ($propstempcomponent | where {$_.PropertyName -eq "Router Hop Count"}).Value1 = $SNMPMaxHops
                ($propstempconfig | where {$_.PropertyName -eq "Router Hop Count"}).Value1 = $SNMPMaxHops
            }

            # Set multiple options for network speed
            if ($SlowNetwork -eq "Yes") {
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
            if ($SlowNetwork -eq "No") {
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

            # Finally write changes back to WMI
            Set-WmiProps "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" $propstempcomponent
            Set-WmiProps "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" $propstempconfig
        }
    }
}
# Method to set the default values for slow/fast network settings
Function Set-NetworkDiscoveryDefaults
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    Param (
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
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
            # Check uniqueness
            if (-not $OverrideUnique -and (Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Subnet Include" "$Subnet $Mask")) {
                Write-Warning "An included subnet with Value: `"$Subnet $Mask`" already exists!"
                Write-Warning "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                Write-Error "Duplicate item found"
                return
            }
            if (-not $OverrideUnique -and (Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Subnet Exclude" "$Subnet $Mask")) {
                Write-Warning "An excluded subnet with Value: `"$Subnet $Mask`" already exists!"
                Write-Warning "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                Write-Error "Duplicate item found"
                return
            }

            if ($Search -eq "Include") {
                Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Address Include" "$Subnet $Mask"
            }
            if ($Search -eq "Exclude") {
                Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Address Include" "$Subnet $Mask"
            }

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
            Write-Error "Item not found"
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Search -eq "Include") { $text = "$Subnet $Mask (Include in search)" }
        if ($Search -eq "Exclude") { $text = "$Subnet $Mask (Exclude from search)" }
        if ($Search -eq "Both") { $text = "$Subnet $Mask" }
        if ($Force -or $pscmdlet.ShouldProcess($text)) {
            if ($Search -ne "Exclude") {
                Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Subnet Include" "$Subnet $Mask"
            }
            if ($Search -ne "Include") {
                Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Subnet Exclude" "$Subnet $Mask"
            }

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
            $OverrideUnique,
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
            # Check uniqueness
            if (-not $OverrideUnique -and (Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Domain Include" $Domain)) {
                Write-Warning "An included domain with Value: `"$Domain`" already exists!"
                Write-Warning "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                Write-Error "Duplicate item found"
                return
            }

            if (-not $OverrideUnique -and (Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Domain Exclude" $Domain)) {
                Write-Warning "An excluded domain with Value: `"$Domain`" already exists!"
                Write-Warning "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                Write-Error "Duplicate item found"
                return
            }

            if ($Search -eq "Include") {
                Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Domain Include" $Domain
            }
            if ($Search -eq "Exclude") {
                Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Domain Exclude" $Domain
            }

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
            Write-Error "Item not found"
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Search -eq "Include") { $text = "$Domain (Include in search)" }
        if ($Search -eq "Exclude") { $text = "$Domain (Exclude from search)" }
        if ($Search -eq "Both") { $text = "$Domain" }
        if ($Force -or $pscmdlet.ShouldProcess($text)) {
            if ($Search -ne "Exclude") {
                Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Domain Include" $Domain
            }
            if ($Search -ne "Include") {
                Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Domain Exclude" $Domain
            }

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
            $OverrideUnique,
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
            # Check uniqueness
            if (-not $OverrideUnique -and ((Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Community Name" $DeviceAddress) -or (Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Community Name" $DeviceAddress))) {
                Write-Warning "An SNMP Community with Name: `"$CommunityName`" already exists!"
                Write-Warning "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                Write-Error "Duplicate item found"
                return
            }

            # SNMP Community names are stored in two places (should be identical)
            Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Community Name" $DeviceAddress
            Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Community Name" $DeviceAddress

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
            Write-Error "Item not found"
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Force -or $pscmdlet.ShouldProcess($CommunityName)) {
            # Stored in two places (should be identical)
            Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Community Name" $DeviceAddress
            Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Community Name" $DeviceAddress

            # Return a subnet type object representing the object(s) just removed
            $existing | Write-Output
        }
    }
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
            $CommunityName = "*"
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
            $OverrideUnique,
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
            if (-not $OverrideUnique -and ((Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress) -or (Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress))) {
                Write-Warning "An SNMP Device with address: `"$DeviceAddress`" already exists!"
                Write-Warning "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                Write-Error "Duplicate item found"
                return
            }

            # Stored in two places (should be identical)
            Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress
            Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress

            # Return object representing the item just added
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
            Write-Error "Item not found"
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Force -or $pscmdlet.ShouldProcess($DeviceAddress)) {
            # Stored in two places (should be identical)
            Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress
            Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Address Include" $DeviceAddress

            # Return object(s) representing the item(s) just removed
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
            $DeviceAddress = "*"
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
            $OverrideUnique,
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
            # Check uniqueness
            if (-not $OverrideUnique -and ((Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "DHCP Include" $DeviceAddress) -or (Item-IsInPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "DHCP Include" $DeviceAddress))) {
                Write-Warning "A DHCP server with address: `"$DHCPServer`" already exists!"
                Write-Warning "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                Write-Error "Duplicate item found"
                return
            }

            # Stored in two places (should be identical)
            Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "DHCP Include" $DeviceAddress
            Add-ItemToPropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "DHCP Include" $DeviceAddress

            # Return object representing the item just added
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
            Write-Error "Item not found"
            return
        }

        # 2. Confirm processing + proceed to remove
        if ($Force -or $pscmdlet.ShouldProcess($DHCPServer)) {
            # SNMP Community names are stored in two places (should be identical)
            Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "DHCP Include" $DeviceAddress
            Filter-PropList "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "DHCP Include" $DeviceAddress

            # Return object(s) representing the item(s) just removed
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
            $DHCPServer = "*"
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
Function Split-NetworkDiscoveryScheduleString
{
    Param (
        $SchedString
    )

    # Split string into 16 character sections
    $sched_array = @()
    $sched_array += $SchedString.Substring(0, 16)
    while ($SchedString = $SchedString.Substring(16)) {
        $sched_array += $SchedString.Substring(0, 16)
    }
    $sched_array
}

Function Add-NetworkDiscoverySchedule
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [switch]
            $OverrideUnique,
        [switch]
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()] 
            $Schedule
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # TODO
        if ($Force -or $pscmdlet.ShouldProcess($Schedule)) {
            $sched = Get-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Startup Schedule"
            $sched += Get-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Startup Schedule"

            # Split schedule strings up
            $sched_array = Split-NetworkDiscoveryScheduleString $sched

            # Ensure no duplicates
            $sched_array = $sched_array | select -uniq

            # Error if item already exists
            if (-not $OverrideUnique -and $sched_array -contains $Schedule) {
                Write-Warning "A Schedule with text: `"$Schedule`" already exists!"
                Write-Warning "This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                Write-Error "Duplicate item found"
                return
            }

            $sched_array += $Schedule
            $sched = [string]::Join("", $sched_array)

            # Update fields + write back
            Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Startup Schedule" $sched
            Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Startup Schedule" $sched

            # Write out added object
            $Schedule | Write-Output
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
            $Force,
        [string]
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()] 
            $Schedule
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # TODO
        # Read string, split into 16 character sections
        # Convert supplied schedule into a string
        ## Filter split sections based on input string to remove matching (exact match only)
        # Write back

        $existing = Get-NetworkDiscoverySchedule -SiteCode $SiteCode -Schedule $Schedule -Exact

        if ($existing -eq $null) {
            Write-Warning "The specified Schedule does not exist, and so cannot be deleted"
            Write-Error "Item not found"
            return
        }

        if ($Force -or $pscmdlet.ShouldProcess($Schedule)) {
            $sched = Get-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Startup Schedule"
            $sched += Get-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Startup Schedule"

            # Split schedule strings up
            $sched_array = Split-NetworkDiscoveryScheduleString $sched

            # Ensure no duplicates
            $sched_array = ($sched_array | select -uniq)

            # Filter results by input
            $sched_array = ($sched_array | where {$_ -ne $Schedule})

            $sched = [string]::Join("", $sched_array)

            # Update fields + write back
            Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Startup Schedule" $sched > $null
            Set-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Startup Schedule" $sched > $null

            # Return the schedule deleted (TODO - return schedule object)
            $existing | Write-Output
        }
    }
}
Function Get-NetworkDiscoverySchedule
{
    [CmdletBinding()]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
            $Schedule = "*",
        [switch]
            $Exact
    )
    Process {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
        # If schedule is not a string (assume schedule object) turn it into a string
        if ($Schedule.GetType().Name -ne "String") {
            # TODO
        }

        # Stored in two places (which should be identical!)
        $sched = Get-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Component "ComponentName='SMS_NETWORK_DISCOVERY'" "Startup Schedule"
        $sched += Get-WmiPropValue1 "root\SMS\site_$($SiteCode)" SMS_SCI_Configuration "ItemName='SMS_NETWORK_DISCOVERY'" "Startup Schedule"

        # Read string, split into 16 character sections
        if ($sched -eq "") {
            # Empty, nothing to do
            return
        } else {
            # Split schedule strings up
            $sched_array = Split-NetworkDiscoveryScheduleString $sched

            # Ensure no duplicates
            $sched_array = $sched_array | select -uniq

            # Filter results by input
            if ($Exact) {
                $sched_array = $sched_array | where {$_ -eq $Schedule}
            } else {
                $sched_array = $sched_array | where {$_ -like $Schedule}
            }

            foreach ($item in $sched_array) {
                # TODO return schedule objects
                $item | Write-Output
            }
        }
    }
}
