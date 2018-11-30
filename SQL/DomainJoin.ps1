Param 
    (    
      [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()]
      [String] 
      $AzureSubscriptionId, 
      [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()]
      [String] 
      $CredentialAsset
    )
      $credential = Get-AutomationPSCredential -Name $CredentialAsset 
      Login-AzureRmAccount -Credential $credential 
      Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId 
