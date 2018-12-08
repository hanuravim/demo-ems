param (
        [Parameter(Mandatory=$false)]
        [string]
        $ResourceGroupName='autoems',

        [Parameter(Mandatory=$false)]
        [string]
        $SQLTemplateFileUri="https://raw.githubusercontent.com/hanuravim/demo-ems/master/SQL/masterTemplate.json",

        [Parameter(Mandatory=$false)]
        [string]
        $SQLParameterFileUri="https://raw.githubusercontent.com/hanuravim/demo-ems/master/SQL/masterTemplate.parameters.json"
        )

# Authenticate to Azure if running from Azure Automation
$ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Connect-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $ServicePrincipalConnection.TenantId `
    -ApplicationId $ServicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Write-Verbose

# Domain Join credential asset
$myCredential = Get-AutomationPSCredential -Name 'DomainJoin'

# Template parameters
$Parameters = @{
    "DomainUsername"=$myCredential.UserName;
    "DomainPassword"=$myCredential.GetNetworkCredential().Password
}

# Deploy SQL Servers
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $SQLTemplateFileUri -TemplateParameterObject $Parameters
