function Update-GitHubModule {
    <#
    .SYNOPSIS
        Updates a module hosted in GitHub
    .DESCRIPTION
        Downloads, extracts, and unblocks module files from GitHub release
    .PARAMETER Name
        Module name
    .PARAMETER Replace
        Replace current module version
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Update-GitHubModule -Name 'SecurityTools'
        Checks published version is newer than installed. Then downloads SecurityTools module package from GitHub
        and extracts & unblocks as a new version.
    .EXAMPLE
        PS C:\> Update-GitHubModule -Name 'SecurityTools' -Replace
        Checks published version is newer than installed. Removes the old version. Then downloads SecurityTools
        module package from GitHub and extracts & unblocks the new version.
    .NOTES
        Name:     Update-GitHubModule
        Author:   Justin Johns
        Version:  0.1.1 | Last Edit: 2024-05-31
        - 0.1.1 - Add functionality to allow multiple module versions, keeping a 'replace' option
        - 0.1.0 - Initial version
        Comments:
        - This function assumes that currently installed module has the project URI property set correctly
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Module name')]
        [ValidateScript({ $null -NE (Get-Module -ListAvailable -Name $_) })]
        [System.String] $Name,

        [Parameter(Mandatory = $false, position = 1, HelpMessage = 'Replace current version')]
        [System.Management.Automation.SwitchParameter] $Replace
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET PLATFORM TEMP
        $tempDir = if ($IsWindows) { $env:TEMP } elseif ($IsMacOS) { $Env:TMPDIR } else { '/tmp/' }
    }
    Process {

        # GET MODULE: MODULE PRE-EXISTENCE VALIDATED IN PARAMETER ARGUMENT
        # IF MULTIPLE VERSIONS, USE LATEST
        $module = (Get-Module -ListAvailable -Name $Name | Sort-Object Version -Descending)[0]

        # VALIDATE PROJECT URI PROPERTY
        if ($module.ProjectUri.AbsoluteUri) {
            # SET URI
            Write-Verbose -Message ('Project URI: [{0}]' -f $module.ProjectUri.AbsoluteUri)
            $uri = 'https://api.{0}/repos{1}/releases/latest' -f $module.ProjectUri.Host, $module.ProjectUri.LocalPath
            Write-Verbose -Message ('Release URI: [{0}]' -f $uri)
        }
        else {
            throw ('Module [{0}] does not contain property "ProjectUri"!' -f $module.Name)
        }

        # GET LATEST RELEASE INFORMATION
        Write-Verbose -Message 'Getting repo release information...'
        $releaseInfo = Invoke-RestMethod -Uri $uri

        # SET LATEST RELEASE VERSION
        $releaseVer = [System.Version] $releaseInfo.tag_name.TrimStart('v')

        # VALIDATE VERSIONS
        if ($module.Version -GE $releaseVer) {
            # OUTPUT RESPONSE
            Write-Verbose -Message ('Installed module version: [{0}]' -f $module.Version.ToString())
            Write-Verbose -Message ('Current release package version: [{0}]' -f $releaseVer.ToString())
            Write-Output -InputObject ('Installed module version is same or greater than current release')
        }
        else {

            # SET TEMPORARY PATH
            $tempPath = Join-Path -Path $tempDir -ChildPath ('{0}.zip' -f $module.Name)

            # DOWNLOAD MODULE
            Write-Verbose -Message 'Downloading module package...'
            Invoke-WebRequest -Uri $releaseInfo.assets[0].browser_download_url -OutFile $tempPath

            # NEW MODULE BASE
            $modulePath = Split-Path -Parent $module.ModuleBase

            if ($Replace) {
                # WRITE OUTPUT
                Write-Output -InputObject ('Installed version [{0}] will be replaced by latest version [{1}]' -f $module.Version.ToString(), $releaseVer.ToString())

                # SHOULD PROCESS
                if ($PSCmdlet.ShouldProcess($module.Name, "Install new module version, remove old module version, and trust module")) {

                    # DECOMPRESS MODULE TO MODULE PATH
                    Write-Verbose -Message 'Expanding package archive...'
                    Expand-Archive -Path $tempPath -DestinationPath $modulePath

                    # RENAME FOLDER TO VERSION NUMBER
                    Rename-Item -Path (Join-Path -Path $modulePath -ChildPath $module.Name) -NewName $releaseVer.ToString()

                    # REMOVE EXISTING MODULE
                    Remove-Item -Path $module.ModuleBase -Recurse -Force -Confirm:$false

                    # UNBLOCK MODULE
                    if ($IsWindows -or $IsMacOS) {
                        Write-Verbose -Message 'Unblocking files...'
                        Get-ChildItem -Path (Join-Path -Path $modulePath -ChildPath $releaseVer.ToString()) -Recurse | Unblock-File
                    }
                }
            }
            else {
                # SHOULD PROCESS
                if ($PSCmdlet.ShouldProcess($module.Name, "Install new module version and trust module")) {

                    # DECOMPRESS MODULE TO MODULE PATH
                    Write-Verbose -Message 'Expanding package archive...'
                    Expand-Archive -Path $tempPath -DestinationPath $modulePath

                    # RENAME FOLDER TO VERSION NUMBER
                    Rename-Item -Path (Join-Path -Path $modulePath -ChildPath $module.Name) -NewName $releaseVer.ToString()

                    if ($IsWindows -or $IsMacOS) {
                        # UNBLOCK MODULE
                        Write-Verbose -Message 'Unblocking files...'
                        Get-ChildItem -Path (Join-Path -Path $modulePath -ChildPath $releaseVer.ToString()) -Recurse | Unblock-File
                    }
                }
            }

            # VALIDATE UPDATE
            if (Get-Module -FullyQualifiedName @{ModuleName = $module.Name; RequiredVersion = $releaseVer } -ListAvailable) {
                Write-Output -InputObject ('Module successfully updated to version [{0}]' -f $releaseVer)
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
