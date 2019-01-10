Param (
  [Parameter()]
  [String]$SAKey
  [String]$SAName
)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Azure -Confirm:$False
Import-Module Azure

#$storageContext = New-AzureStorageContext -StorageAccountName $SAName -StorageAccountKey $SAKey
#$storageContext |  New-AzureStorageShare -Name 'azurefileshare'

cmdkey /add:$SAName.file.core.windows.net /user:$SAName /pass:$SAKey
net use F: \\$SAName.file.core.windows.net\azurefileshare
