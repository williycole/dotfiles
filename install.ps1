# Define paths
$sourceNvimConfig = "$env:USERPROFILE\repos\dotfiles\windows\nvim"
$destNvimConfig = "$env:LOCALAPPDATA\nvim"
$configNvimLink = "$env:USERPROFILE\.config\nvim"

# Check if source directory exists
if (-not (Test-Path $sourceNvimConfig)) {
    Write-Host "Error: Source Neovim configuration not found at $sourceNvimConfig"
    exit 1
}

# Remove existing Neovim config if it exists
if (Test-Path $destNvimConfig) {
    Remove-Item -Recurse -Force $destNvimConfig
    Write-Host "Removed existing Neovim configuration."
}

# Copy Neovim configuration
Copy-Item -Path $sourceNvimConfig -Destination $destNvimConfig -Recurse
Write-Host "Copied Neovim configuration to $destNvimConfig"

# Create symbolic link in .config folder
if (Test-Path $configNvimLink) {
    Remove-Item -Force $configNvimLink
}
New-Item -ItemType SymbolicLink -Path $configNvimLink -Target $destNvimConfig
Write-Host "Created symbolic link from $configNvimLink to $destNvimConfig"

