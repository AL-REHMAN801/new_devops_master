# 🚀 Deployment Checklist

## What Needs to Be Pushed/Deployed?

### ✅ **STEP 1: Push Code to GitHub**

This is **required** if you want to use GitHub Actions CI/CD pipeline.

```powershell
# Navigate to project directory
cd E:\DEV\devops-multicloud-project

# Initialize Git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Complete DevOps Multi-Cloud Project"

# Create GitHub repository
# Option A: Using GitHub CLI
gh repo create devops-multicloud-project --public --source=. --remote=origin --push

# Option B: Manual (if you don't have GitHub CLI)
# 1. Go to https://github.com/new
# 2. Create repository named: devops-multicloud-project
# 3. Then run:
git remote add origin https://github.com/YOUR_USERNAME/devops-multicloud-project.git
git branch -M main
git push -u origin main
```

**What gets pushed to GitHub:**
- ✅ All Terraform files
- ✅ All Ansible files
- ✅ Sample application code
- ✅ Jenkinsfile
- ✅ GitHub Actions workflow
- ✅ All documentation
- ❌ **NOT pushed** (in .gitignore): node_modules, .terraform, credentials, secrets

---

### ✅ **STEP 2: Build and Push Docker Image**

You need to push the Docker image to a container registry so Kubernetes can pull it.

#### **Option A: Push to GitHub Container Registry (GHCR) - Recommended**

```powershell
# Navigate to sample app
cd E:\DEV\devops-multicloud-project\phase2-cicd\sample-app

# Install dependencies first
npm install

# Build Docker image
docker build -t devops-sample-app:latest .

# Login to GitHub Container Registry
# Create a Personal Access Token (PAT) first:
# Go to: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
# Create token with: write:packages, read:packages, delete:packages
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin

# Tag the image
docker tag devops-sample-app:latest ghcr.io/YOUR_GITHUB_USERNAME/devops-sample-app:latest

# Push to GHCR
docker push ghcr.io/YOUR_GITHUB_USERNAME/devops-sample-app:latest
```

#### **Option B: Push to DockerHub**

```powershell
# Login to DockerHub
docker login

# Tag the image
docker tag devops-sample-app:latest YOUR_DOCKERHUB_USERNAME/devops-sample-app:latest

# Push to DockerHub
docker push YOUR_DOCKERHUB_USERNAME/devops-sample-app:latest
```

#### **Option C: Let CI/CD Pipeline Do It (Easiest)**

If you push to GitHub and set up GitHub Actions, the pipeline will automatically:
1. Build the Docker image
2. Push to GHCR and DockerHub
3. Deploy to Kubernetes

**Just need to add these secrets to GitHub:**
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

---

### ✅ **STEP 3: Deploy Infrastructure with Terraform**

You need to deploy cloud infrastructure before deploying the application.

#### **Deploy to AWS**

```powershell
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\aws

# Update variables if needed
notepad variables.tf

# Initialize Terraform
terraform init

# Plan (review what will be created)
terraform plan

# Apply (create infrastructure)
terraform apply

# Save outputs
terraform output > aws-outputs.txt

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name devops-eks-cluster
```

**Time**: ~15-20 minutes  
**Cost**: ~$150/month

#### **Deploy to Azure**

```powershell
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\azure

# Update variables if needed
notepad variables.tf

# Initialize Terraform
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Save outputs
terraform output > azure-outputs.txt

# Configure kubectl
az aks get-credentials --resource-group devops-multicloud-rg --name devops-aks-cluster
```

**Time**: ~10-15 minutes  
**Cost**: ~$80/month

#### **Deploy to GCP**

```powershell
cd E:\DEV\devops-multicloud-project\phase1-iac\terraform\gcp

# IMPORTANT: Update project_id in variables.tf first!
notepad variables.tf
# Change: default = "your-actual-project-id"

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com

# Initialize Terraform
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Save outputs
terraform output > gcp-outputs.txt

# Configure kubectl
gcloud container clusters get-credentials devops-gke-cluster-dev --zone us-east1-b --project YOUR_PROJECT_ID
```

**Time**: ~15-20 minutes  
**Cost**: ~$145/month

---

### ✅ **STEP 4: Deploy Application to Kubernetes**

After infrastructure is ready and Docker image is pushed:

```powershell
cd E:\DEV\devops-multicloud-project\phase2-cicd\sample-app\k8s

# IMPORTANT: Update deployment.yaml with your image
notepad deployment.yaml
# Change line 21: image: ghcr.io/YOUR_USERNAME/devops-sample-app:latest

# Create image pull secret (if using private registry)
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_TOKEN

# Deploy to Kubernetes
kubectl apply -f deployment.yaml

# Check deployment
kubectl get deployments
kubectl get pods
kubectl get services

# Get external IP (may take 2-5 minutes)
kubectl get service devops-sample-app

# Test the application
# Once you have EXTERNAL-IP:
curl http://EXTERNAL-IP/health
```

---

### ✅ **STEP 5: Setup CI/CD Pipeline**

#### **Option A: GitHub Actions (Recommended)**

```powershell
# 1. Copy workflow to correct location
mkdir .github\workflows -Force
copy phase2-cicd\github-actions\.github\workflows\ci-cd.yml .github\workflows\

# 2. Add secrets to GitHub repository
# Go to: Repository → Settings → Secrets and variables → Actions → New repository secret

# Required secrets:
# - DOCKERHUB_USERNAME: your-dockerhub-username
# - DOCKERHUB_TOKEN: your-dockerhub-access-token
# - SONAR_TOKEN: your-sonarqube-token (optional, can skip SonarQube step)
# - SONAR_HOST_URL: https://sonarqube.example.com (optional)
# - KUBE_CONFIG: base64-encoded kubeconfig

# 3. Generate KUBE_CONFIG secret
kubectl config view --flatten --minify > kubeconfig.yaml
$content = Get-Content kubeconfig.yaml -Raw
$bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
$base64 = [Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard
# Now paste into GitHub secret

# 4. Commit and push
git add .github/workflows/ci-cd.yml
git commit -m "Add GitHub Actions CI/CD workflow"
git push

# 5. Pipeline will run automatically on push!
```

#### **Option B: Jenkins**

```powershell
# 1. Start Jenkins (if not running)
docker run -d -p 8080:8080 -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  --name jenkins `
  jenkins/jenkins:lts

# 2. Get initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# 3. Open http://localhost:8080 and complete setup

# 4. Install required plugins:
# - Docker Pipeline
# - Kubernetes
# - SonarQube Scanner

# 5. Add credentials in Jenkins:
# - dockerhub-credentials (Username/Password)
# - kubeconfig-file (Secret file)
# - sonarqube-token (Secret text)

# 6. Create Pipeline job:
# - New Item → Pipeline
# - Pipeline script from SCM
# - SCM: Git
# - Repository URL: https://github.com/YOUR_USERNAME/devops-multicloud-project.git
# - Script Path: phase2-cicd/jenkins/Jenkinsfile

# 7. Run the pipeline!
```

---

## 📋 **Quick Deployment Checklist**

### **Minimal Deployment (Just to Test)**

- [ ] 1. Install dependencies: `npm install` in sample-app
- [ ] 2. Build Docker image: `docker build -t devops-sample-app .`
- [ ] 3. Run locally: `docker run -p 3000:3000 devops-sample-app`
- [ ] 4. Test: Open http://localhost:3000

### **Cloud Deployment (One Cloud)**

- [ ] 1. Choose cloud (Azure is cheapest at ~$80/month)
- [ ] 2. Deploy infrastructure: `terraform apply`
- [ ] 3. Build and push Docker image to registry
- [ ] 4. Update deployment.yaml with image name
- [ ] 5. Deploy to Kubernetes: `kubectl apply -f deployment.yaml`
- [ ] 6. Get external IP: `kubectl get service`
- [ ] 7. Test application

### **Full CI/CD Setup**

- [ ] 1. Push code to GitHub
- [ ] 2. Add GitHub secrets (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN, KUBE_CONFIG)
- [ ] 3. Copy GitHub Actions workflow to .github/workflows/
- [ ] 4. Push workflow: `git push`
- [ ] 5. Pipeline runs automatically!

---

## 🎯 **Recommended Approach for You**

### **For Learning/Demo:**

```powershell
# 1. Test locally first
cd phase2-cicd/sample-app
npm install
npm test
docker build -t devops-sample-app .
docker run -p 3000:3000 devops-sample-app

# 2. Push to GitHub
cd E:\DEV\devops-multicloud-project
git init
git add .
git commit -m "Initial commit"
gh repo create devops-multicloud-project --public --source=. --push

# 3. Deploy to ONE cloud (Azure - cheapest)
cd phase1-iac/terraform/azure
terraform init
terraform apply

# 4. Build and push Docker image
cd ../../phase2-cicd/sample-app
docker build -t devops-sample-app .
docker tag devops-sample-app ghcr.io/YOUR_USERNAME/devops-sample-app:latest
docker push ghcr.io/YOUR_USERNAME/devops-sample-app:latest

# 5. Deploy to Kubernetes
kubectl apply -f k8s/deployment.yaml

# 6. Setup GitHub Actions
mkdir .github\workflows -Force
copy ../github-actions/.github/workflows/ci-cd.yml .github/workflows/
git add .github
git commit -m "Add CI/CD"
git push
```

---

## ⚠️ **Important Notes**

### **Before Pushing to GitHub:**
- ✅ .gitignore is already configured
- ✅ No credentials will be pushed
- ✅ Terraform state files excluded
- ✅ node_modules excluded

### **Before Deploying to Cloud:**
- ⚠️ **Set up billing alerts** on all clouds
- ⚠️ **Understand costs**: ~$80-$150/month per cloud
- ⚠️ **Use free tier** where possible
- ⚠️ **Destroy resources** when done: `terraform destroy`

### **Docker Registry:**
- **GHCR** (GitHub Container Registry): Free, integrated with GitHub
- **DockerHub**: Free for public images, rate limited
- **ECR/ACR/GCR**: Cloud-specific, costs apply

---

## 🔑 **Secrets You'll Need**

### **For GitHub Actions:**
1. **DOCKERHUB_USERNAME**: Your DockerHub username
2. **DOCKERHUB_TOKEN**: DockerHub access token (create at hub.docker.com)
3. **KUBE_CONFIG**: Base64-encoded kubeconfig (see Step 5)
4. **SONAR_TOKEN**: SonarQube token (optional)
5. **SONAR_HOST_URL**: SonarQube URL (optional)

### **For Cloud Providers:**
1. **AWS**: Access Key ID, Secret Access Key
2. **Azure**: Service Principal credentials
3. **GCP**: Service Account JSON key

---

## 🚀 **Next Steps**

1. **Decide your approach:**
   - Local testing only? → Just build Docker image
   - One cloud deployment? → Choose Azure (cheapest)
   - Full multi-cloud? → Deploy all three
   - CI/CD pipeline? → Push to GitHub

2. **Follow the checklist** for your chosen approach

3. **Monitor costs** on cloud providers

4. **Clean up** when done: `terraform destroy`

---

**Need help with any specific step? Let me know!** 🎯
