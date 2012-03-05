#
# Module manifest for module 'PSCCM12'
#

@{

ModuleVersion       = "0.1"
PowerShellVersion   = "2.0"
CLRVersion          = "2.0"

# GUID generated on 05/03/2012
GUID                = "{b379e17c-b86d-4a6d-8572-9504ac21f3ee}"
Author              = "Timothy Baldock"
Copyright           = "(c) 2012 Timothy Baldock. All rights reserved."
Description         = "Administrative functions within SCCM 2012 - exposed through PowerShell"

RequiredModules = @()
RequiredAssemblies = @()
ScriptsToProcess = @()
TypesToProcess = @()
FormatsToProcess = @()
NestedModules = @(
    "schedule.ps1",
    "discovery.ps1",
    "boundary.ps1"
)

# Module does not provide any functions (and any defined are internal use only)
FunctionsToExport   = ""
CmdletsToExport     = "*"
VariablesToExport   = ""
AliasesToExport     = ""

ModuleList = @()
FileList = @()

# HelpInfoURI         = ""

}
