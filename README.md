# 3-Tier Web Application on AKS

This project deploys a 3-tier blogging application on **Azure Kubernetes Service (AKS)** using Helm.

The application consists of:

* React frontend
* Node.js API
* PostgreSQL database
* NGINX Ingress
* Azure Key Vault for secrets
* Azure Workload Identity
* Terraform for infrastructure
* Azure DevOps for CI/CD

## Architecture

```text
                    Internet
                       |
                    HTTPS
                       |
                NGINX Ingress
                 /           \
                /             \
          React UI         Node.js API
                                |
                           PostgreSQL
                                |
                               PVC
```

The frontend is available at `/` and API requests are routed through `/api`.

## Helm Structure

The application uses a parent Helm chart with separate subcharts for each tier.

```text
helm/three-tier-app/
├── Chart.yaml
├── values.yaml
├── values.schema.json
├── templates/
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── migration-job.yaml
│   └── serviceaccount.yaml
└── charts/
    ├── frontend/
    ├── api/
    └── postgres/
```

`values.schema.json` is used to validate Helm values and ensures resource requests and limits are provided.

Frontend, API and PostgreSQL deployments can also be enabled or disabled through Helm values.

## Database Migration

A Kubernetes Job is configured as a Helm:

```text
pre-install
pre-upgrade
```

hook to simulate database migration before application deployment/upgrade.

## Security

Database credentials are stored in **Azure Key Vault** instead of being hardcoded in the Helm charts.

```text
Azure Key Vault
      |
Secrets Store CSI Driver
      |
Kubernetes Secret
      |
Node.js API
      |
PostgreSQL
```

The workloads use **Azure Workload Identity**, so static Azure credentials are not stored inside the pods.

A Kubernetes `NetworkPolicy` restricts PostgreSQL access to the API tier on port `5432`.

## PostgreSQL Storage

PostgreSQL uses a PersistentVolumeClaim so database data is retained when the pod is recreated.

## Ingress

NGINX provides path-based routing:

```text
/       -> React frontend
/api    -> Node.js API
```

The application is exposed through HTTPS.

## CI/CD

Azure DevOps pipelines are used to build the application images, push them to Azure Container Registry and deploy the Helm release to AKS.

Terraform is used for provisioning the Azure infrastructure.

## Deployment Verification

Useful commands:

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get pvc
kubectl get networkpolicy
```

Helm validation:

```bash
helm lint helm/three-tier-app
helm template three-tier helm/three-tier-app
```

## Screenshots

### Application

<img width="1907" height="871" alt="image" src="https://github.com/user-attachments/assets/5ba844ab-220f-4bea-bf54-ddde3a37ff2c" />


### AKS Resources
<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/eba05708-ca44-4a0e-9d3d-d82e85181d75" />

<img width="1905" height="967" alt="image" src="https://github.com/user-attachments/assets/5bdb3a00-74f2-4267-a218-c764ececbd23" />

<img width="1245" height="196" alt="image" src="https://github.com/user-attachments/assets/9efdd4d1-5964-41dc-a2cb-83ba7e339165" />

<img width="1870" height="941" alt="image" src="https://github.com/user-attachments/assets/690a671a-3528-4abf-91bd-bd4e024cb743" />


### Azure DevOps Pipeline

<img width="1895" height="978" alt="image" src="https://github.com/user-attachments/assets/e65c8da7-edfb-42c7-9821-cdc8e91f5ecb" />


### PostgreSQL PVC and NetworkPolicy

<img width="1672" height="540" alt="image" src="https://github.com/user-attachments/assets/473ae5de-b333-433a-9b12-740db2f11696" />



### Azure Key Vault

<img width="1892" height="865" alt="image" src="https://github.com/user-attachments/assets/eaf7501f-6145-459a-9056-13c9a55e9a94" />


## Tech Stack

**Azure | AKS | Kubernetes | Helm | Terraform | Azure DevOps | Docker | NGINX | Azure Key Vault | React | Node.js | PostgreSQL**
