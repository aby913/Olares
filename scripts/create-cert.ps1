param (
  [string]$Version
)

$currentPath = Get-Location
$currentDir = "$currentPath\$Version"
$signtoolPath = 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64\signtool.exe'
$timestampUrl = "http://timestamp.digicert.com"
$certificateThumbprint = $env:CERTIFICATE_THUMBPRINT

Write-Host "Current Dir: $currentDir"

function changeVersion {
    Get-Content -Path $currentDir\install.ps1 | ForEach-Object {
        $_ -replace "#__VERSION__", $Version
    } | Set-Content -Path $currentDir\install_tmp.ps1

    Remove-Item -Path $currentDir\install.ps1 -Force
    Rename-Item -Path $currentDir\install_tmp.ps1 -NewName $currentDir\install.ps1
}

changeVersion
& $signtoolPath sign /sha1 "$certificateThumbprint" /tr $timestampUrl /td sha256 /fd sha256 $currentDir\install.ps1
