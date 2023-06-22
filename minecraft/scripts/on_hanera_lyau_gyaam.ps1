Workflow Start-Stop-AzureVM 
{ 
  Param 
  (    
    [Parameter(Mandatory=$false)]
    [object] $WebhookData
  ) 

  # $Values = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)

  # $AzureSubscriptionId = $Values.AzureSubscriptionId
  # $AzureVMList = $Values.AzureVMList
  # $Action = $Values.Action

  $AzureSubscriptionId = "b5e90f4f-4cf3-4858-8adc-4e9cb7e4fb51"
  $AzureVMList = "minecraft-vm"
  $Action = "Start"

  Write-Output $AzureSubscriptionId
  Write-Output $AzureVMList
  Write-Output $Action

  $credential = Get-AutomationPSCredential -Name 'AzureCredential' 
  Login-AzureRmAccount -Credential $credential 
  Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId 
 
  if($AzureVMList -ne "All") 
  { 
    $AzureVMs = $AzureVMList.Split(",") 
    [System.Collections.ArrayList]$AzureVMsToHandle = $AzureVMs 
  } else 
  { 
    $AzureVMs = (Get-AzureRmVM).Name 
    [System.Collections.ArrayList]$AzureVMsToHandle = $AzureVMs 
 
  } 
 
  foreach($AzureVM in $AzureVMsToHandle) 
  { 
    if(!(Get-AzureRmVM | ? {$_.Name -eq $AzureVM})) 
    { 
      throw " AzureVM : [$AzureVM] - Does not exist! - Check your inputs " 
    } 
  } 
 
  if($Action -eq "Stop") 
  { 
    Write-Output "Stopping VMs"; 
    foreach -parallel ($AzureVM in $AzureVMsToHandle) 
    { 
      Get-AzureRmVM | ? {$_.Name -eq $AzureVM} | Stop-AzureRmVM -Force 
    } 
  } else 
  { 
    Write-Output "Starting VMs"; 
    foreach -parallel ($AzureVM in $AzureVMsToHandle) 
    { 
      Get-AzureRmVM | ? {$_.Name -eq $AzureVM} | Start-AzureRmVM 
    } 
  } 
}

