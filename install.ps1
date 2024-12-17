# Check if XDG_CONFIG_HOME is set correctly
$expectedPath = "$env:USERPROFILE\.config"
$currentPath = [System.Environment]::GetEnvironmentVariable("XDG_CONFIG_HOME", "User")

if ($currentPath -ne $expectedPath) {
    Write-Host "XDG_CONFIG_HOME is not set correctly."
    Write-Host "Please run the following command before continuing:"
    Write-Host "[System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', '$expectedPath', 'User')"
    Write-Host "Then restart your PowerShell session."
    exit 1
} else {
    Write-Host "XDG_CONFIG_HOME is correctly set to: $currentPath"
}

# Rest of your existing script...
# Define source and destination paths
$sourceNvimConfig = "$env:USERPROFILE\repos\dotfiles\windows\nvim"
$destNvimConfig = "$env:XDG_CONFIG_HOME\nvim"

# Check if source directory exists
if (-not (Test-Path $sourceNvimConfig)) {
    Write-Host "Error: Source Neovim configuration not found at $sourceNvimConfig"
    Write-Host "Please ensure your dotfiles are cloned to $env:USERPROFILE\repos\dotfiles"
    exit 1
}

# Remove existing Neovim config if it exists
if (Test-Path $destNvimConfig) {
    Write-Host "Removing existing Neovim configuration..."
    Remove-Item -Recurse -Force $destNvimConfig
}

# Copy Neovim configuration
Write-Host "Copying Neovim configuration to $destNvimConfig..."
Copy-Item -Path $so

