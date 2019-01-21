#CREATE AZURE FILE SHARE
Param (
  [Parameter()]
  [String]$SAKey='GL9JGze0oCXgOq1j0TiSa8CQ/Rz/Mrlo9c1ZXNaVM84L9bjSj2b3xxAQgzfXfUHD+x44YfsvyzNupYtN29Aynw==',
  [String]$SAName='emscusbdevemsstr001',
  [String]$share = 'azrfileshare'
)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Azure -Confirm:$False
Import-Module Azure
$storageContext = New-AzureStorageContext -StorageAccountName $SAName -StorageAccountKey $SAKey
$storageContext |  New-AzureStorageShare -Name azrfileshare

cmdkey /add:$SAName.file.core.windows.net /user:$SAName /pass:$SAKey
net use K: \\$SAName.file.core.windows.net\$share /u:$SAName $SAKey /persistent:yes

#DISABLE WINDOWS DEFENDER
Set-MpPreference -DisableRealtimeMonitoring $true
#################################################
#DISABLE AUTO UPDATES
Stop-Service -Name "wuauserv" -Force
#################################################

