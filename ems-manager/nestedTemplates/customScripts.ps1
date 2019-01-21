#CREATE AZURE FILE SHARE
Param (
  [Parameter()]
  [String]$SAKey,
  [String]$SAName,
  [String]$share
)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Azure -Confirm:$False
Import-Module Azure
$storageContext = New-AzureStorageContext -StorageAccountName $SAName -StorageAccountKey $SAKey
$storageContext |  New-AzureStorageShare -Name $share

cmdkey /add:$SAName.file.core.windows.net /user:$SAName /pass:$SAKey
net use K: \\$SAName.file.core.windows.net\$share /u:$SAName $SAKey /persistent:yes

#DISABLE WINDOWS DEFENDER
Set-MpPreference -DisableRealtimeMonitoring $true
#################################################
#DISABLE AUTO UPDATES
Stop-Service -Name "wuauserv" -Force
#################################################

