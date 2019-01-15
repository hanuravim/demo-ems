param (
        [Parameter(Mandatory=$false)]
        [string]
        $ResourceGroupName='fa-dr-poc',

        [Parameter(Mandatory=$false)]
        [string]
        $TemplateUri="https://raw.githubusercontent.com/hanuravim/demo-ems/master/ems-manager/deploy.json",

        [Parameter(Mandatory=$false)]
        [string]
        $ParameterUri="https://raw.githubusercontent.com/hanuravim/demo-ems/master/ems-manager/deploy.parameters.json"
)

# Authenticate to Azure if running from Azure Automation
$ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Login-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $ServicePrincipalConnection.TenantId `
    -ApplicationId $ServicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Write-Verbose

# Domain Join credential asset
$myCredential = Get-AutomationPSCredential -Name 'DomainAdmin'

# Template parameters
$Parameters = @{
    "DomainUserName"=$myCredential.UserName;
    "DomainPassword"=$myCredential.Password
    "adminPassword"="Testuser@123"
}

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateUri -TemplateParameterUri $ParameterUri
