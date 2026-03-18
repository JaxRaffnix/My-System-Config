function Set-PowerShellProfile {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigFile = (Join-Path (Split-Path $PSScriptRoot -Parent) "config/powershell_profile.ps1")
    )

    if (-not (Test-Path -Path $ConfigFile)) {
        throw Write-Error "Config file not found: $ConfigFile"
    }

    $DestinationFile = Join-Path $env:USERPROFILE "\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

    $DestinationDir = Split-Path -Path $DestinationFile -Parent
    if (-not (Test-Path -Path $DestinationDir)) {
        Write-Verbose "Creating directory: $DestinationDir"
        New-Item -Path $DestinationDir -ItemType Directory -Force | Out-Null
    }
    
    Copy-Item -Path $ConfigFile -Destination $DestinationFile -Force
    Write-Host "PowerShell profile configured successfully!" -ForegroundColor Green
}

