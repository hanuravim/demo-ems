param (
        [Parameter(Mandatory=$false)]
        [string]
        $ResourceGroupName='GAV-WE2-NET-SB-PRD-NET-SRD-01',

        [Parameter(Mandatory=$false)]
        [string]
        $SQLTemplateFileUri="https://raw.githubusercontent.com/hanuravim/demo-ems/master/ems-manager/masterTemplate.json"
)

# Authenticate to Azure if running from Azure Automation
$ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Login-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $ServicePrincipalConnection.TenantId `
    -ApplicationId $ServicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Write-Verbose

# Domain Join credential asset
$myCredential = Get-AutomationPSCredential -Name 'DomainJoinEfoqa'

# Template parameters
$Parameters = @{
    "DomainUserName"=$myCredential.UserName;
    "DomainPassword"=$myCredential.Password
    "adminPassword"="Testuser@123"
}

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $SQLTemplateFileUri -TemplateParameterObject $Parameters
