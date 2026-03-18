function Restart-Explorer {
    param (
        [switch]$Force
    )
    Write-Warning "Restarting Windows Explorer to apply changes..."
    
    # Kill the Windows Explorer process
    Stop-Process -Name "explorer" -Force:$Force -ErrorAction SilentlyContinue

    # Restart Windows Explorer
    Start-Process -FilePath "explorer.exe" -ErrorAction SilentlyContinue
}