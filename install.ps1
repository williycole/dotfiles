# PowerShell script to copy Neovim configuration to Windows location

# Define source and destination paths
$sourceNvimConfig = "$env:USERPROFILE\repos\dotfiles\nvim"
$destNvimConfig = "$env:LOCALAPPDATA\nvim"

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
Copy-Item -Path $sourceNvimConfig -Destination $destNvimConfig -Recurse

# Verify the copy operation
if (Test-Path $destNvimConfig) {
    Write-Host "Neovim configuration successfully copied to Windows location."
} else {
    Write-Host "Error: Failed to copy Neovim configuration."
}

