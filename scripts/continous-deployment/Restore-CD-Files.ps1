# Used to restore objects in your hosted Xperience by Kentico website
# Use this file in your deployment pipeline after you have deployed your 

$TargetLocation = '<PATH_TO_WEBSITE_ROOT_DIRECTORY>'
$XbyKWebsiteDllFileName = '<YOUR_XBYK_WEBSITE_ASSEMBLY>.dll'
$CDRepositoryLocation = "$TargetLocation\App_Data\CDRepository"
$lockDirName = ".lock"

Write-Output "Deleting CDRepository directory contents..."
Get-ChildItem -Path $CDRepositoryLocation -Recurse | Where-Object {
    $_.FullName -notlike "*\$lockDirName*"
} | Remove-Item -Recurse -Force
Write-Output "CDRepository directory contents successfully deleted"

# If you zipped up the CD files in conjunction with the Store-CD-Files powershell script, ensure you uncomment the below 3 lines
# Write-Output "Unzipping CDRepository.zip..."
# Expand-Archive -Path "$TargetLocation\App_Data\CDRepository.zip" -DestinationPath "$CDRepositoryLocation"
# Write-Output "CDRepository.zip successfully extracted"

Write-Output "Restoring CD repository..."
Set-Location -Path $TargetLocation
dotnet $XbyKWebsiteDllFileName --kxp-cd-restore --repository-path "$CDRepositoryLocation"
Write-Output "Restoring CD repository..."
