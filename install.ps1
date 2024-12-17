# Check if XDG_CONFIG_HOME is set correctly
$expectedPath = "$env:USERPROFILE\.config"
$currentPath = [System.Environment]::GetEnvironmentVariable("XDG_CONFIG_HOME", "User")

if ($currentPath -ne $expectedPath) {
    Write-Host "XDG_CONFIG_HOME is not set correctly."
    if ($currentPath) {
        Write-Host "Current value: $currentPath"
    } else {
        Write-Host "XDG_CONFIG_HOME is not set."
    }
    Write-Host "Expected value: $expectedPath"
    Write-Host "Please run the following command to fix it:"
    Write-Host "[System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', '$expectedPath', 'User')"
    Write-Host "Then restart your PowerShell session and run this script again."
    exit 1
} else {
    Write-Host "XDG_CONFIG_HOME is correctly set to: $currentPath"
    
    # Define source and destination directories
    $sourceDir = "$env:USERPROFILE\repos\dotfiles\windows"
    $destDir = $expectedPath

    # Create symbolic links
    Get-ChildItem $sourceDir | ForEach-Object {
        $sourcePath = $_.FullName
        $destPath = Join-Path $destDir $_.Name
        
        if (!(Test-Path $destPath)) {
            New-Item -ItemType SymbolicLink -Path $destPath -Target $sourcePath
            Write-Host "Created symbolic link for $($_.Name)"
        } else {
            Write-Host "Symbolic link for $($_.Name) already exists"
        }
    }
}

