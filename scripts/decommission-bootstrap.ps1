param(
    [Parameter(Mandatory = $true)]
    [string]$Decommission,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [string]$SubscriptionId
)

$ErrorActionPreference = 'Stop'

if ($Decommission -ne 'true') {
    throw 'Bootstrap decommission was not explicitly enabled.'
}

if ($SubscriptionId) {
    az account set --subscription $SubscriptionId
}

$exists = az group exists --name $ResourceGroupName
if ($exists -eq 'true') {
    az group delete --name $ResourceGroupName --yes
    Write-Host "Bootstrap resource group deleted: $ResourceGroupName"
}
else {
    Write-Host "Bootstrap resource group does not exist: $ResourceGroupName"
}
