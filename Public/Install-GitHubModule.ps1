function Install-GitHubModule {
    <#
    .SYNOPSIS
        Install PowerShell module from GitHub repository
    .DESCRIPTION
        Install PowerShell module from GitHub repository
    .PARAMETER Account
        GitHub account or organization name
    .PARAMETER Repository
        Repository name
    .PARAMETER Scope
        Module scope
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Install-GitHubModule -Account 'johnsarie27' -Repository 'SecurityTools'
        Installs SecurityTools module in the CurrentUser scope
    .NOTES
        Name:     Install-GitHubModule
        Author:   Justin Johns
        Version:  0.1.0 | Last Edit: 2023-12-22
        - 0.1.0 - Initial version
        Comments:
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'GitHub account or organization name')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Account,

        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Repository name')]
        [Alias('Repo')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Repository,

        [Parameter(Mandatory = $false, Position = 2, HelpMessage = 'Module home folder')]
        [ValidateSet('AllUsers', 'CurrentUser')]
        [System.String] $Scope = 'CurrentUser'
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET PLATFORM VARIABLES
        if ($IsWindows) { $tempDir = $env:TEMP; $splitChar = ';' }
        if ($IsLinux) { $tempDir = '/tmp/'; $splitChar = ':' }
        if ($IsMacOS) { $tempDir = $Env:TMPDIR; $splitChar = ':' }

        # SET DEFAULT MODULE HOME PATH
        $moduleHome = switch ($Scope) {
            'CurrentUser' { ($env:PSModulePath.Split("$splitChar"))[0] }
            'AllUsers' { ($env:PSModulePath.Split("$splitChar"))[1] }
        }

        Write-Verbose -Message ('Module home: "{0}"' -f $moduleHome)
    }
    Process {
        # GET INSTALLED MODULE
        $hasModule = Get-Module -ListAvailable -Name $Repository

        # VALIDATE VERSIONS
        if ($hasModule) {
            # OUTPUT RESPONSE
            Write-Warning -Message ('Module already installed. Use "Update-GitHubModule" to upgrade.')
        }
        else {
            # SET PATHS
            $tempPath = Join-Path -Path $tempDir -ChildPath ('{0}.zip' -f $Repository)

            # GET LATEST RELEASE INFORMATION
            Write-Verbose -Message 'Getting repo release information...'
            $releaseInfo = Invoke-RestMethod -Uri ('https://api.github.com/repos/{0}/{1}/releases/latest' -f $Account, $Repository) -ErrorAction Stop

            # DOWNLOAD MODULE
            Write-Verbose -Message 'Downloading module package...'
            Invoke-WebRequest -Uri $releaseInfo.assets[0].browser_download_url -OutFile $tempPath

            # DECOMPRESS MODULE TO MODULE PATH
            Write-Verbose -Message 'Expanding package archive...'
            Expand-Archive -Path $tempPath -DestinationPath $moduleHome -Force

            # UNBLOCK MODULE
            if ($IsWindows) {
                Write-Verbose -Message 'Unblocking files...'
                Get-ChildItem -Path (Join-Path -Path $moduleHome -ChildPath $Repository) -Recurse | Unblock-File
            }

            # VALIDATE INSTALL
            if (Test-Path -Path (Join-Path -Path $moduleHome -ChildPath $Repository) -PathType Container) {
                Write-Output -InputObject 'Module installed successfully'
            }
        }
    }
    End {
        # REMOVE TEMPORARY ZIP FILE
        if ($tempPath -and (Test-Path -Path $tempPath)) {
            Write-Verbose -Message 'Cleanup: removing package archive...'
            Remove-Item -Path $tempPath -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}
