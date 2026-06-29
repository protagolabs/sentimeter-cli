# SentiMeter CLI installer (Windows, PowerShell).
#
#   irm https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install.ps1 | iex
#
# Downloads the prebuilt Windows binary from the latest GitHub Release of the
# public releases repo and installs it to %LOCALAPPDATA%\Programs\sentimeter,
# adding that dir to the user PATH. No Python required.
#
# Env overrides:
#   $env:SENTIMETER_VERSION  tag to install (default: latest)
$ErrorActionPreference = "Stop"

# Public releases repo (binaries live here, NOT the private source monorepo).
$repo    = "protagolabs/sentimeter-cli"
$version = if ($env:SENTIMETER_VERSION) { $env:SENTIMETER_VERSION } else { "latest" }
$asset   = "sentimeter-windows-x86_64.exe"

if ($version -eq "latest") {
    $url = "https://github.com/$repo/releases/latest/download/$asset"
} else {
    $url = "https://github.com/$repo/releases/download/$version/$asset"
}

$installDir = Join-Path $env:LOCALAPPDATA "Programs\sentimeter"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
$target = Join-Path $installDir "sentimeter.exe"

Write-Host "Downloading $asset ($version)..."
Invoke-WebRequest -Uri $url -OutFile $target

# Add the install dir to the user PATH if it's not already there.
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
    Write-Host "Added $installDir to your PATH (restart the terminal to pick it up)."
}

Write-Host "Installed sentimeter -> $target"
Write-Host "Run: sentimeter login"
