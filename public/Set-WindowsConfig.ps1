function Set-WindowsConfig {
<#
.SYNOPSIS
Configures various Windows settings to enhance usability and functionality.

.DESCRIPTION
This function allows you to configure a range of Windows settings, such as enabling clipboard sync, hiding the search icon, enabling dark mode, showing hidden files, and more. You can enable individual settings or apply all configurations at once using the -All parameter.

.PARAMETER All
Applies all available configuration options.

.PARAMETER EnableClipboardSync
Enables clipboard history and synchronization across devices.

.PARAMETER HideSearchIcon
Hides the Windows Search icon from the taskbar.

.PARAMETER EnableSearchIndex
Enables and starts the Windows Search Indexing service to improve file search performance.

.PARAMETER EnableDarkMode
Activates dark mode for Windows applications and system UI.

.PARAMETER EnableFullPathInExplorer
Displays the full file path in the title bar of File Explorer.

.PARAMETER ShowHiddenFiles
Configures File Explorer to display hidden files and folders.

.PARAMETER ShowFileExtensions
Configures File Explorer to display file extensions for known file types.

.PARAMETER EnableLongPaths
Enables support for file paths longer than 260 characters.

.PARAMETER EnableDeveloperMode
Activates Windows Developer Mode, allowing the installation of unsigned apps and enabling advanced developer features.

.PARAMETER DisableEdgeTabsInAltTabView
Disables the display of Microsoft Edge tabs in the Alt+Tab view.

.EXAMPLE
Set-WindowsConfig -All
Configures all available settings.

.NOTES
This function requires administrative privileges with the 'gsudo' tool for certain settings to be applied successfully.
#>

    [CmdletBinding()]
    param (
        [switch]$All,
        [switch]$EnableClipboardSync,
        [switch]$HideSearchIcon,
        [switch]$EnableSearchIndex,
        [switch]$EnableDarkMode,
        [switch]$EnableFullPathInExplorer,
        [switch]$ShowHiddenFiles,
        [switch]$ShowFileExtensions,
        [switch]$EnableLongPaths,
        [switch]$EnableDeveloperMode,
        [switch]$DisableEdgeTabsInAltTabView,
        [switch]$DisableWindowsFeedback,
        [switch]$DisableTelemetry,
        [switch]$DisableMouseAcceleration,
        [switch]$DisableExplorerGallery,
        [switch]$DisablePowerShellLogo
    )

    # All feature switch names except -All and common parameters
    $FeatureParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Keys |
                         Where-Object { $_ -ne 'All' -and $_ -notmatch '^(Verbose|Debug|ErrorAction|WarningAction|InformationAction|OutVariable|OutBuffer|PipelineVariable)$' }
    # If -All is used, activate all feature switches dynamically
    if ($All) {
        foreach ($param in $FeatureParameters) {
            Set-Variable -Name $param -Value $true
        }
    }
    # Determine which switches are enabled
    $EnabledFeatures = $FeatureParameters |
        Where-Object { (Get-Variable $_ -ValueOnly -ErrorAction SilentlyContinue) }
    if (-not $EnabledFeatures) {
        throw "No configuration options were selected. Use -All or specify individual switches."
    }

    Test-Dependency -Command "gsudo" -Source "gerardog.gsudo" -App

    Write-Host "Starting Windows configuration setup..." -ForegroundColor Cyan

    gsudo cache on | Out-Null

    # Enable clipboard history and sync
    if ($EnableClipboardSync) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1 -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardSync" -Value 1 -Force

            Write-Host "Clipboard history and sync enabled successfully." 
        } catch {
            Write-Error "Failed to enable clipboard history and sync: $_"
        }
    }

    # Hide Windows Search icon
    if ($HideSearchIcon) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force
            
            Write-Host "Windows Search icon hidden successfully." 
        } catch {
            Write-Error "Failed to hide Windows Search icon: $_"
        }
    }

    # Enable Windows Search Indexing
    if ($EnableSearchIndex) {
        try {
            #  ! Error: cannot open wseach service on computer '.'
            Start-Service -Name "WSearch" -ErrorAction Stop
            gsudo Set-Service -Name "WSearch" -StartupType Automatic -ErrorAction Stop
            
            Write-Host "Windows Search Indexing service enabled successfully." 
        } catch {
            Write-Error "Failed to enable Windows Search Indexing service: $_"
        }
    }

    # Enable dark mode
    if ($EnableDarkMode) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Force
            
            Write-Host "Dark mode enabled successfully." 
        } catch {
            Write-Error "Failed to enable dark mode: $_"
        }
    }

    # Enable full path in Explorer title bar
    if ($EnableFullPathInExplorer) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPathAddress" -Value 1 -Force
            
            Write-Host "Full path in Explorer title bar enabled successfully." 
        } catch {
            Write-Error "Failed to enable full path in Explorer title bar: $_"
        }
    }

    # Show hidden files
    if ($ShowHiddenFiles) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force
            
            Write-Host "Hidden files visibility enabled successfully." 
        } catch {
            Write-Error "Failed to enable hidden files visibility: $_"
        }
    }

    # Show file extensions
    if ($ShowFileExtensions) {
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force
            
            Write-Host "File extensions visibility enabled successfully." 
        } catch {
            Write-Error "Failed to enable file extensions visibility: $_"
        }
    }

    # Enable long paths
    if ($EnableLongPaths) {
        try {
            gsudo Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Force
            
            Write-Host "Long paths support enabled successfully." 
        } catch {
            Write-Error "Failed to enable long paths support: $_"
        }
    }

    # Enable Developer Mode
    if ($EnableDeveloperMode) {
        try {
            gsudo Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Force
            gsudo Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Value 1 -Force
            
            Write-Host "Developer Mode enabled successfully." 
        } catch {
            Write-Error "Failed to enable Developer Mode: $_"
        }
    }

    # Disable Edge tabs in Alt+Tab view
    if ($DisableEdgeTabsInAltTabView) {
        try {
            # Navigate to the registry key and set the property
            gsudo Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Value 3

            Write-Host "Edge tabs in Alt+Tab view disabled successfully."
        } catch {
            Write-Error "Failed to disable Edge tabs in Alt+Tab view: $_"
        }
    }

    if ($DisableWindowsFeedback) {
        try {
            gsudo Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowWindowsFeedback" -Value 0 -Force

            Write-Host "Windows Feedback disabled successfully."
        } catch {
            Write-Error "Failed to disable Windows Feedback: $_"
        }
    }

    # Disable Telemetry
    if ($DisableTelemetry) {
        try {
            gsudo Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force

            Write-Host "Telemetry disabled successfully."
        } catch {
            Write-Error "Failed to disable Telemetry: $_"
        }
    }

    if ($DisableMouseAcceleration) {
        try {
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -Force
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold" -Value 0 -Force
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0 -Force
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0 -Force
             
            Write-Host "Mouse Acceleration disabled successfully."
        } catch {
            Write-Error "Failed to disable Mouse Acceleration: $_"
        }
    }

    if ($DisableExplorerGallery) {
        try {
            Write-Warning "Not yet implemented."
            # TODO: this did not work.
            
            # Write-Host "Explorer Gallery disabled successfully." 
        } catch {
            Write-Error "Failed to disable Explorer Gallery: $_"
        }
    }

    if ($DisablePowerShellLogo) {
        try {
            Set-ItemProperty -Path "HKCU:\Console" -Name "ShowPowerShellLogo" -Value 0 -Type DWord -Force

            Write-Host "PowerShell logo disabled successfully."
        } catch {
            Write-Error "Failed to disable PowerShell logo: $_"
        }
    }

    Restart-Explorer -Force
    Write-Host "Windows configuration setup completed." -ForegroundColor Green
}

