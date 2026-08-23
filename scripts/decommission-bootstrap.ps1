param(
    [Parameter(Mandatory = $true)]
    [bool]$Decommission,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [string]$SubscriptionId
)

$ErrorActionPreference = 'Stop'

if (-not $Decommission) {
    throw 'Bootstrap decommission was not explicitly enabled.'
}

if ($SubscriptionId) {
    az account set --subscription $SubscriptionId
}

Push-Location (Join-Path $PSScriptRoot '..\terraform\bootstrap')
try {
    terraform init -input=false
    if (Test-Path 'terraform.tfstate') {
        terraform destroy -auto-approve -input=false
    }
}
finally {
    Pop-Location
}

if (az group exists --name $ResourceGroupName | Select-String -Pattern 'true') {
    az group delete --name $ResourceGroupName --yes --no-wait
    Write-Host "Bootstrap resource group deletion started: $ResourceGroupName"
}
else {
    Write-Host "Bootstrap resource group does not exist: $ResourceGroupName"
}
