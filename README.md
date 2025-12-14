# DevOps Multi-Cloud Project 

A comprehensive DevOps project demonstrating Infrastructure as Code (IaC) and CI/CD implementation across AWS, Azure, and GCP.

## 📚 Documentation

**All guides and documentation are organized in the [`docs/`](docs/) folder!**

### Quick Links:
- 📖 [**Documentation Index**](docs/README.md) - Complete guide index
- 🚀 [**Execution Guide**](docs/EXECUTION_GUIDE.md) - Step-by-step deployment
- 🔑 [**Credentials Guide**](docs/CREDENTIALS_GUIDE.md) - Cloud setup (AWS, Azure, GCP)
- 🐳 [**Docker Desktop Guide**](docs/DOCKER_DESKTOP_GUIDE.md) - Local deployment
- ⚡ [**Quick Reference**](docs/QUICK_REFERENCE.md) - Common commands
- 🔧 [**Pipeline Fixed**](docs/PIPELINE_FIXED.md) - CI/CD troubleshooting

## 🎯 Quick Start

### Deploy to Docker Desktop (Fastest):
```powershell
.\deploy-docker.ps1
```
Then open: http://localhost:3000

## Project Structure

```
devops-multicloud-project/
├── docs/                    # 📚 All documentation
├── phase1-iac/
│   ├── terraform/
│   │   ├── aws/
│   │   ├── azure/
│   │   └── gcp/
│   ├── ansible/
│   │   ├── inventory/
│   │   └── playbooks/
│   └── documentation/
│       ├── cloud-setup-guide.md
│       ├── terraform-vs-competitors.md
│       └── cost-analysis.md
├── phase2-cicd/
│   ├── sample-app/
│   ├── jenkins/
│   ├── github-actions/
│   └── documentation/
│       ├── artifact-management-strategy.md
│       ├── cicd-tools-comparison.md
│       └── performance-metrics.md
└── README.md
```

## Phase 1: Environment Setup & IaC

### Prerequisites
- Terraform >= 1.0
- Ansible >= 2.9
- Cloud provider accounts (AWS, Azure, GCP)

### Quick Start - Terraform
```bash
# AWS
cd phase1-iac/terraform/aws
terraform init
terraform plan
terraform apply

# Azure
cd ../azure
terraform init
terraform plan
terraform apply

# GCP
cd ../gcp
terraform init
terraform plan
terraform apply
```

### Quick Start - Ansible
```bash
cd phase1-iac/ansible
ansible-playbook -i inventory/hosts playbooks/install-docker.yml
ansible-playbook -i inventory/hosts playbooks/setup-users.yml
ansible-playbook -i inventory/hosts playbooks/configure-k8s.yml
```

## Phase 2: CI/CD Pipeline Implementation

### Jenkins Pipeline
```bash
cd phase2-cicd/jenkins
# Copy Jenkinsfile to your Jenkins project
```

### GitHub Actions
```bash
cd phase2-cicd/github-actions
# Copy .github/workflows/ci-cd.yml to your repository
```

### Sample Application
```bash
cd phase2-cicd/sample-app
docker build -t sample-app:latest .
docker run -p 3000:3000 sample-app:latest
```

## Documentation

All research papers and documentation are available in:
- `phase1-iac/documentation/`
- `phase2-cicd/documentation/`

## Author

DevOps Multi-Cloud Project - 2025
