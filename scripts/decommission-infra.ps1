param(
    [Parameter(Mandatory = $true)]
    [string]$Decommission,

    [Parameter(Mandatory = $true)]
    [string]$StateResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$StateStorageAccount,

    [Parameter(Mandatory = $true)]
    [string]$StateContainer,

    [Parameter(Mandatory = $true)]
    [string]$StateKey
)

$ErrorActionPreference = 'Stop'

if ($Decommission -ne 'true') {
    throw 'Infrastructure decommission was not explicitly enabled.'
}

Push-Location (Join-Path $PSScriptRoot '..\terraform\infra')
try {
    terraform init -input=false `
        "-backend-config=resource_group_name=$StateResourceGroup" `
        "-backend-config=storage_account_name=$StateStorageAccount" `
        "-backend-config=container_name=$StateContainer" `
        "-backend-config=key=$StateKey"

    terraform destroy -auto-approve -input=false
}
finally {
    Pop-Location
}
