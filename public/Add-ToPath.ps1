function Add-ToPath {

    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$ConfigFile = (Join-Path (Split-Path $PSScriptRoot -Parent) "config/user_path.txt")
    )

    if (-not (Test-Path $ConfigFile)) {
        throw "Config file not found: $ConfigFile"
    }

    $NewPaths = Get-Content $ConfigFile |
                Where-Object { $_.Trim() -ne "" } |
                ForEach-Object { $_.Trim() }

    if (-not $NewPaths) {
        throw "Config file is empty: $ConfigFile"
    }

    # Get current user PATH (persistent)
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $CurrentPath) { $CurrentPath = "" }

    # Normalize existing entries (case-insensitive set behavior)
    $PathSet = [System.Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase
    )
    foreach ($p in ($CurrentPath -split ';')) {
        if ($p.Trim()) {
            $normalized = (Resolve-Path -LiteralPath $p -ErrorAction SilentlyContinue)?.Path
            $PathSet.Add(($normalized ?? $p).TrimEnd('\')) | Out-Null
        }
    }

    $Changed = $false
    foreach ($line in $NewPaths) {

        $resolved = [Environment]::ExpandEnvironmentVariables($line)

        if (-not (Test-Path $resolved)) {
            Write-Warning "Path does not exist: $resolved"
            continue
        }

        $normalized = (Resolve-Path -LiteralPath $resolved).Path.TrimEnd('\')

        if ($PathSet.Add($normalized)) {
            Write-Verbose "Adding: $normalized"
            $Changed = $true
        }
        else {
            Write-Verbose "Already present: $normalized"
        }
    }

    if (-not $Changed) {
        Write-Verbose "No PATH changes required."
        return
    }

    $UpdatedPath = ($PathSet.ToArray() -join ';')

    if ($UpdatedPath -ne $CurrentPath) {
        [Environment]::SetEnvironmentVariable("Path", $UpdatedPath, "User")
        Restart-Explorer -Force
        Write-Host "User PATH updated successfully." -ForegroundColor Green
    }
    else {
        Write-Host "User PATH is already up to date." -ForegroundColor Yellow
    }
}