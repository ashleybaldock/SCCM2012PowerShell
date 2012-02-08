
# Functions associated with SCCM 2012 Schedules


# Direct production of an Interval String, for use in other methods
Function New-IntervalString
{
    [CmdletBinding(DefaultParameterSetName = "None")]
    Param (
        [string]
        [ValidateNotNullOrEmpty()] 
            $SiteCode = "Auto",

        [DateTime]
        [parameter(Mandatory = $true)]
            $Start,

        # Should DateTime object be interpreted as local time, or UTC?
        [switch]
            $UTC = $false,

        # Should UTC value be specified in the WMI Time object?
        [switch]
            $UnzonedTime = $false,

        [int]
        [ValidateRange(0,31)]
            $DayDuration = $null,
        [int]
        [ValidateRange(0,23)]
            $HourDuration = $null,
        [int]
        [ValidateRange(0,59)]
            $MinuteDuration = $null,

        # For No Reccurrence (default), specify nothing
        # For Weekly, specify -Day and -NumberOfWeeks
        # For Monthly, specify -NumberOfMonths and:
        #   By Date: -MonthDay
        #   By Weekday: -Day -WeekOfMonth
        # For Custom, specify -DaySpan, -HourSpan or -MinuteSpan

        # All reccurrences take -DayDuration, -HourDuration and -MinuteDuration
        # Ditto -Start (mandatory)

        [string]
        [parameter(Mandatory = $true, ParameterSetName = "Weekly")]
        [parameter(Mandatory = $true, ParameterSetName = "MonthlyByWeekday")]
        [ValidateSet("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")]
            $Day = "Sunday",

        [int]
        [parameter(Mandatory = $true, ParameterSetName = "Weekly")]
        [ValidateRange(1,4)]
            $NumberOfWeeks = 1,

        [int]
        [parameter(Mandatory = $true, ParameterSetName = "MonthlyByDate")]
        [ValidateRange(0,31)]
            $MonthDay = 0,

        [int]
        [parameter(Mandatory = $true, ParameterSetName = "MonthlyByWeekday")]
        [parameter(Mandatory = $true, ParameterSetName = "MonthlyByDate")]
        [ValidateRange(1,12)]
            $NumberOfMonths = 1,

        [string]
        [parameter(Mandatory = $true, ParameterSetName = "MonthlyByWeekday")]
        [ValidateSet("First", "Second", "Third", "Fourth", "Last")]
            $WeekOfMonth = "Last",

        [int]
        [parameter(Mandatory = $true, ParameterSetName = "CustomDay")]
        [ValidateRange(0,31)]
            $DaySpan = 0,
        [int]
        [parameter(Mandatory = $true, ParameterSetName = "CustomHour")]
        [ValidateRange(0,23)]
            $HourSpan = 0,
        [int]
        [parameter(Mandatory = $true, ParameterSetName = "CustomMinute")]
        [ValidateRange(0,59)]
            $MinuteSpan = 0

    )
    Begin {
        if ($SiteCode -eq "Auto") { $SiteCode = "D71" }
    }
    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "None" {
                $token = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ST_NonRecurring").CreateInstance()
            break }
            "MonthlyByDate" {
                $token = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ST_RecurMonthlyByDate").CreateInstance()
                $token.ForNumberOfMonths = $NumberOfMonths
                $token.MonthDay = $MonthDay
            break }
            "MonthlyByWeekday" {
                $token = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ST_RecurMonthlyByWeekday").CreateInstance()
                $token.ForNumberOfMonths = $NumberOfMonths
                $token.Day = $Day # TODO convert string to int
                $token.WeekOrder = $WeekOfMonth # TODO convert string to int
            break }
            "Weekly" {
                $token = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ST_RecurWeekly").CreateInstance()
                $token.Day = $Day # TODO convert string to int
                $token.ForNumberOfWeeks = $NumberOfWeeks
            break }
            "CustomDay" {
                $token = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ST_RecurInterval").CreateInstance()
                $token.DaySpan = $DaySpan
            break }
            "CustomHour" {
                $token = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ST_RecurInterval").CreateInstance()
                $token.HourSpan = $HourSpan
            break }
            "CustomMinute" {
                $token = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ST_RecurInterval").CreateInstance()
                $token.MinuteSpan = $MinuteSpan
            break }
        }

        # Set Start
        $objScriptTime = New-Object -ComObject WbemScripting.SWbemDateTime
        $objScriptTime.SetVarDate($startTimeWindow, (-not $GMT))
        if ( $UnzonedTime -eq $true ) { $objScriptTime.UTCSpecified = $false }
        $token.StartTime = $objScriptTime.Value

        # Set Duration
        if ($DayDuration -ne $null) { $token.DayDuration = $DayDuration }
        else { if ($HourDuration -ne $null) { $token.HourDuration = $HourDuration }
        else { if ($MinuteDuration -ne $null) { $token.MinuteDuration = $MinuteDuration } } }

        # Finally get the schedule string from the instance
        $schedulemethods = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ScheduleMethods")
        $InParams = $schedulemethods.PSBase.GetMethodParameters("WriteToString")
        $InParams.TokenData = $token
        $IntervalString = $BoundaryGroup.PSBase.InvokeMethod("WriteToString", $InParams, $Null)

        Write-Output $IntervalString
    }
}


######################
#  Helper Functions  #
######################

# These methods allow you to manipulate existing ScheduleToken objects

#  return encoded interval string, takes an SMS_ScheduleToken object
Function Encode-IntervalString
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
        # TODO - split out functionality from New-IntervalString and call these methods
    }
}

#  return SMS_ScheduleToken object, takes an encoded interval string
Function Decode-IntervalString
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
        # TODO - split out functionality from New-IntervalString and call these methods
    }
}


## Encode/decode schedules
#$schedulemethods = ([WMIClass] "root\SMS\site_$($SiteCode):SMS_ScheduleMethods")
#$InParams = $schedulemethods.PSBase.GetMethodParameters("WriteToString")
#$InParams.TokenData = <A token>
#$BoundaryGroup.PSBase.InvokeMethod("WriteToString", $InParams, $Null)
#
#$InParams = $schedulemethods.PSBase.GetMethodParameters("ReadFromString")
#$InParams.StringData = <A string>
#$BoundaryGroup.PSBase.InvokeMethod("ReadFromString", $InParams, $Null)





#    # None
#    -StartTime (datetime) # Mandatory
#    -DayDuration
#    -HourDuration
#    -MinuteDuration
#    -GMT (bool [default false])
#    # MonthlyByDate
#    -MonthDay (0-31 [default:0])
#    -ForNumberOfMonths (1-12 [default:1])
#    # MonthlyByWeekday
#    -Day (Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday [default: Sunday])
#    -ForNumberOfMonths (1-12 [default: 1])
#    -WeekOfMonth (First, Second, Third, Fourth, Last [default: Last])
#    # Weekly
#    -Day (Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday [default: Sunday])
#    -ForNumberOfWeeks (1-4 [default: 1])
#    # Interval
#    -DaySpan
#    -HourSpan
#    -MinuteSpan


