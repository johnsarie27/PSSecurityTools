# IMPORT ALL FUNCTIONS
foreach ( $directory in @('Public', 'Private') ) {
    foreach ( $fn in (Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1") ) { . $fn.FullName }
}

# VARIABLES
New-Variable -Name 'EventTable' -Option ReadOnly -Value (
    Get-Content -Raw -Path "$PSScriptRoot\Public\EventTable.json" | ConvertFrom-Json
)

New-Variable -Name 'InfoModel' -Option ReadOnly -Value (
    Get-Content -Raw -Path "$PSScriptRoot\Public\InformationModel.json" | ConvertFrom-Json
)

# EXPORT MEMBERS
# THESE ARE SPECIFIED IN THE MODULE MANIFEST AND THEREFORE DON'T NEED TO BE LISTED HERE
#Export-ModuleMember -Function *
Export-ModuleMember -Variable 'EventTable', 'InfoModel'
Export-ModuleMember -Alias 'Get-ActiveGWUser'