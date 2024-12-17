# Backup script for dotfiles

# Source and destination paths
$sourceDir = "C:\Users\William\.config"
$destDir = "C:\Users\William\repos\dotfiles\windows"

# List of folders to backup
$foldersToBackup = @(
    ".glaze-wm",
    "scoop",
    "spotify-tui",
    "wezterm"
)

# Function to copy folder
function Copy-FolderWithOverwrite {
    param (
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path $Destination) {
        Remove-Item -Path $Destination -Recurse -Force
    }
    Copy-Item -Path $Source -Destination $Destination -Recurse -Force
}

# Perform backup
foreach ($folder in $foldersToBackup) {
    $sourcePath = Join-Path $sourceDir $folder
    $destPath = Join-Path $destDir $folder

    if (Test-Path $sourcePath) {
        Write-Host "Backing up $folder..."
        Copy-FolderWithOverwrite -Source $sourcePath -Destination $destPath
    } else {
        Write-Host "Warning: $folder not found in source directory."
    }
}

Write-Host "Backup completed!"

