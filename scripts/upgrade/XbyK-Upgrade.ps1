# Script used in the deployment pipeline to upgrade Xperience by Kentico to the same version as that of the deployed Xperience by Kentico assemblies

$TargetLocation = '<PATH_TO_WEBSITE_ROOT_DIRECTORY>'
$XbyKWebsiteDllFileName = '<YOUR_XBYK_WEBSITE_ASSEMBLY>.dll'

function Get-ConnectionString
{
    $appSettingsPath = "$TargetLocation\appsettings.json"

    if (Test-Path $appSettingsPath)
    {
        $appSettings = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
        if ($appSettings.ConnectionStrings -and $appSettings.ConnectionStrings.CMSConnectionString)
        {
            return $appSettings.ConnectionStrings.CMSConnectionString
        }
    }

    Write-Error "Connection string not found in any appsettings files"
    return $null
}

function Invoke-SQLQuery {
    param (
        [string]$query
    )

    $connectionString = Get-ConnectionString

    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $sqlConnection.Open()

    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = $query
    $result = $sqlCommand.ExecuteScalar()

    $sqlConnection.Close()
    return $result
}

$currentXbyKDBVersion = ''

$selectQuery = "SELECT TOP (1) KeyValue FROM CMS_SettingsKey WHERE KeyName = N'CMSDBVersion'"

try {
    $currentXbyKDBVersion = Invoke-SQLQuery($selectQuery)
    if ($currentXbyKDBVersion -match '^\d{2}\.\d\.\d$')
    {
        Write-Host "Current Xperience by Kentico version: $currentXbyKDBVersion"
    }
    else
    {
        Write-Error "Version format is invalid: $currentXbyKDBVersion"
    }
}
catch {
    Write-Error "Unable to retrieve current Xperience by Kentico version from the database $_.Exception.Message"
}

$dllVersion = ''

try
{
    $dllPath = Get-ChildItem -Path $TargetLocation -Filter 'Kentico.Xperience*.dll' -Recurse -ErrorAction Stop | Select-Object -First 1

    if ($dllPath)
    {
        $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($dllPath.FullName)
        $dllVersion = $versionInfo.ProductVersion
        Write-Host "Xperience by Kentico version being deployed: $dllVersion"
    }
    else
    {
        Write-Error "No DLL file starting with 'Kentico.Xperience' found in the current directory."
    }
}
catch
{
    Write-Error "Error occurred while searching for DLL file: $_.Exception.Message"
}

if ([version]$dllVersion -gt [version]$currentXbyKDBVersion)
{
    
    Write-Host "Upgrading Xperience by Kentico from $currentXbyKDBVersion to $dllVersion"
    Set-Location -Path $TargetLocation
    dotnet $XbyKWebsiteDllFileName --kxp-update --skip-confirmation
    Write-Host "Upgrade complete"
}
else
{
    Write-Host "No update needed. Current Xperience by Kentico version is up to date."
}