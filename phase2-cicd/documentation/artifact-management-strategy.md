# Artifact Management Strategy

## Executive Summary

This document outlines the comprehensive artifact management strategy for the DevOps Multi-Cloud project. It covers artifact types, storage solutions, versioning, retention policies, security, and best practices for managing build artifacts across the CI/CD pipeline.

**Key Components:**
- Docker images stored in container registries (DockerHub, GHCR, ECR, ACR, GCR)
- Build artifacts stored in cloud storage (S3, Azure Blob, GCS)
- Versioning using semantic versioning and Git SHA
- Automated cleanup and retention policies

---

## 1. Artifact Types

### 1.1 Container Images
**Description**: Docker images containing application code and dependencies

**Storage Locations**:
- **DockerHub**: Public and private repositories
- **GitHub Container Registry (GHCR)**: Integrated with GitHub
- **AWS ECR**: For AWS deployments
- **Azure Container Registry (ACR)**: For Azure deployments
- **Google Container Registry (GCR)**: For GCP deployments

**Naming Convention**:
```
<registry>/<organization>/<image-name>:<tag>
Example: ghcr.io/myorg/devops-sample-app:1.2.3
```

**Tags**:
- `latest`: Most recent production build
- `<version>`: Semantic version (e.g., 1.2.3)
- `<branch>-<sha>`: Branch name with Git SHA (e.g., main-abc1234)
- `<branch>`: Latest build from specific branch

### 1.2 Application Binaries
**Description**: Compiled application code, JAR files, executables

**Storage**: Cloud storage buckets with versioning enabled

**Examples**:
- Node.js: `node_modules` (not stored, rebuilt)
- Java: `.jar`, `.war` files
- Go: Compiled binaries
- Python: `.whl` packages

### 1.3 Test Reports
**Description**: Unit test results, coverage reports, integration test outputs

**Storage**: 
- Jenkins: Workspace artifacts
- GitHub Actions: Workflow artifacts
- Long-term: S3/Blob/GCS

**Retention**: 30 days for test reports

### 1.4 Security Scan Results
**Description**: Trivy vulnerability reports, SonarQube analysis

**Storage**: 
- Trivy: JSON/SARIF reports in artifacts
- SonarQube: SonarQube server database

**Retention**: 90 days minimum for compliance

### 1.5 Infrastructure as Code
**Description**: Terraform state files, Ansible playbooks

**Storage**:
- Terraform state: S3/Azure Blob/GCS with state locking
- Playbooks: Git repository

**Versioning**: Git-based versioning

---

## 2. Storage Solutions

### 2.1 Container Registries

#### DockerHub
**Pros**:
- Industry standard
- Easy to use
- Good free tier

**Cons**:
- Rate limiting on free tier
- Pull limits

**Configuration**:
```yaml
# GitHub Actions
- name: Login to DockerHub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

**Retention Policy**:
- Keep last 10 versions of each tag
- Delete untagged images after 7 days

#### GitHub Container Registry (GHCR)
**Pros**:
- Integrated with GitHub
- No rate limits for authenticated users
- Free for public repositories

**Cons**:
- Requires GitHub authentication

**Configuration**:
```yaml
- name: Login to GHCR
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

**Retention Policy**:
- Keep all tagged versions
- Delete untagged images after 14 days

#### Cloud Provider Registries

**AWS ECR**:
```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

**Azure ACR**:
```bash
az acr login --name myregistry
```

**GCP GCR**:
```bash
gcloud auth configure-docker
```

### 2.2 Object Storage

#### AWS S3
**Use Cases**:
- Build artifacts
- Test reports
- Terraform state

**Configuration**:
```hcl
# Terraform backend
terraform {
  backend "s3" {
    bucket         = "devops-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
```

**Lifecycle Policy**:
```json
{
  "Rules": [{
    "Id": "DeleteOldArtifacts",
    "Status": "Enabled",
    "Expiration": {
      "Days": 90
    },
    "NoncurrentVersionExpiration": {
      "NoncurrentDays": 30
    }
  }]
}
```

#### Azure Blob Storage
**Use Cases**: Same as S3

**Configuration**:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "terraformstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

#### Google Cloud Storage
**Use Cases**: Same as S3

**Configuration**:
```hcl
terraform {
  backend "gcs" {
    bucket = "devops-terraform-state"
    prefix = "prod"
  }
}
```

---

## 3. Versioning Strategy

### 3.1 Semantic Versioning

**Format**: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

**Examples**:
- `1.0.0`: Initial release
- `1.1.0`: New feature added
- `1.1.1`: Bug fix
- `2.0.0`: Breaking change

### 3.2 Git-Based Versioning

**Git Tags**:
```bash
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin v1.2.3
```

**Automated Versioning in CI/CD**:
```yaml
# GitHub Actions
- name: Get version from tag
  id: version
  run: |
    if [[ $GITHUB_REF == refs/tags/* ]]; then
      echo "version=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT
    else
      echo "version=${GITHUB_SHA::8}" >> $GITHUB_OUTPUT
    fi
```

### 3.3 Build Metadata

**Include in artifact**:
- Git commit SHA
- Build number
- Build timestamp
- Branch name

**Example Docker label**:
```dockerfile
LABEL version="1.2.3" \
      git.commit="abc1234" \
      build.number="42" \
      build.date="2025-12-12"
```

---

## 4. Retention Policies

### 4.1 Container Images

| Environment | Retention Period | Policy |
|-------------|------------------|--------|
| Production | Indefinite | Keep all tagged releases |
| Staging | 90 days | Keep last 20 versions |
| Development | 30 days | Keep last 10 versions |
| Feature branches | 7 days | Delete after merge |

### 4.2 Build Artifacts

| Artifact Type | Retention Period | Storage Location |
|---------------|------------------|------------------|
| Release builds | 1 year | S3 Glacier |
| Nightly builds | 30 days | S3 Standard |
| PR builds | 7 days | S3 Standard |
| Test reports | 90 days | S3 Standard |

### 4.3 Automated Cleanup

**Docker Registry Cleanup Script**:
```bash
#!/bin/bash
# Delete untagged images older than 7 days
docker images -f "dangling=true" -q | xargs docker rmi

# Delete old images
docker images | grep "days ago" | awk '{print $3}' | xargs docker rmi
```

**S3 Lifecycle Policy** (see section 2.2)

---

## 5. Security

### 5.1 Access Control

**Principle of Least Privilege**:
- CI/CD pipelines: Write access to registries
- Developers: Read access to registries
- Production: Pull-only access

**IAM Policies**:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ],
    "Resource": "arn:aws:ecr:*:*:repository/devops-*"
  }]
}
```

### 5.2 Encryption

**At Rest**:
- S3: SSE-S3 or SSE-KMS
- Azure Blob: Azure Storage Service Encryption
- GCS: Google-managed encryption keys

**In Transit**:
- HTTPS for all registry communications
- TLS 1.2+ required

### 5.3 Vulnerability Scanning

**Automated Scanning**:
- Trivy: Scan on every build
- Fail pipeline on CRITICAL vulnerabilities
- Weekly scans of production images

**Example**:
```yaml
- name: Run Trivy scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'myimage:latest'
    severity: 'CRITICAL,HIGH'
    exit-code: '1'
```

---

## 6. Best Practices

### 6.1 Immutability

**Never overwrite artifacts**:
- Each build gets unique version
- Use Git SHA for uniqueness
- Prevent tag mutation in registries

**Registry Configuration**:
```yaml
# Prevent tag overwriting
immutable_tags: true
```

### 6.2 Traceability

**Artifact Metadata**:
```json
{
  "version": "1.2.3",
  "git_commit": "abc1234567890",
  "build_number": "42",
  "build_date": "2025-12-12T10:30:00Z",
  "builder": "github-actions",
  "tests_passed": true,
  "security_scan": "passed"
}
```

### 6.3 Multi-Region Replication

**For High Availability**:
- Replicate critical images to multiple regions
- Use registry mirroring
- Implement pull-through cache

**AWS ECR Replication**:
```hcl
resource "aws_ecr_replication_configuration" "main" {
  replication_configuration {
    rule {
      destination {
        region      = "us-west-2"
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}
```

### 6.4 Bandwidth Optimization

**Strategies**:
- Use multi-stage Docker builds
- Leverage build cache
- Implement layer caching
- Use registry pull-through cache

**Example**:
```dockerfile
# Multi-stage build
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

FROM node:18-alpine
COPY --from=builder /app /app
```

---

## 7. Monitoring and Metrics

### 7.1 Key Metrics

- **Storage Usage**: Track artifact storage growth
- **Pull Frequency**: Monitor image pull rates
- **Build Success Rate**: Track artifact creation success
- **Scan Results**: Monitor vulnerability trends

### 7.2 Alerting

**Set up alerts for**:
- Storage quota approaching limits
- Failed artifact uploads
- Critical vulnerabilities detected
- Unusual pull patterns (security)

---

## 8. Disaster Recovery

### 8.1 Backup Strategy

**Critical Artifacts**:
- Production images: Replicated to 3 regions
- Terraform state: Versioned with backups
- Configuration: Git repository (multiple remotes)

### 8.2 Recovery Procedures

**Image Recovery**:
1. Identify required version from Git tag
2. Rebuild from source if not in registry
3. Restore from backup registry

**State Recovery**:
1. Restore Terraform state from S3 versioning
2. Verify state integrity
3. Re-apply if necessary

---

## Conclusion

This artifact management strategy ensures:
- ✅ Reliable artifact storage and retrieval
- ✅ Proper versioning and traceability
- ✅ Security and compliance
- ✅ Cost optimization through retention policies
- ✅ High availability through replication

**Next Steps**:
1. Implement automated cleanup policies
2. Set up monitoring and alerting
3. Document recovery procedures
4. Train team on artifact management

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Maintained By**: DevOps Team  
**Pages**: 2
