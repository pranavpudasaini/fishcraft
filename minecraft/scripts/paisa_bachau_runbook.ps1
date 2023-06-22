param
(
    [Parameter(Mandatory=$false)]
    [object] $WebhookData
)

$CredentialAssetName = 'DefaultAzureCredential'

#Get the credential with the above name from the Automation Asset store
$Cred = Get-AutomationPSCredential -Name $CredentialAssetName
if(!$Cred) {
    Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
}

#Connect to your Azure Account
$Account = Add-AzureAccount -Credential $Cred
if(!$Account) {
    Throw "Could not authenticate to Azure using the credential asset '${CredentialAssetName}'. Make sure the user name and password are correct."
}

#Get all the VMs you have in your Azure subscription
$VMs = Get-AzureVM

#Print out up to 10 of those VMs
if(!$VMs) {
    Write-Output "No VMs were found in your subscription."
} else {
    Write-Output $VMs[0]
}
