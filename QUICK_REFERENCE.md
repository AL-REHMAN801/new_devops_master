# Quick Reference Guide

## 🚀 Quick Commands

### Terraform

```powershell
# AWS
cd phase1-iac/terraform/aws
terraform init
terraform plan
terraform apply
terraform output
terraform destroy

# Azure
cd phase1-iac/terraform/azure
terraform init
terraform plan
terraform apply
terraform output
terraform destroy

# GCP
cd phase1-iac/terraform/gcp
terraform init
terraform plan
terraform apply
terraform output
terraform destroy
```

### Ansible

```powershell
cd phase1-iac/ansible

# Install Docker
ansible-playbook -i inventory/hosts playbooks/install-docker.yml

# Setup Users
ansible-playbook -i inventory/hosts playbooks/setup-users.yml

# Configure Kubernetes
ansible-playbook -i inventory/hosts playbooks/configure-k8s.yml

# Run on specific hosts
ansible-playbook -i inventory/hosts playbooks/install-docker.yml --limit aws_nodes
```

### Kubectl

```powershell
# Configure for AWS
aws eks update-kubeconfig --region us-east-1 --name devops-eks-cluster

# Configure for Azure
az aks get-credentials --resource-group devops-multicloud-rg --name devops-aks-cluster

# Configure for GCP
gcloud container clusters get-credentials devops-gke-cluster-dev --zone us-east1-b

# Common commands
kubectl get nodes
kubectl get pods
kubectl get services
kubectl get deployments
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml
```

### Docker

```powershell
cd phase2-cicd/sample-app

# Build
docker build -t devops-sample-app:latest .

# Run
docker run -p 3000:3000 devops-sample-app:latest

# Run in background
docker run -d -p 3000:3000 --name sample-app devops-sample-app:latest

# View logs
docker logs sample-app

# Stop
docker stop sample-app

# Remove
docker rm sample-app

# Push to registry
docker tag devops-sample-app:latest ghcr.io/USERNAME/devops-sample-app:latest
docker push ghcr.io/USERNAME/devops-sample-app:latest
```

### Application

```powershell
cd phase2-cicd/sample-app

# Install dependencies
npm install

# Run tests
npm test

# Run with coverage
npm test -- --coverage

# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Start application
npm start

# Development mode
npm run dev
```

## 📁 Important File Locations

### Configuration Files
- AWS Terraform: `phase1-iac/terraform/aws/`
- Azure Terraform: `phase1-iac/terraform/azure/`
- GCP Terraform: `phase1-iac/terraform/gcp/`
- Ansible: `phase1-iac/ansible/`
- Sample App: `phase2-cicd/sample-app/`
- Jenkinsfile: `phase2-cicd/jenkins/Jenkinsfile`
- GitHub Actions: `phase2-cicd/github-actions/.github/workflows/ci-cd.yml`

### Documentation
- Cloud Setup: `phase1-iac/documentation/cloud-setup-guide.md`
- Terraform Comparison: `phase1-iac/documentation/terraform-vs-competitors.md`
- Cost Analysis: `phase1-iac/documentation/cost-analysis.md`
- Artifact Management: `phase2-cicd/documentation/artifact-management-strategy.md`
- CI/CD Comparison: `phase2-cicd/documentation/cicd-tools-comparison.md`
- Performance Metrics: `phase2-cicd/documentation/performance-metrics.md`

### Guides
- Main README: `README.md`
- Execution Guide: `EXECUTION_GUIDE.md`
- Project Structure: `PROJECT_STRUCTURE.md`
- Project Summary: `PROJECT_SUMMARY.md`

## 🔑 Required Secrets

### GitHub Actions
Add these in: Repository Settings → Secrets and variables → Actions

- `DOCKERHUB_USERNAME`: Your DockerHub username
- `DOCKERHUB_TOKEN`: DockerHub access token
- `SONAR_TOKEN`: SonarQube authentication token
- `SONAR_HOST_URL`: SonarQube server URL
- `KUBE_CONFIG`: Base64-encoded kubeconfig

### Jenkins
Add these in: Manage Jenkins → Credentials

- `dockerhub-credentials`: Username/password for DockerHub
- `kubeconfig-file`: Kubeconfig file
- `sonarqube-token`: SonarQube token

## 🌐 Cloud CLI Authentication

### AWS
```powershell
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format
```

### Azure
```powershell
az login
az account set --subscription "Your Subscription Name"
```

### GCP
```powershell
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

## 📊 Monitoring Commands

### Check Pipeline Status
```powershell
# GitHub Actions
# Go to: https://github.com/USERNAME/REPO/actions

# Jenkins
# Go to: http://localhost:8080
```

### Check Application Health
```powershell
# Local
curl http://localhost:3000/health

# Kubernetes
kubectl get service devops-sample-app
# Get EXTERNAL-IP, then:
curl http://EXTERNAL-IP/health
```

### Check Resource Usage
```powershell
# Kubernetes pods
kubectl top pods

# Kubernetes nodes
kubectl top nodes

# Docker
docker stats
```

## 🧹 Cleanup Commands

### Stop Application
```powershell
# Kubernetes
kubectl delete -f phase2-cicd/sample-app/k8s/deployment.yaml

# Docker
docker stop sample-app
docker rm sample-app
```

### Destroy Infrastructure
```powershell
# AWS
cd phase1-iac/terraform/aws
terraform destroy

# Azure
cd phase1-iac/terraform/azure
terraform destroy

# GCP
cd phase1-iac/terraform/gcp
terraform destroy
```

### Clean Docker
```powershell
# Remove all containers
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi -f $(docker images -q)

# Clean up everything
docker system prune -a --volumes
```

## 🐛 Troubleshooting

### Terraform Issues
```powershell
# Refresh state
terraform refresh

# Re-initialize
rm -rf .terraform
terraform init

# Import existing resource
terraform import aws_vpc.main vpc-xxxxx
```

### Kubectl Issues
```powershell
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name devops-eks-cluster

# Check context
kubectl config current-context

# Switch context
kubectl config use-context CONTEXT_NAME

# View all contexts
kubectl config get-contexts
```

### Docker Issues
```powershell
# Check logs
docker logs CONTAINER_NAME

# Execute into container
docker exec -it CONTAINER_NAME /bin/sh

# Rebuild without cache
docker build --no-cache -t IMAGE_NAME .
```

## 📈 Cost Monitoring

### AWS
```powershell
# Check current month costs
aws ce get-cost-and-usage --time-period Start=2025-12-01,End=2025-12-31 --granularity MONTHLY --metrics BlendedCost
```

### Azure
```powershell
# Check costs
az consumption usage list --start-date 2025-12-01 --end-date 2025-12-31
```

### GCP
```powershell
# Check billing
gcloud billing accounts list
gcloud billing projects describe PROJECT_ID
```

## 🔗 Useful URLs

### Documentation
- Terraform: https://www.terraform.io/docs
- Ansible: https://docs.ansible.com/
- Kubernetes: https://kubernetes.io/docs/
- Docker: https://docs.docker.com/

### Cloud Providers
- AWS Console: https://console.aws.amazon.com/
- Azure Portal: https://portal.azure.com/
- GCP Console: https://console.cloud.google.com/

### Tools
- DockerHub: https://hub.docker.com/
- GitHub: https://github.com/
- SonarQube: https://www.sonarqube.org/

## 💡 Tips

1. **Always check costs** before deploying
2. **Set up billing alerts** on all clouds
3. **Use free tier** resources when possible
4. **Destroy resources** when not in use
5. **Keep credentials secure** - never commit to Git
6. **Test locally** before deploying to cloud
7. **Use version control** for all changes
8. **Document everything** you do
9. **Monitor resource usage** regularly
10. **Keep dependencies updated** for security

## 🎯 Next Steps

1. ✅ Review all documentation
2. ✅ Set up cloud accounts
3. ✅ Deploy infrastructure with Terraform
4. ✅ Configure servers with Ansible
5. ✅ Set up CI/CD pipeline
6. ✅ Deploy sample application
7. ✅ Monitor and optimize
8. ✅ Implement additional features
9. ✅ Clean up when done

---

**Quick Reference Version**: 1.0  
**Last Updated**: December 2025
