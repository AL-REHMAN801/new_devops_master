# Multi-Cloud Setup Guide: AWS, Azure, and GCP Free Tier

## Table of Contents
1. [AWS Free Tier Setup](#aws-free-tier-setup)
2. [Azure Free Tier Setup](#azure-free-tier-setup)
3. [GCP Free Tier Setup](#gcp-free-tier-setup)
4. [CLI Tools Installation](#cli-tools-installation)
5. [Authentication Configuration](#authentication-configuration)

---

## AWS Free Tier Setup

### Account Creation
1. **Navigate to AWS**: Visit [aws.amazon.com/free](https://aws.amazon.com/free)
2. **Create Account**: Click "Create a Free Account"
3. **Provide Details**:
   - Email address
   - Password
   - AWS account name
4. **Contact Information**: Enter personal or business details
5. **Payment Method**: Add credit/debit card (won't be charged for free tier usage)
6. **Identity Verification**: Complete phone verification
7. **Select Support Plan**: Choose "Basic Support - Free"

### Free Tier Limits (12 months)
- **EC2**: 750 hours/month of t2.micro or t3.micro instances
- **S3**: 5GB standard storage
- **RDS**: 750 hours/month of db.t2.micro, db.t3.micro, or db.t4g.micro
- **EKS**: Control plane costs apply ($0.10/hour)
- **VPC**: Free (data transfer charges may apply)

### Post-Setup Configuration
```bash
# Install AWS CLI
# Windows (PowerShell)
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Configure credentials
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)
```

### Create IAM User for Terraform
1. Go to IAM Console → Users → Add User
2. Username: `terraform-user`
3. Access type: Programmatic access
4. Attach policies: `AdministratorAccess` (for demo; restrict in production)
5. Save Access Key ID and Secret Access Key

---

## Azure Free Tier Setup

### Account Creation
1. **Navigate to Azure**: Visit [azure.microsoft.com/free](https://azure.microsoft.com/free)
2. **Start Free**: Click "Start free"
3. **Sign In**: Use Microsoft account or create new one
4. **About You**: Enter personal information
5. **Identity Verification**: Phone and credit card verification
6. **Agreement**: Accept terms and click "Sign up"

### Free Tier Limits (12 months + Always Free)
- **Virtual Machines**: 750 hours/month of B1S instances
- **Blob Storage**: 5GB LRS hot block blob storage
- **SQL Database**: 250GB storage
- **AKS**: Free cluster management (pay for nodes)
- **VNet**: Free (bandwidth charges may apply)

### Post-Setup Configuration
```bash
# Install Azure CLI
# Windows (PowerShell)
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# Login
az login

# Set subscription (if multiple)
az account set --subscription "Your Subscription Name"
```

### Create Service Principal for Terraform
```bash
# Create service principal
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"

# Output will contain:
# - appId (client_id)
# - password (client_secret)
# - tenant (tenant_id)
```

---

## GCP Free Tier Setup

### Account Creation
1. **Navigate to GCP**: Visit [cloud.google.com/free](https://cloud.google.com/free)
2. **Get Started**: Click "Get started for free"
3. **Sign In**: Use Google account
4. **Country & Terms**: Select country and accept terms
5. **Account Type**: Choose "Individual" or "Business"
6. **Payment Method**: Add credit card (won't be charged without upgrade)
7. **Free Trial**: Receive $300 credit for 90 days

### Free Tier Limits (Always Free)
- **Compute Engine**: 1 f1-micro instance/month (US regions)
- **Cloud Storage**: 5GB standard storage
- **Cloud SQL**: db-f1-micro instance (up to 30GB storage)
- **GKE**: One zonal cluster free (pay for nodes)
- **VPC**: Free (egress charges may apply)

### Post-Setup Configuration
```bash
# Install gcloud CLI
# Windows: Download from https://cloud.google.com/sdk/docs/install

# Initialize gcloud
gcloud init

# Login
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable storage-api.googleapis.com
```

### Create Service Account for Terraform
```bash
# Create service account
gcloud iam service-accounts create terraform-sa --display-name "Terraform Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"

# Create and download key
gcloud iam service-accounts keys create ~/terraform-key.json \
  --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

---

## CLI Tools Installation

### Terraform Installation
```bash
# Windows (using Chocolatey)
choco install terraform

# Or download from terraform.io
# Verify installation
terraform --version
```

### Ansible Installation
```bash
# Windows (using WSL or Python pip)
pip install ansible

# Verify installation
ansible --version
```

---

## Authentication Configuration

### AWS Credentials
Create `~/.aws/credentials`:
```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

### Azure Credentials
Set environment variables:
```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

### GCP Credentials
Set environment variable:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/terraform-key.json"
```

---

## Cost Monitoring Setup

### AWS
1. Go to AWS Billing Dashboard
2. Enable "Free Tier Usage Alerts"
3. Set billing alarms in CloudWatch

### Azure
1. Go to Cost Management + Billing
2. Set up budgets and alerts
3. Enable cost analysis

### GCP
1. Go to Billing → Budgets & alerts
2. Create budget with email notifications
3. Set threshold alerts at 50%, 90%, 100%

---

## Security Best Practices

1. **Enable MFA** on all root/admin accounts
2. **Use IAM roles** instead of root credentials
3. **Rotate keys** regularly
4. **Implement least privilege** access
5. **Enable audit logging** (CloudTrail, Azure Monitor, Cloud Audit Logs)
6. **Set up billing alerts** to avoid unexpected charges

---

## Troubleshooting

### Common Issues

**AWS CLI not recognized**
- Add AWS CLI to PATH environment variable
- Restart terminal

**Azure login fails**
- Clear cache: `az account clear`
- Try: `az login --use-device-code`

**GCP authentication errors**
- Verify GOOGLE_APPLICATION_CREDENTIALS path
- Check service account permissions
- Ensure APIs are enabled

---

## Next Steps

After completing the setup:
1. Verify CLI access to all three clouds
2. Create test resources manually to understand the services
3. Proceed to Terraform infrastructure deployment
4. Configure Ansible inventory with your resources

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Maintained By**: DevOps Team
