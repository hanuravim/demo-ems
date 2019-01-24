Param (
  [Parameter()]
  [String]$SAKey,
  [String]$SAName,
  [String]$AzureFileShareName
)

#MOUNT AZURE FILE SHARE
$acctKey = ConvertTo-SecureString -String $SAKey -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$SAName", $acctKey
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$SAName.file.core.windows.net\$AzureFileShareName" -Credential $credential -Persist 

#DISABLE WINDOWS DEFENDER
Set-MpPreference -DisableRealtimeMonitoring $true
#################################################
#DISABLE AUTO UPDATES
Stop-Service -Name "wuauserv" -Force
#################################################
