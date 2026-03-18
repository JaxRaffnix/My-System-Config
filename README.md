# My-Config-Manager

A personal PowerShell module for Windows setup and day-to-day system configuration. It ships with curated config files and a set of commands to apply them on a new machine.

## Requirements

- Windows 10 or 11
- PowerShell 5.1 or newer
- Required modules: `My-System-Setup`, `powershell-yaml`
- Admin elevation is needed for some commands (handled via `gsudo`)

## Install

Clone the repo and import the module from the repo root:

```powershell
Import-Module .\My-Config-Manager.psd1
```

For Develeopment, leverage the [Powershell ModuleTools](https://github.com/JaxRaffnix/Powershell-ModuleTools).

1. Download [Powershell ModuleTools](https://github.com/JaxRaffnix/Powershell-ModuleTools).  
2. Run its installer:
    ```bash
    .\self-installer.ps1.
    ```

3. Clone the Repo
  ```powershell
  git clone https://github.com/JaxRaffnix/My-Config-Manager.git
  cd My-Config-Manager
  Install-FromDev .
```

## Usage

```powershell
# Windows configuration
Set-WindowsConfig -All

# Apply bundled configs
Set-GitConfig
Set-PowerShellProfile
Set-TerminalConfig
Add-ToPath

# Apps and UI
Install-OhMyPosh -FontName "meslo"
Install-MSOffice365
Set-Wallpaper -WallpaperPath "C:\\Images\\wallpaper.jpg" -LockScreenPath "C:\\Images\\lockscreen.jpg"
```

## Config Files

- `config\global.gitconfig` -> used by `Set-GitConfig`
- `config\powershell_profile.ps1` -> used by `Set-PowerShellProfile`
- `config\windows-terminal.json` -> used by `Set-TerminalConfig`
- `config\user_path.txt` -> used by `Add-ToPath`
- `config\msoffice365.xml` -> used by `Install-MSOffice365`

## TO DO

```powershell
New-ItemProperty -Path "HKLM:\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" `
  -Name "ExecutionPolicy" -Value "Bypass" -PropertyType String -Force

Set-ItemProperty -Path "HKLM:\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" `
  -Name "NoLogo" -Value 1 -Type DWord
```

## Known Limitations

- `Set-WindowsConfig -DisableExplorerGallery` is not implemented yet.
- Config updates are one-way: if you change your local Terminal or PowerShell profile, update the files in `config` manually.

## Manual Steps

- Visual Studio Code: settings and extensions are managed via your GitHub account.
- KeepassXC: enable browser integration for Google Chrome. Enable lock after x seconds. Set Auto Type Shortcut to `CTRL+ALT+A`.
- MikTeX: check for upgrades.
- Thunderbird: import address book and calendar from `jan.hoegen.akathebozz@gmail.com`.