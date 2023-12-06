function Write-EncryptedFile {
    <# =========================================================================
    .SYNOPSIS
        Create encrypted file
    .DESCRIPTION
        Create encrypted file
    .PARAMETER Content
        Data to encrypt
    .PARAMETER Path
        Path to new encrypted file
    .PARAMETER Key
        Encryption key
    .PARAMETER KeyBytes
        Encryption key in byte array
    .INPUTS
        System.String[].
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Write-EncryptedFile -Content ($settings | ConvertTo-Json) -Path C:\temp\mySettings -Key 'Password123'
        Encrypts user settings in new file mySettings with the encryption key specified
    .NOTES
        General notes
        This function was written by Tim Curwick in PowerShell Conference Book 2
        (minor changes made)
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeLine)]
        [System.String[]] $Content,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path ([System.IO.Path]::GetDirectoryName($_)) -PathType Container })]
        [System.String] $Path,

        [Parameter(Mandatory, ParameterSetName = '__key')]
        [System.String] $Key,

        [Parameter(Mandatory, ParameterSetName = '__keybytes')]
        [System.Byte[]] $KeyBytes
    )
    Begin {
        try {
            # If the key was provided as a string convert it to bytes
            if ( $Key ) { $KeyBytes = [byte[]] $Key.ToCharArray() }

            # If the key is not 256 bits pad it or truncate it as needed
            if ( $KeyBytes.Count -ne 32 ) { $KeyBytes = ( $KeyBytes + [byte[]]'ThePaddingToUseIfWeNeedMoreBytes'.ToCharArray() )[0..31] }

            # Create cryptography engine
            $crypto = New-Object -TypeName System.Security.Cryptography.RijndaelManaged

            # Set key
            $crypto.Key = $KeyBytes

            # Use hash of key for initializing vector
            $crypto.IV = (New-Object -TypeName Security.Cryptography.SHA256Managed).ComputeHash($crypto.Key)[0..15]

            # Create encryptor
            $encryptor = $crypto.CreateEncryptor()

            # Create file stream
            $fileStream = New-Object System.IO.FileStream -ArgumentList @( $Path, [System.IO.FileMode]::Create )

            # Plumb the file stream into a cryptography stream with encryptor
            $cryptoStream = New-Object -TypeName Security.Cryptography.CryptoStream -ArgumentList @( $fileStream, $encryptor, "Write" )

            # Create stream writer to send the data
            $streamWriter = New-Object -TypeName IO.StreamWriter -ArgumentList $cryptoStream
        }
        catch {
            # Clean up
            if ( $streamWriter ) { $streamWriter.Close() }
            if ( $cryptoStream ) { $cryptoStream.Close() }
            if ( $fileStream ) { $fileStream.Close() }
            if ( $crypto ) { $crypto.Clear() }

            throw $_
        }

        # Set first line flag
        $firstLine = $true
    }
    Process {
        try {
            foreach ( $line in $Content ) {
                if ( $firstLine ) { $firstLine = $false }
                else { $streamWriter.Write( [Environment]::NewLine ) }

                # Dump the data to be encrypted into the stream
                $streamWriter.Write( $line )
            }
        }
        catch {
            # Clean up
            if ( $streamWriter ) { $streamWriter.Close() }
            if ( $cryptoStream ) { $cryptoStream.Close() }
            if ( $fileStream ) { $fileStream.Close() }
            if ( $crypto ) { $crypto.Clear() }

            throw $_
        }
    }
    End {
        # Clean up
        if ( $streamWriter ) { $streamWriter.Close() }
        if ( $cryptoStream ) { $cryptoStream.Close() }
        if ( $fileStream ) { $fileStream.Close() }
        if ( $crypto ) { $crypto.Clear() }

        # Return resulting file
        return ( Get-Item -Path $Path )
    }
}