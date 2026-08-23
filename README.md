# AKS 3-Tier Assignment Solution

This project implements a secure, reusable Helm deployment for a 3-tier app on AKS with Azure DevOps CI/CD.

Application layer status:
- Frontend and backend code are synced from the Jerney main branch.
- Backend is placed under the `api` folder for chart and pipeline alignment.
- Only Dockerfile dependency install lines were adjusted to support builds when package-lock files are absent.

## What Is Included

- Parent Helm chart with subcharts:
  - `frontend`
  - `api`
  - `postgres`
- `values.schema.json` to block invalid values and missing resource limits.
- Pre-install and pre-upgrade Helm hook Job for DB migration.
- Template conditionals to toggle frontend and postgres on or off.
- Shared helper templates for naming and ingress path conventions.
- Secret ingestion via Azure Key Vault Provider for Secrets Store CSI Driver.
- Azure Workload Identity annotations and service account wiring.
- NetworkPolicy to allow postgres ingress only from API pods.
- Ingress path routing:
  - `/` -> frontend
  - `/api` -> backend
- PostgreSQL with PVC.
- Azure DevOps pipeline for build, lint, and AKS deploy.

## Do I Need Docker or PostgreSQL Locally?

- Docker local install: optional.
- PostgreSQL local install: not required.
- If Azure DevOps builds images and deploys to AKS, local Docker/Postgres are not needed.

## Local Prerequisites

- Azure CLI
- kubectl
- Helm

## One-Time AKS Prerequisites

1. Enable OIDC and Workload Identity on AKS.
2. Install ingress-nginx.
3. Install Secrets Store CSI Driver and Azure Key Vault provider.
4. Create Key Vault secrets:
   - `db-user`
   - `db-password`
   - `db-name`
5. Grant Key Vault access to the user-assigned managed identity used by workload identity.

## Deploy Using Helm

```bash
helm dependency update helm/three-tier-app
helm lint helm/three-tier-app
helm upgrade --install three-tier helm/three-tier-app \
  --namespace three-tier --create-namespace \
  -f helm/three-tier-app/values.yaml \
  -f helm/three-tier-app/environments/values-dev.yaml
```

## Pipeline

File: `azure-pipelines.yml`

Pipeline stages:

1. Build and push API/frontend images to ACR.
2. Helm validation (`helm lint` + `helm template`).
3. Helm deploy to AKS.

Update service connections and variable values before running.

## Terraform Bootstrap and Infra

Two Terraform layers are included:

- `terraform/bootstrap`: creates remote state backend (resource group, storage account, container).
- `terraform/infra`: creates AKS, ACR, Key Vault, workload identity, federated credentials, and optional ingress addon.

### Local bootstrap run

```bash
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Save the output values:

- `resource_group_name`
- `storage_account_name`
- `container_name`

### Local infra run

1. Copy and edit variables.

```bash
cd terraform/infra
cp terraform.tfvars.example terraform.tfvars
```

2. Set unique names for:

- `acr_name`
- `key_vault_name`

3. Set DB values (`db_user`, `db_password`, `db_name`).

4. Initialize with backend settings from bootstrap outputs.

```bash
terraform init \
  -backend-config="resource_group_name=<bootstrap-rg>" \
  -backend-config="storage_account_name=<bootstrap-sa>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=infra-dev.tfstate"
terraform plan -out=tfplan
terraform apply tfplan
```

5. Optional addon deployment with Terraform:

- Set `enable_cluster_addons = true` in `terraform.tfvars`
- Re-run `terraform plan/apply`

This deploys:

- namespace `three-tier`
- ingress-nginx controller via Helm provider

## Azure DevOps Terraform Pipelines

Additional pipeline files are included:

- `azure-pipelines-bootstrap.yml`
- `azure-pipelines-infra.yml`

### Run order

1. Run `azure-pipelines-bootstrap.yml` first.
2. Copy bootstrap output storage account name into `tfStateStorageAccount` variable in `azure-pipelines-infra.yml` (or set it in pipeline variables).
3. Set `dbPassword` as a secret variable in Azure DevOps.
4. Run `azure-pipelines-infra.yml`.
