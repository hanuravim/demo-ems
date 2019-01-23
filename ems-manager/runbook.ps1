$AutomationAccount = 'fa-dr-poc-automation'
$RunbookName = 'AzureFileShare'
$TemplateUri="https://raw.githubusercontent.com/hanuravim/demo-ems/master/ems-manager/deploy.json"

# Authenticate to Azure if running from Azure Automation
$ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Login-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $ServicePrincipalConnection.TenantId `
    -ApplicationId $ServicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Write-Verbose

# Domain Join credential asset
$DomainCredential = Get-AutomationPSCredential -Name 'DomainAdmin1'
$LocalCredential = Get-AutomationPSCredential -Name 'LocalAdmin'

# Template parameters
$Parameters = @{"DomainUserName"=$DomainCredential.UserName;"DomainPassword"=$DomainCredential.Password;
"adminUsername"=$LocalCredential.UserName;"adminPassword"=$LocalCredential.Password}

#Deploy EMS Manager
New-AzureRmDeployment -Location 'westus2'  -TemplateFile $TemplateUri  -TemplateParameterObject $Parameters

#Configure Azure File Share
$AutomationRGNAme = (Get-AzureRmAutomationAccount | Where {$_.AutomationAccountName -like $AutomationAccount}).ResourceGroupName
Start-AzureRmAutomationRunbook –AutomationAccountName $AutomationAccount –Name $RunbookName -ResourceGroupName $AutomationRGNAme
