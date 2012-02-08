
# Functions associated with SCCM 2012 Boundaries and Boundary Groups

# All methods should return an array of Boundary/BoundaryGroup objects
# All methods accept either an array or a single Boundary/BoundaryGroup/SiteSystem object for arguments which accept them

# TODO - Specify site codes via environment variable?

# Returns an array of Boundary objects (may only contain one)
# Multiple arguments can be supplied to filter the returned Boundaries
Function Get-Boundary
{
    [CmdletBinding()]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [string[]]
        [alias("Name", "Names", "DisplayNames")]
            $DisplayName,
        [string[]]
        [alias("Values")]
            $Value,
        [string[]]
        [alias("Type", "Types", "BoundaryTypes")]
        [ValidateSet("IPSubnet", "ADSite", "IPv6Prefix", "IPRange")]
            $BoundaryType,
        [System.Management.ManagementObject[]]
        [alias("BoundaryGroups")]
        [parameter(ValueFromPipeLine = $true)]
            $BoundaryGroup
        # TODO Filter by DefaultSiteCode
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        $Filter = @()

        # Build query out of arguments (default return ALL Boundaries)
        if ($BoundaryGroup -ne $null) {
            $temp = @()
            foreach ($BG in $BoundaryGroup) {
                $BGFilter = "GroupID='$($BG.GroupID)'"
                Write-Debug "Filter is: $BGFilter"
                $result = Get-WmiObject -Namespace "root\SMS\site_D71" -Class SMS_BoundaryGroupMembers -Filter $BGFilter
                # TODO - This will give duplicates!
                if ($result -ne $null) {
                    foreach ($j in $result) { $temp += "BoundaryID='$($j.BoundaryID)'" }
                }
            }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") {
                $Filter += "($temp)"
            } else {
                Write-Debug "BoundaryGroup(s) specified, but none contained Boundaries - no match possible"
                return
            }
        }

        if ($DisplayName -ne $null) {
            $temp = @()
            foreach ($DN in $DisplayName) { $temp += "DisplayName='$DN'" }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") { $Filter += "($temp)" }
        }

        if ($Value -ne $null) {
            $temp = @()
            foreach ($Val in $Value) { $temp += "Value='$Val'" }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") { $Filter += "($temp)" }
        }

        if ($BoundaryType -ne $null) {
            $temp = @()
            foreach ($BT in $Type) {
                switch($BT) {
                    "IPSubnet"   { $temp += "BoundaryType='0'" ; break }
                    "ADSite"     { $temp += "BoundaryType='1'" ; break }
                    "IPv6Prefix" { $temp += "BoundaryType='2'" ; break }
                    "IPRange"    { $temp += "BoundaryType='3'" ; break }
                }
            }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") { $Filter += "($temp)" }
        }

        if ($DefaultSiteCode -ne $null) {
            $temp = @()
            foreach ($DSC in $DefaultSiteCode) { $temp += "DefaultSiteCode='$DSC'" }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") { $Filter += "($temp)" }
        }

        $Filter = [string]::join(" and ", $Filter)

        Write-Debug "Filter is: $Filter"

        # Look up WMI objects
        Get-WmiObject -Namespace "root\SMS\site_D71" -Class SMS_Boundary -Filter $Filter | Write-Output
    }
}


# Returns an array of BoundaryGroup objects (may only contain one)
Function Get-BoundaryGroup
{
    [CmdletBinding()]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",
        [string[]]
        [alias("Names")]
            $Name,
        [string[]]
        [alias("Descriptions")]
            $Description,
        [string[]]
        [alias("DefaultSiteCodes")]
            $DefaultSiteCode,
        [System.Management.ManagementObject[]]
        [alias("Boundaries")]
        [parameter(ValueFromPipeLine = $true)]
            $Boundary
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        $Filter = @()

        # Build query out of arguments (default return ALL BoundaryGroups)
        if ($Boundary -ne $null) {
            $temp = @()
            foreach ($Bound in $Boundary) {
                $BFilter = "BoundaryID='$($Bound.BoundaryID)'"
                Write-Debug "Filter is: $BFilter"
                $result = Get-WmiObject -Namespace "root\SMS\site_D71" -Class SMS_BoundaryGroupMembers -Filter $BFilter
                # TODO - This will give duplicates!
                if ($result -ne $null) {
                    foreach ($j in $result) { $temp += "GroupID='$($j.GroupID)'" }
                }
            }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") {
                $Filter += "($temp)"
            } else {
                Write-Debug "Boundary specified, but none contained in any boundary groups - no match possible"
                return
            }
        }

        if ($Name -ne $null) {
            $temp = @()
            foreach ($N in $Name) { $temp += "Name='$N'" }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") { $Filter += "($temp)" }
        }

        if ($Description -ne $null) {
            $temp = @()
            foreach ($Desc in $Description) { $temp += "Description='$Desc'" }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") { $Filter += "($temp)" }
        }

        if ($DefaultSiteCode -ne $null) {
            $temp = @()
            foreach ($DSC in $DefaultSiteCode) { $temp += "DefaultSiteCode='$DSC'" }
            $temp = [string]::join(" or ", $temp)
            if ($temp -ne "") { $Filter += "($temp)" }
        }

        $Filter = [string]::join(" and ", $Filter)

        Write-Debug "Filter is: $Filter"

        # Look up WMI objects
        $result = Get-WmiObject -Namespace "root\SMS\site_D71" -Class SMS_BoundaryGroup -Filter $Filter

        # Return set of results
        Write-Output $result
    }
}


# Returns a single newly created Boundary
Function New-Boundary
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [switch]
            $OverrideUnique,
        [switch]
            $Force,
        [string]
            $DisplayName = "",
        [string]
        [alias("Type")]
        [ValidateSet("IPSubnet", "ADSite", "IPv6Prefix", "IPRange")]
            $BoundaryType,
        [string]
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
            $Value
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        $Type = 0
        if ($BoundaryType -ne $null) {
            switch($BoundaryType) {
                "IPSubnet"   { $Type = 0 ; break }
                "ADSite"     { $Type = 1 ; break }
                "IPv6Prefix" { $Type = 2 ; break }
                "IPRange"    { $Type = 3 ; break }
            }
        }
        # Check for uniqueness of $Value
        if (-not $OverrideUnique -and (Get-Boundary -Value $Value) -ne $null) {
            Write-Error "An SMS_Boundary with Value: $Value already exists! This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
        } else {
            if ($Force -or $pscmdlet.ShouldProcess("SMS_Boundary: $DisplayName ($Value)")) {
                $Argument = @{
                    DisplayName="$DisplayName";
                    BoundaryType="$Type";
                    Value="$Value"
                }

                Set-WmiInstance -Namespace "root\SMS\site_D71" -Class SMS_Boundary -Argument $Argument | Write-Output
            }
        }
    }
}


# Returns a single newly created BoundaryGroup
Function New-BoundaryGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [switch]
            $OverrideUnique,
        [switch]
            $Force,
        [string]
            $DefaultSiteCode,
        [string]
            $Description,
        [string]
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
            $Name
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        # Check for uniqueness of $Name
        if (-not $OverrideUnique -and (Get-BoundaryGroup -Name $Name) -ne $null) {
            Write-Error "An SMS_BoundaryGroup with Name: $Name already exists! This parameter must be unique, pick a different value. You can override with the -OverrideUnique parameter."
        } else {
            if ($Force -or $pscmdlet.ShouldProcess("Create new SMS_BoundaryGroup: $Name")) {
                $Argument = @{
                    Name="$Name";
                    DefaultSiteCode="$DefaultSiteCode";
                    Description="$Description"
                }

                Set-WmiInstance -Namespace "root\SMS\site_D71" -Class SMS_BoundaryGroup -Argument $Argument | Write-Output
            }
        }
    }
}


# Remove one or more Boundaries entirely
Function Remove-Boundary
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [switch]
            $Force,
        [System.Management.ManagementObject[]]
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            $Boundary
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($Bound in $Boundary) {
            if ($Force -or $pscmdlet.ShouldProcess("SMS_Boundary: $($Bound.DisplayName) ($($Bound.Value))")) {
                # Find all BoundaryGroups this Boundary belongs to, and remove it from them
                $BoundaryGroups = Get-BoundaryGroup -Boundary $Bound
                foreach ($BoundaryGroup in $BoundaryGroups) {
                    $Bound | Remove-BoundaryFromBoundaryGroup -BoundaryGroup $BoundaryGroup
                }
                # Finally remove the object itself
                $Bound | Remove-WmiObject
            }
        }
    }
}


# Remove one or more BoundaryGroups entirely (does not remove their contained Boundaries)
Function Remove-BoundaryGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [switch]
            $Force,
        [System.Management.ManagementObject[]]
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            $BoundaryGroup
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($BG in $BoundaryGroup) {
            if ($Force -or $pscmdlet.ShouldProcess("SMS_BoundaryGroup: $($BG.Name)")) {
                # Find all Boundaries in this BoundaryGroup and remove them from it
                Get-Boundary -BoundaryGroup $BG | Remove-BoundaryFromBoundaryGroup -BoundaryGroup $BG
                # Find all SiteSystems in this BoundaryGroup and remove them from it (TODO)
                ## Get-SiteSystems -BoundaryGroups $BoundaryGroup | Remove-SiteSystemsFromBoundaryGroup -BoundaryGroup $BoundaryGroup
                # Finally remove the object itself
                $BG | Remove-WmiObject
            }
        }
    }
}


# Configure properties of the specified Boundary/Boundaries
Function Set-Boundary
{
    # No enforcement of type on these arguments, since strings cannot be $null in PowerShell
    # and we need nulls since we may way to pass an empty string to set a value to
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [switch]
            $OverrideUnique,
        [switch]
            $Force,
        [System.Management.ManagementObject[]]
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            $Boundary,
        [alias("Name")]
            $DisplayName = $null,
        [alias("Type")]
        [ValidateSet("IPSubnet", "ADSite", "IPv6Prefix", "IPRange")]
            $BoundaryType = $null,
            $Value = $null
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($Bound in $Boundary) {
            if ($Force -or $pscmdlet.ShouldProcess("SMS_Boundary: $($Bound.DisplayName) ($($Bound.Value))")) {
                # Check uniqueness of $Value
                if ($Value -ne $null) {
                    if (-not $OverrideUnique -and (Get-Boundary -Value $Value) -ne $null) {
                        Write-Error "An SMS_Boundary with Value: '$Value' already exists! This parameter must be unique, pick a different value. (You can override with the -OverrideUnique parameter.)"
                        # TODO ThrowTerminatingError
                        return
                    }
                    if ($Value.GetType() -eq [string]) { $Bound.Value = $Value }
                }

                if ($DisplayName -ne $null) {
                    if ($DisplayName.GetType() -eq [string]) { $Bound.DisplayName = $DisplayName }
                }

                if ($BoundaryType -ne $null) {
                    switch($BoundaryType) {
                        "IPSubnet"   { $Bound.BoundaryType = 0 ; break }
                        "ADSite"     { $Bound.BoundaryType = 1 ; break }
                        "IPv6Prefix" { $Bound.BoundaryType = 2 ; break }
                        "IPRange"    { $Bound.BoundaryType = 3 ; break }
                    }
                }

                Write-Debug "Modified object:"
                $Bound | Write-Debug
                $Bound.put()
            }
        }
    }
}


# Configure properties of the specified BoundaryGroup(s)
Function Set-BoundaryGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [switch]
            $OverrideUnique,
        [switch]
            $Force,
        [System.Management.ManagementObject[]]
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            $BoundaryGroup,
            $DefaultSiteCode = $null,
            $Description = $null,
            $Name = $null
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($BG in $BoundaryGroup) {
            if ($Force -or $pscmdlet.ShouldProcess("SMS_BoundaryGroup: $($BG.Name)")) {
                # Check uniqueness of $Name
                if ($Name -ne $null) {
                    if (-not $OverrideUnique -and (Get-BoundaryGroup -Name $Name) -ne $null) {
                        Write-Error "An SMS_BoundaryGroup with Name: '$Name' already exists! This parameter must be unique, pick a different value. You can override with the -OverrideUnique parameter."
                        # TODO ThrowTerminatingError
                        return
                    }
                    if ($Name.GetType() -eq [string]) { $BG.Name = $Name }
                }

                if ($DefaultSiteCode -ne $null) {
                    if ($DefaultSiteCode.GetType() -eq [string]) { $BG.DefaultSiteCode = $DefaultSiteCode }
                }

                if ($Description -ne $null) {
                    if ($Description.GetType() -eq [string]) { $BG.Description = $Description }
                }

                Write-Debug "Modified object:"
                $BG | Write-Debug
                $BG.put()
            }
        }
    }
}

# Add the specified Boundaries to the specified BoundaryGroup
Function Add-BoundaryToBoundaryGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [switch]
            $Force,
        [System.Management.ManagementObject[]]
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            $Boundary,
        [System.Management.ManagementObject]
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
            $BoundaryGroup
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($Bound in $Boundary) {
            if ($Force -or $pscmdlet.ShouldProcess("SMS_Boundary: $($Bound.DisplayName), SMS_BoundaryGroup: $($BoundayGroup.Name)")) {
                $InParams = $BoundaryGroup.PSBase.GetMethodParameters("AddBoundary")
                $InParams.BoundaryID = $Bound.BoundaryID

                Write-Debug "Calling SMS_BoundaryGroup::AddBoundary with Parameters: "
                Write-Debug $InParams.PSBase.properties | Select name,Value | Format-Table

                Write-Debug "Result: "
                $BoundaryGroup.PSBase.InvokeMethod("AddBoundary", $InParams, $Null) | Write-Debug | Format-List
            }
        }
    }
}


# Add the specified SiteSystems to the specified BoundaryGroup
Function Add-SiteSystemToBoundaryGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [string[]]
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            # Form: DEV71-CM01.DEV71.local
            $SiteSystem,
        [int]
            $Flags = 0,
        [System.Management.ManagementObject]
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
            $BoundaryGroup
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($SiteSys in $SiteSystem) {
            if ($Force -or $pscmdlet.ShouldProcess("SiteSystem: $SiteSys (SiteCode: $SiteCode), SMS_BoundaryGroup: $($BoundayGroup.Name)")) {
                # Form: ["Display=\\DEV71-CM01.DEV71.local\"]MSWNET:["SMS_SITE=D71"]\\DEV71-CM01.DEV71.local\
                $ServerNALPath = "[`"Display=\\$SiteSystem\`"]MSWNET:[`"SMS_SITE=$SiteCode`"]\\$SiteSystem\"

                $InParams = $BoundaryGroup.PSBase.GetMethodParameters("AddSiteSystem")
                $InParams.Flags = $Flags
                $InParams.ServerNALPath = $ServerNALPath

                Write-Debug "Calling SMS_BoundaryGroup::AddSiteSystem with Parameters: "
                Write-Debug $InParams.PSBase.properties | Select name,Value | Format-Table

                Write-Debug "Result: "
                $BoundaryGroup.PSBase.InvokeMethod("AddSiteSystem", $InParams, $Null) | Write-Debug | Format-List
            }
        }
    }
}


# Remove the specified Boundaries from the specified BoundaryGroup (silent if Boundary isn't within the BoundaryGroup)
Function Remove-BoundaryFromBoundaryGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [switch]
            $Force,
        [System.Management.ManagementObject[]]
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            $Boundary,
        [System.Management.ManagementObject]
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
            $BoundaryGroup
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($Bound in $Boundary) {
            if ($Force -or $pscmdlet.ShouldProcess("SMS_Boundary: $($Bound.DisplayName), SMS_BoundaryGroup: $($BoundayGroup.Name)")) {
                $InParams = $BoundaryGroup.PSBase.GetMethodParameters("RemoveBoundary")
                $InParams.BoundaryID = $Bound.BoundaryID

                Write-Debug "Calling SMS_BoundaryGroup::RemoveBoundary with Parameters: "
                Write-Debug $InParams.PSBase.properties | Select name,Value | Format-Table

                Write-Debug "Result: "
                $BoundaryGroup.PSBase.InvokeMethod("RemoveBoundary", $InParams, $Null) | Write-Debug | Format-List
            }
        }
    }
}


# Remove the specified SiteSystems from the specified BoundaryGroup (silent if SiteSystem isn't within the BoundaryGroup)
Function Remove-SiteSystemFromBoundaryGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param (
        # Auto SiteCode uses value of environment parameter, can be overridden
        [string]
        [ValidateNotNullOrEmpty()]
            $SiteCode = "Auto",
        [string[]]
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [ValidateNotNullOrEmpty()]
            # Form: DEV71-CM01.DEV71.local
            $SiteSystem,
        [System.Management.ManagementObject]
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
            $BoundaryGroup
    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        foreach ($SiteSys in $SiteSystem) {
            if ($Force -or $pscmdlet.ShouldProcess("SiteSystem: $SiteSys (SiteCode: $SiteCode), SMS_BoundaryGroup: $($BoundayGroup.Name)")) {
                # Form: ["Display=\\DEV71-CM01.DEV71.local\"]MSWNET:["SMS_SITE=D71"]\\DEV71-CM01.DEV71.local\
                $ServerNALPath = "[`"Display=\\$SiteSystem\`"]MSWNET:[`"SMS_SITE=$SiteCode`"]\\$SiteSystem\"

                $InParams = $BoundaryGroup.PSBase.GetMethodParameters("RemoveSiteSystem")
                $InParams.ServerNALPath = $ServerNALPath

                Write-Debug "Calling SMS_BoundaryGroup::RemoveSiteSystem with Parameters: "
                Write-Debug $InParams.PSBase.properties | Select name,Value | Format-Table

                Write-Debug "Result: "
                $BoundaryGroup.PSBase.InvokeMethod("RemoveSiteSystem", $InParams, $Null) | Write-Debug | Format-List
            }
        }
    }
}
