function Get-WinInfo {
    <# =========================================================================
    .SYNOPSIS
        Get Windows information
    .DESCRIPTION
        Get Windows information using WMI and CIM
    .PARAMETER List
        List available classes
    .PARAMETER Id
        Id of class object
    .PARAMETER ComputerName
        Name of target host
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-WinInfo -List
        List available classes to pull information from
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = 'list')]
    Param(
        [Parameter(Mandatory, HelpMessage = 'List available classes', ParameterSetName = 'list')]
        [switch] $List,

        [Parameter(Mandatory, HelpMessage = 'Class Id', ParameterSetName = 'info')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $InfoModel.Classes.Id -contains $_ })]
        [int] $Id,

        [Parameter(ValueFromPipeline, HelpMessage = 'Hostname of target computer', ParameterSetName = 'info')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [Alias('CN')]
        [string] $ComputerName
    )

    Begin {
        $infoModel = Get-Content -Raw -Path "$PSScriptRoot\InformationModel.json" | ConvertFrom-Json

        $params = @{ }

        if ( $PSBoundParameters.ContainsKey('ComputerName') ) { $params.Add('ComputerName', $ComputerName) }
        if ( $PSBoundParameters.ContainsKey('Id') ) { $im = $infoModel.Classes.Where({ $_.Id -EQ $Id }) }
    }

    Process {
        if ( $PSBoundParameters.ContainsKey('List') ) {
            $infoModel.Classes | Select-Object -Property Id, Comments
        }
        else {
            $params['Namespace'] = $im.Namespace
            $params['ClassName'] = $im.ClassName

            if ( $im.Filters ) { $params.Add('Filter', $im.Filters) }

            Get-CimInstance @params
        }
    }
}