# Used to generate and store Xperience by Kentico objects in your local development environment CD repository
# Place this file in the root of your Xperience by Kentico website project

Write-Output "Creating CDRepository files..."

dotnet run --no-build -- --kxp-cd-store --repository-path "$PSScriptRoot\App_Data\CDRepository"

# If your build server runs on Windows Server 2012 or older, uncomment the below line to create a zip of the CD files to avoid hitting the 255 file path max character length issue 
# Compress-Archive -Path "$PSScriptRoot\App_Data\CDRepository\@global", "$PSScriptRoot\App_Data\CDRepository\repository.config" -DestinationPath "$PSScriptRoot\App_Data\CDRepository.zip" -Force

Write-Output "CDRepository files successfully created"
