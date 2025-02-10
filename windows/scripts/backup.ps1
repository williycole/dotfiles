# Backup script for dotfiles

# Source and destination paths
$sourceDirs = @{
    ".config" = "C:\Users\William\.config"
    ".glzr" = "C:\Users\William\.glzr"
}
$destDir = "C:\Users\William\repos\dotfiles\windows"

# List of folders to backup
$foldersToBackup = @{
    ".config" = @("scoop", "spotify-tui", "wezterm")
    ".glzr" = @("*")
}

# Function to copy folder
function Copy-FolderWithOverwrite {
    param (
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path $Source) {
        if (Test-Path $Destination) {
            Remove-Item -Path $Destination -Recurse -Force
        }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Warning: Source path $Source does not exist."
    }
}

# Perform backup
foreach ($dirKey in $sourceDirs.Keys) {
    $sourceDir = $sourceDirs[$dirKey]
    $folders = $foldersToBackup[$dirKey]

    foreach ($folder in $folders) {
        if ($folder -eq "*") {
            $items = Get-ChildItem -Path $sourceDir -Directory
            foreach ($item in $items) {
                $sourcePath = $item.FullName
                $destPath = Join-Path -Path $destDir -ChildPath $dirKey | Join-Path -ChildPath $item.Name

                Write-Host "Backing up $dirKey\$($item.Name)..."
                Copy-FolderWithOverwrite -Source $sourcePath -Destination $destPath
            }
        } else {
            $sourcePath = Join-Path -Path $sourceDir -ChildPath $folder
            $destPath = Join-Path -Path $destDir -ChildPath $dirKey | Join-Path -ChildPath $folder

            Write-Host "Backing up $dirKey\$folder..."
            Copy-FolderWithOverwrite -Source $sourcePath -Destination $destPath
        }
    }
}

Write-Host "Backup completed!"

