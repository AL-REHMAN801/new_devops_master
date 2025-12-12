# DevOps Multi-Cloud Project - Complete Execution Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Phase 1: Infrastructure as Code](#phase-1-infrastructure-as-code)
3. [Phase 2: CI/CD Pipeline](#phase-2-cicd-pipeline)
4. [Troubleshooting](#troubleshooting)
5. [Cleanup](#cleanup)

---

## Prerequisites

### Required Tools

Install the following tools before proceeding:

#### 1. Terraform
```powershell
# Windows (using Chocolatey)
choco install terraform

# Verify installation
terraform --version
```

#### 2. Ansible
```powershell
# Windows (using WSL or Python pip)
pip install ansible

# Verify installation
ansible --version
```

#### 3. Cloud CLI Tools

**AWS CLI**:
```powershell
# Download and install from https://aws.amazon.com/cli/
# Or use Chocolatey
choco install awscli

# Configure
aws configure
```

**Azure CLI**:
```powershell
# Download and install from https://aka.ms/installazurecliwindows
# Or use Chocolatey
choco install azure-cli

# Login
az login
```

**Google Cloud SDK**:
```powershell
# Download from https://cloud.google.com/sdk/docs/install
# Initialize
gcloud init
```

#### 4. kubectl
```powershell
choco install kubernetes-cli

# Verify
kubectl version --client
```

#### 5. Docker
```powershell
# Install Docker Desktop for Windows
# Download from https://www.docker.com/products/docker-desktop

# Verify
docker --version
```

#### 6. Node.js (for sample app)
```powershell
choco install nodejs

# Verify
node --version
npm --version
```

---

## Phase 1: Infrastructure as Code

### Step 1: Cloud Account Setup

Follow the guide in `phase1-iac/documentation/cloud-setup-guide.md` to:
1. Create AWS free tier account
2. Create Azure free tier account
3. Create GCP free tier account
4. Configure CLI authentication

### Step 2: Deploy AWS Infrastructure

```powershell
# Navigate to AWS Terraform directory
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\aws

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Save outputs
terraform output > outputs.txt
```

**Expected Resources Created**:
- VPC with public and private subnets
- Internet Gateway and NAT Gateway
- EKS cluster with node group
- S3 bucket
- RDS MySQL instance

**Estimated Time**: 15-20 minutes  
**Estimated Cost**: ~$150/month (EKS control plane: $73, EC2 nodes: ~$30, RDS: ~$15, NAT: ~$32)

**Configure kubectl for AWS**:
```powershell
# Get the command from Terraform output
aws eks update-kubeconfig --region us-east-1 --name devops-eks-cluster

# Verify
kubectl get nodes
```

### Step 3: Deploy Azure Infrastructure

```powershell
# Navigate to Azure Terraform directory
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\azure

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Save outputs
terraform output > outputs.txt
```

**Expected Resources Created**:
- Resource Group
- Virtual Network with subnets
- AKS cluster
- Storage Account with blob container
- SQL Server and Database

**Estimated Time**: 10-15 minutes  
**Estimated Cost**: ~$80/month (AKS: free control plane, VMs: ~$30, SQL: ~$5, Storage: ~$1)

**Configure kubectl for Azure**:
```powershell
# Get the command from Terraform output
az aks get-credentials --resource-group devops-multicloud-rg --name devops-aks-cluster

# Verify
kubectl get nodes
```

### Step 4: Deploy GCP Infrastructure

**Important**: Update `variables.tf` with your GCP project ID first!

```powershell
# Navigate to GCP Terraform directory
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\gcp

# Edit variables.tf and set your project_id
# variable "project_id" {
#   default = "your-actual-project-id"
# }

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Save outputs
terraform output > outputs.txt
```

**Expected Resources Created**:
- VPC network with subnet
- GKE cluster with node pool
- Cloud Storage bucket
- Cloud SQL MySQL instance

**Estimated Time**: 15-20 minutes  
**Estimated Cost**: ~$145/month (GKE: $73, Compute: ~$25, Cloud SQL: ~$10, Storage: ~$1)

**Configure kubectl for GCP**:
```powershell
# Get the command from Terraform output
gcloud container clusters get-credentials devops-gke-cluster-dev --zone us-east1-b --project your-project-id

# Verify
kubectl get nodes
```

### Step 5: Configure Ansible Inventory

```powershell
cd E:\DEV\devops-multicloud-project\phase1-iac\ansible

# Edit inventory/hosts file
# Add your EC2, Azure VM, and GCP VM IP addresses
notepad inventory\hosts
```

Example:
```ini
[aws_nodes]
aws-node-1 ansible_host=3.80.123.45

[azure_nodes]
azure-node-1 ansible_host=20.120.45.67

[gcp_nodes]
gcp-node-1 ansible_host=35.190.12.34
```

### Step 6: Run Ansible Playbooks

**Install Docker**:
```powershell
ansible-playbook -i inventory/hosts playbooks/install-docker.yml
```

**Setup Users**:
```powershell
# First, update SSH keys in playbooks/setup-users.yml
ansible-playbook -i inventory/hosts playbooks/setup-users.yml
```

**Configure Kubernetes**:
```powershell
ansible-playbook -i inventory/hosts playbooks/configure-k8s.yml
```

**Estimated Time**: 10-15 minutes per playbook

---

## Phase 2: CI/CD Pipeline

### Step 1: Prepare Sample Application

```powershell
cd E:\DEV\devops-multicloud-project\phase2-cicd\sample-app

# Install dependencies
npm install

# Run tests locally
npm test

# Build Docker image locally
docker build -t devops-sample-app:local .

# Test the container
docker run -p 3000:3000 devops-sample-app:local

# Test the application
# Open browser to http://localhost:3000
# Or use curl
curl http://localhost:3000/health
```

### Step 2: Setup GitHub Repository

```powershell
# Initialize Git repository (if not already done)
cd E:\DEV\devops-multicloud-project
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: DevOps Multi-Cloud Project"

# Create GitHub repository (via GitHub CLI or web interface)
gh repo create devops-multicloud-project --public

# Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/devops-multicloud-project.git
git branch -M main
git push -u origin main
```

### Step 3: Configure GitHub Actions

**Required Secrets** (Settings → Secrets and variables → Actions):

1. **DOCKERHUB_USERNAME**: Your DockerHub username
2. **DOCKERHUB_TOKEN**: DockerHub access token
3. **SONAR_TOKEN**: SonarQube token (if using SonarQube)
4. **SONAR_HOST_URL**: SonarQube server URL
5. **KUBE_CONFIG**: Base64-encoded kubeconfig file

**Generate kubeconfig secret**:
```powershell
# Get kubeconfig
kubectl config view --flatten --minify > kubeconfig.yaml

# Base64 encode (for GitHub secret)
$content = Get-Content kubeconfig.yaml -Raw
$bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
$base64 = [Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard
# Now paste into GitHub secret
```

**Copy GitHub Actions workflow**:
```powershell
# The workflow file is already in the correct location
# phase2-cicd/github-actions/.github/workflows/ci-cd.yml

# Copy to repository root
mkdir .github\workflows -Force
copy phase2-cicd\github-actions\.github\workflows\ci-cd.yml .github\workflows\

# Commit and push
git add .github/workflows/ci-cd.yml
git commit -m "Add GitHub Actions CI/CD workflow"
git push
```

### Step 4: Setup Jenkins (Optional)

**Install Jenkins**:
```powershell
# Using Docker
docker run -d -p 8080:8080 -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  --name jenkins `
  jenkins/jenkins:lts
```

**Initial Setup**:
1. Get initial admin password:
   ```powershell
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
2. Open http://localhost:8080
3. Install suggested plugins
4. Create admin user

**Required Plugins**:
- Docker Pipeline
- Kubernetes
- SonarQube Scanner
- Blue Ocean (optional, for better UI)

**Configure Jenkins**:
1. **Credentials**:
   - Add DockerHub credentials (ID: `dockerhub-credentials`)
   - Add kubeconfig file (ID: `kubeconfig-file`)
   - Add SonarQube token (ID: `sonarqube-token`)

2. **Create Pipeline Job**:
   - New Item → Pipeline
   - Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your GitHub repo
   - Script Path: `phase2-cicd/jenkins/Jenkinsfile`

### Step 5: Deploy Application to Kubernetes

**Create Kubernetes manifests**:
```powershell
cd E:\DEV\devops-multicloud-project\phase2-cicd\sample-app

# Create deployment.yaml
@"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-sample-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: devops-sample-app
  template:
    metadata:
      labels:
        app: devops-sample-app
    spec:
      containers:
      - name: devops-sample-app
        image: ghcr.io/YOUR_USERNAME/devops-sample-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: production
---
apiVersion: v1
kind: Service
metadata:
  name: devops-sample-app
spec:
  type: LoadBalancer
  selector:
    app: devops-sample-app
  ports:
  - port: 80
    targetPort: 3000
"@ | Out-File -FilePath deployment.yaml -Encoding UTF8

# Apply to Kubernetes
kubectl apply -f deployment.yaml

# Check deployment
kubectl get deployments
kubectl get pods
kubectl get services

# Get external IP (may take a few minutes)
kubectl get service devops-sample-app
```

### Step 6: Verify CI/CD Pipeline

**Trigger Pipeline**:
```powershell
# Make a change to the application
cd E:\DEV\devops-multicloud-project\phase2-cicd\sample-app

# Edit server.js (add a comment or change version)
notepad server.js

# Commit and push
git add .
git commit -m "Test CI/CD pipeline"
git push
```

**Monitor Pipeline**:
- GitHub Actions: Go to repository → Actions tab
- Jenkins: Go to Jenkins dashboard → Your job

**Expected Pipeline Flow**:
1. ✅ Code Quality Check (1-2 min)
2. ✅ SonarQube Analysis (2-3 min)
3. ✅ Run Tests (1-2 min)
4. ✅ Build Docker Image (2-3 min)
5. ✅ Security Scan with Trivy (30-60 sec)
6. ✅ Push to Registry (10-30 sec)
7. ✅ Deploy to Kubernetes (1-2 min)

**Total Time**: ~8-12 minutes

---

## Troubleshooting

### Common Issues

#### Terraform Issues

**Issue**: "Error creating VPC: VpcLimitExceeded"
```powershell
# Solution: Delete unused VPCs or request limit increase
aws ec2 describe-vpcs
aws ec2 delete-vpc --vpc-id vpc-xxxxx
```

**Issue**: "Error: Kubernetes cluster unreachable"
```powershell
# Solution: Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name devops-eks-cluster
```

#### Ansible Issues

**Issue**: "SSH connection failed"
```powershell
# Solution: Check SSH key and security groups
# Ensure port 22 is open in security groups
# Verify SSH key path in inventory file
```

#### Docker Issues

**Issue**: "Docker build fails with 'npm install' error"
```powershell
# Solution: Clear npm cache
docker build --no-cache -t devops-sample-app:latest .
```

#### Kubernetes Issues

**Issue**: "ImagePullBackOff"
```powershell
# Solution: Check image name and registry credentials
kubectl describe pod <pod-name>

# Create image pull secret if needed
kubectl create secret docker-registry ghcr-secret `
  --docker-server=ghcr.io `
  --docker-username=YOUR_USERNAME `
  --docker-password=YOUR_TOKEN
```

#### CI/CD Issues

**Issue**: "SonarQube Quality Gate failed"
```powershell
# Solution: Check SonarQube dashboard for issues
# Fix code quality issues or adjust quality gate
```

**Issue**: "Trivy scan fails with critical vulnerabilities"
```powershell
# Solution: Update dependencies
npm audit fix
npm update
```

---

## Cleanup

### Destroy Infrastructure

**AWS**:
```powershell
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\aws
terraform destroy
```

**Azure**:
```powershell
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\azure
terraform destroy
```

**GCP**:
```powershell
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\gcp
terraform destroy
```

**Estimated Time**: 10-15 minutes per cloud

### Clean Up Docker

```powershell
# Remove containers
docker rm -f $(docker ps -aq)

# Remove images
docker rmi -f $(docker images -q)

# Clean up volumes
docker volume prune -f
```

### Clean Up Local Files

```powershell
# Remove Terraform state files (optional)
cd E:\DEV\devops-multicloud-project
Remove-Item -Recurse -Force phase1-iac\terraform\*\.terraform
Remove-Item -Recurse -Force phase1-iac\terraform\*\*.tfstate*
```

---

## Cost Monitoring

### Set Up Billing Alerts

**AWS**:
1. Go to AWS Billing Dashboard
2. Billing Preferences → Enable "Receive Free Tier Usage Alerts"
3. CloudWatch → Create Billing Alarm

**Azure**:
1. Cost Management + Billing
2. Budgets → Create budget
3. Set alert at 80% of budget

**GCP**:
1. Billing → Budgets & alerts
2. Create budget
3. Set threshold alerts

### Estimated Monthly Costs

| Cloud | Free Tier | Actual Cost |
|-------|-----------|-------------|
| AWS | ~$10 | ~$150 |
| Azure | ~$10 | ~$80 |
| GCP | ~$10 | ~$145 |
| **Total** | **~$30** | **~$375** |

**Note**: Costs can be reduced significantly by:
- Using spot/preemptible instances
- Stopping resources when not in use
- Using smaller instance types
- Leveraging free tiers

---

## Next Steps

1. ✅ Review all documentation in `phase1-iac/documentation/`
2. ✅ Review all documentation in `phase2-cicd/documentation/`
3. ✅ Customize Terraform variables for your needs
4. ✅ Update Ansible playbooks with your SSH keys
5. ✅ Configure monitoring and alerting
6. ✅ Set up log aggregation (ELK, Splunk, etc.)
7. ✅ Implement backup and disaster recovery
8. ✅ Add more comprehensive tests
9. ✅ Implement blue-green or canary deployments
10. ✅ Set up service mesh (Istio, Linkerd)

---

## Support and Resources

### Documentation
- AWS: https://docs.aws.amazon.com/
- Azure: https://docs.microsoft.com/azure/
- GCP: https://cloud.google.com/docs
- Terraform: https://www.terraform.io/docs
- Ansible: https://docs.ansible.com/
- Kubernetes: https://kubernetes.io/docs/

### Community
- Stack Overflow
- Reddit: r/devops, r/kubernetes
- Discord: DevOps communities
- Slack: Kubernetes, CNCF

---

**Guide Version**: 1.0  
**Last Updated**: December 2025  
**Maintained By**: DevOps Team
