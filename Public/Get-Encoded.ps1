function Get-Encoded {
    <#
    .SYNOPSIS
        Encode string to Base64 or URL encoding
    .DESCRIPTION
        Encode string to Base64 or URL encoding
    .PARAMETER String
        Plain text string
    .PARAMETER Encoding
        Encoding type (Base64 or URL)
    .INPUTS
        System.String.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Get-Encoded -String 'https://google.com/' -Encoding URL
        URL encode 'https://google.com/'
    .NOTES
        Name: Get-Encoded
        Author: Justin Johns
        Version: 0.1.1 | Last Edit: 2022-01-11 [0.1.1]
        - Changed class used to perform URL encoding
        Comments: <Comment(s)>
        General notes
    #>
    [CmdletBinding()]
    [OutputType('System.String')]
    Param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'Plain text string')]
        [ValidateNotNullOrEmpty()]
        [System.String] $String,

        [Parameter(Position = 1, HelpMessage = 'Encoding')]
        [ValidateSet('Base64', 'URL')]
        [System.String] $Encoding = 'Base64'
    )
    Process {
        if ($Encoding -EQ 'Base64') {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
            [System.Convert]::ToBase64String($bytes)
        }
        if ($Encoding -EQ 'URL') {
            #[System.Web.HttpUtility]::UrlEncode($String)
            [System.Uri]::EscapeDataString($String)
        }
    }
}
