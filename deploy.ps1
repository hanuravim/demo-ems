#region Azure Login.
#Login-AzureRmAccount
#$Subscription              = Get-AzureRmSubscription | Out-GridView -Title "Select the Azure subscription..." -PassThru
#Select-AzureRmSubscription -SubscriptionId $Subscription.SubscriptionId
#endregion

#region Parameters
$RG_Name=           'hanu-poc-rg'
$location=          'eastus'
$parametersUri=     'https://raw.githubusercontent.com/hanuravim/demo-ems/master/parameters.json'
$masterTemplateUri= 'https://raw.githubusercontent.com/hanuravim/demo-ems/master/masterTemplate.json'

#Check or Create Resource group
Get-AzureRmResourceGroup -Name $RG_Name -ev notPresent -ea 0
if ($notPresent) { Write-Host "Failover RG '$RG_Name' does not exist.Creating new in $location..." -ForegroundColor Yellow
New-AzureRmResourceGroup -Name $RG_Name -Location $location
} else { Write-Host "Using existing resource group '$RG_Name'"-ForegroundColor Yellow ;}

#region deploy
New-AzureRmResourceGroupDeployment -ResourceGroupName $RG_Name -Mode Incremental -TemplateParameterFile $paramFile -TemplateUri $masterTemplateUri -Verbose
#endregion 
