![Alt Text](https://github.com/lann87/cloud_infra_eng_ntu_coursework_alanp/blob/main/.misc/ntu_logo.png)  

# CE7 Group 2 Capstone Project  

**Team Members:**  

1. **Alan Peh**  
2. **Andy Liew**  
3. **Azmi Maniku**  
4. **Lovell Tan**  
5. **Wong Teck Choy**  

## Project Objectives

1. Build a health tips/information Web Application
2. Containerize Web App using Docker. Store content in AWS DynamoDB and access via AWS Lambda.
3. Deploy AWS infrastructure using Terraform
4. Implement CI/CD pipeline using Github Actions by building infrastructure, conduct tests on Terraform, k8s, Python code and Dockerfiles. Automate deployment from test to production
5. Deploy to AWS EKS for container orchestration

## Architecture Diagram

![ce7-grp-2-capstone-architecture (1) drawio](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone1.png)

## Dev/UAT/Prod Github Branch strategy  

![git branch2](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone2.jpg)
Image from Valaxy Technologies.  

### Pros and Cons of Dev/UAT/Prod Branch Strategy  

**Pros**  

- **Simplicity**: This strategy is straightforward, making it easier for teams to understand and implement. Developers can work directly in the DEV branch, and changes flow through UAT to PROD without complex branching structures.
- **Continuous Development**: Development can continue uninterrupted during releases, as new features can be worked on in the DEV branch while UAT and PROD are being updated.
- **Clear Environment Segregation**: Each branch corresponds to a specific environment (DEV for development, UAT for testing, PROD for production), which helps maintain clarity about what code is being tested or deployed.
- **Hotfix Management**: The strategy allows for quick hotfixes directly to the PROD branch without disrupting ongoing development.
  
**Cons**  

- **Limited Control Over Releases**: If multiple features are in development, it can be challenging to release only certain features if others are not ready. This can lead to delays or the need for complex merges.  
- **Potential for Code Drift**: Continuous merging into DEV could lead to integration issues if not managed properly, as features might not be tested together until later stages.  
- **Less Granular Control**: Compared to GitFlow, this strategy may provide less control over which features are included in each release since it typically promotes all changes from DEV to UAT at once.  

### Pros and Cons of GitFlow  

**Pros**  

- **Structured Release Process**: GitFlow offers a more structured approach with dedicated branches for features, releases, and hotfixes, allowing teams to manage releases more granularly.  
- **Isolation of Features**: Each feature can be developed in isolation on its own branch, reducing the risk of conflicts and making it easier to manage complex projects with multiple features being developed simultaneously.  
- **Selective Merging**: Teams can cherry-pick which features to promote to production by merging specific branches rather than merging everything from DEV at once. This allows for more control over what goes live.  
  
**Cons**  

- **Complexity**: The additional branches and rules can complicate the workflow, especially for smaller teams or projects. New team members may find it harder to navigate compared to simpler strategies like Dev, UAT, Prod.  
- **Slower Release Cycles**: The structured nature of GitFlow may slow down the release process since features must go through multiple branches and approvals before reaching production.  
- **Overhead Management**: Managing multiple branches requires more overhead in terms of maintaining them and ensuring they are up-to-date with the latest changes from other branches.  

### Conclusion  

The Dev/UAT/Prod strategy is beneficial for small teams like ours seeking simplicity and continuous development on smaller projects.
It may lack the granularity of control offered by GitFlow, which provides a robust framework suitable for larger projects.
However, Gitflow introduces additional complexity that may not be necessary for all teams.
We are also implementing some continuous deployment by automatically merging dev branch to uat branch after a PR is successfully pushed to dev branch.
Moving from uat branch to prod branch will be a manual pull request.

## Branch Security

The following branch security was implemented to ensure the integrity of the repository:

1. Require pull request + Minimum 1 review approval before merging
2. No force pushes allowed
3. No force deletions allowed
![image](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone3.png)

## OpenID Connect (OIDC)  

### Advantages

**GitHub OpenID Connect (OIDC)** allows GitHub Actions to authenticate with cloud providers securely. Rather than storing a permanent AWS access key ID and secret access key, OIDC enables use of temporary credentials to access AWS.
![image](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone4.png)

GitHub OpenID Connect (OIDC) offers several advantages for CI/CD workflows:  

1. **Elimination of Long-Lived Secrets**  
    - OIDC removes the need for storing long-lived cloud credentials in GitHub, reducing the risk of credential exposure.  
2. **Enhanced Security with Temporary Credentials**  
    - Tokens are short-lived, minimizing the impact of any potential compromise since they expire quickly.  
3. **Simplified Credential Management**  
    - OIDC streamlines credential management by eliminating the need for manual rotation and updates, leading to increased efficiency.  
4. **Improved Access Control**  
    - Organizations can define specific permissions for access tokens, enhancing security by ensuring only authorized workflows can access resources.  
5. **Seamless Integration with Cloud Providers**  
    - OIDC supports multiple cloud providers, allowing teams to deploy applications without changing authentication methods.  
6. **Better Compliance with Security Standards**  
    - Adopting OIDC helps organizations align with security best practices, minimizing the use of long-lived credentials.  
  
### Summary

OIDC eliminates the need for all team members to share a set of access keys/credentials and reduces access management workload. Hence we chose to integrate OIDC in our workflow.  
Potential areas for improvement: Restrict Access to different resources created based on specific user roles (IAM) that authenticate using OIDC.

### Implementation

Create a IAM Role in AWS with required aws permissions and a trust relationship for github.
![image](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone5.png)

> [!CAUTION]
> We have used Administrator Access for this role for ease of use in this capstone project.
> However, best practice would be to use principle of least privilege and only give access to the required aws resources.

<details>

Trust Relationship:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<redacted>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:latcaa-ce-ntu/ce7-grp-2-capstone:*"
                }
            }
        }
    ]
}
```

Create a github actions secret `ROLE_TO_ASSUME` with the arn of the IAM role.

**Github Actions permissions:**  

```yml
permissions:
  id-token: write # This is required for requesting the JWT

```

configure-aws-credentials action:

```yml
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.AWS_REGION }}
          audience: sts.amazonaws.com
          role-to-assume: ${{ secrets.ROLE_TO_ASSUME }}
```

</details>

## Containerization & Container Management

### Container Orchestration Solution

Initially, the team considered deploying the containerized web app to AWS Elastic Constainer Service (ECS) given the relatively small scale of the project and lack of experience with EKS.  

However, understanding that AWS Elastic Kubernetes Service (EKS) tends to be the industry standard and offers greater customization flexibility, EKS was eventually selected as the Container Orchestration Solution for the project.  

### Container Registry selection

We have decided to use github container registry (ghcr) for this project instead of other options like AWS Elastic Container Registry (ECR) or Docker Hub.
Following are some advantages of using ghcr:

1. **Cost Efficiency**
    - Free for Open Source: GHCR is free for public repositories, making it ideal for open-source projects, while ECR can incur costs for private repositories.
2. **Seamless Integration with GitHub**
    - CI/CD Support: Direct integration with GitHub Actions simplifies the automation of building and deploying container images.
3. **No Pull Limits**
    - Relaxed Rate Limits: GHCR allows unlimited pulls, reducing the risk of deployment delays compared to Docker Hub's rate limits.
4. **Simplified Authentication**
    - Personal Access Tokens: Easier authentication through personal access tokens compared to the more complex AWS IAM policies used by ECR.
5. **Multi-Architecture Support**
    - Automatic Image Selection: Supports multi-architecture images, allowing automatic selection based on CPU architecture.
6. **User-Friendly Interface**
    - Familiarity: Provides a familiar interface for GitHub users, reducing the learning curve and increasing productivity.
7. **Flexibility in Image Management**
    - Tagging and Versioning: Offers flexible tagging and versioning, essential for continuous integration and delivery practices.

In summary, GHCR provides significant advantages in cost, integration, ease of use, and flexibility, making it a strong choice for developers leveraging GitHub.

### Secrets Management

We are using Github Actions Secrets for all of our secrets in this repo for ease of integration with Github Actions workflow. Moreover, third-party secret management tools are unnecessary as the number of secrets need to be stored is small.  

### Environment handling

We are not using terraform workspaces for this project because we do not want to create a vpc and eks for each workspace (and increase costs).
Instead we re-use the same vpc and eks cluster. Then use kubernetes namespaces (dev/uat/prod) to separate the environments respectively.
Understandably, in a large enough organization, it will be prudent to separate the cloud infra into different environments.
However, for our small capstone project, we have opted to save on costs of running multiple eks clusters.

### Kubernetes Cluster - Key Setup Features

#### Auto-scaling

By default, 2 worker nodes are running at all times to ensure steady performance. However this can be auto-scaled up or down to 1-3 nodes depending on workload.  

<details>
  
```sh
  # Configure auto-scaling for nodes
  scaling_config {
    desired_size = 2 # Normal running nodes
    max_size     = 3 # Maximum during high load
    min_size     = 1 # Minimum to maintain
    }
```

</details>

#### Security - Logging & S3

Logs from the Application Load Balancer were activated and stored in an S3 bucket. Some security measures implemented for logs include:

1. Blocking Public Access to s3 bucket
2. Server-Side Encryption (SSE) - All objects stored in S3 bucket are encrypted using AES-256 encryption by default
3. Enabling Versioning on S3 bucket - allows older versions of logs to be accessed easily for auditing/monitoring/troubleshooting
4. S3 bucket policy that allows only the specific ALB service account from us-east-1 region to write and upload logs into the bucket.

<details>
  
```sh
# Block all public access to the bucket for security 
resource "aws_s3_bucket_public_access_block" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  block_public_acls       = true # Prevent public ACLs
  block_public_policy     = true # Prevent public bucket policies  
  ignore_public_acls      = true # Ignore any public ACLs
  restrict_public_buckets = true # Restrict public bucket access
}

# Enable server-side encryption for all objects
resource "aws_s3_bucket_server_side_encryption_configuration" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Use AES-256 encryption
    }
  }
}

# Enable versioning to maintain log history
resource "aws_s3_bucket_versioning" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Configure bucket policy to allow ALB to write logs
resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root" # AWS ALB service account for us-east-1
        }
        Action = [
          "s3:PutObject" # Allow writing objects (logs)
        ]
        Resource = "${aws_s3_bucket.lb_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com" # ALB log delivery service
        }
        Action = [
          "s3:PutObject" # Allow writing objects (logs)
        ]
        Resource = "${aws_s3_bucket.lb_logs.arn}/*"
      }
    ]
  })
}
```

</details>

#### Security - IAM

Distinct IAM roles were created for EKS cluster and worker nodes on a needs-only basis, ensuring clear boundaries for permissions and minimizing potential risks.

1. EKS cluster role  

- Allows EKS to manage AWS resources

2. Node role  

- Allows EC2 Instances/EKS worker nodes to access AWS services; namely to
- interact with the EKS cluster and manage workloads
- access network functionalities
- pull container images from ECR
  
<details>
  
```sh
# Create IAM role for EKS cluster management
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.name_prefix}-eks-cluster-role"

  # Trust policy - defines who can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach required EKS cluster policy to cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create IAM role for EKS worker nodes
resource "aws_iam_role" "eks_node_role" {
  name = "${var.name_prefix}-eks-node-role"

  # Trust policy for EC2 instances (worker nodes)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach required policies to node role
# Worker node policy - basic node operations
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

# CNI policy - networking functionality
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# Container registry policy - allows pulling images from ECR
resource "aws_iam_role_policy_attachment" "eks_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}
```

</details>

#### Security - Environment Separation and Role segregation

Upon creation of EKS cluster, the clusters are further organized into 3 separate namespaces - **dev**, **uat** and **prod** - to achieve separate environments for our deployments/services/apps.

<details> 

```sh
# Create namespaces to organize our applications
resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}

resource "kubernetes_namespace" "uat" {
  metadata {
    name = "uat"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}
```
</details>


Separate IAM roles - **app_role_dev**, **app_role_uat**, **app_role_prod** were also created and can only be assumed by specific service accounts **ce7-grp2-sa-app-dev**, **ce7-grp2-sa-app-uat** and **ce7-grp2-sa-app-prod** respectively through OpenID Connect (OIDC) authentication. 
If needed, each IAM role can be further configured to restrict access to AWS services depending on each role's needs. 

<details> 

```sh
# Create IAM roles that can be assumed by Kubernetes service accounts
resource "aws_iam_role" "app_role_dev" {
  name = "${var.name_prefix}-app-role-dev"

  # Trust policy allowing Kubernetes service accounts to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        # Use OIDC provider for secure authentication
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          # Ensure only our specific service account can assume this role
          "${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:applications:${var.name_prefix}-sa-app-dev"
        }
      }
    }]
  })
}

# Create IAM roles that can be assumed by Kubernetes service accounts
resource "aws_iam_role" "app_role_uat" {
  name = "${var.name_prefix}-app-role-uat"

  # Trust policy allowing Kubernetes service accounts to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        # Use OIDC provider for secure authentication
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          # Ensure only our specific service account can assume this role
          "${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:applications:${var.name_prefix}-sa-app-uat"
        }
      }
    }]
  })
}

# Create IAM role that can be assumed by Kubernetes service accounts
resource "aws_iam_role" "app_role_prod" {
  name = "${var.name_prefix}-app-role-prod"

  # Trust policy allowing Kubernetes service accounts to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        # Use OIDC provider for secure authentication
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          # Ensure only our specific service account can assume this role
          "${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:applications:${var.name_prefix}-sa-app-prod"
        }
      }
    }]
  })
}

# Create Kubernetes service account for our application
resource "kubernetes_service_account" "dev_service_account" {
  metadata {
    name      = "${var.name_prefix}-sa-app-dev"
    namespace = kubernetes_namespace.dev.metadata[0].name
    annotations = {
      # Link to IAM role for AWS permissions
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role_dev.arn
    }
  }

  # Add GitHub container registry credentials
  # image_pull_secret {
  #   name = kubernetes_secret.ghcr_auth.metadata[0].name
  # }

  depends_on = [
    kubernetes_namespace.dev,
    aws_iam_role.app_role_dev
  ]
}

# Create Kubernetes service account for our application
resource "kubernetes_service_account" "uat_service_account" {
  metadata {
    name      = "${var.name_prefix}-sa-app-uat"
    namespace = kubernetes_namespace.uat.metadata[0].name
    annotations = {
      # Link to IAM role for AWS permissions
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role_uat.arn
    }
  }

  # Add GitHub container registry credentials
  # image_pull_secret {
  #   name = kubernetes_secret.ghcr_auth.metadata[0].name
  # }

  depends_on = [
    kubernetes_namespace.uat,
    aws_iam_role.app_role_uat
  ]
}

# Create Kubernetes service account for our application
resource "kubernetes_service_account" "prod_service_account" {
  metadata {
    name      = "${var.name_prefix}-sa-app-prod"
    namespace = kubernetes_namespace.prod.metadata[0].name
    annotations = {
      # Link to IAM role for AWS permissions
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role_prod.arn
    }
  }

  # Add GitHub container registry credentials
  # image_pull_secret {
  #   name = kubernetes_secret.ghcr_auth.metadata[0].name
  # }

  depends_on = [
    kubernetes_namespace.prod,
    aws_iam_role.app_role_prod
  ]
}
```
</details>

#### Security - EKS & Load Balancer
Currently, there is minimal restriction to the flow of traffic from the Internet to Load Balancer to EKS Nodes and vice versa. 
The general Traffic Flow is as such:
Internet -> (port 80) Load Balancer  -> (NodePorts 30000 to 32767) EKS Cluster Nodes -> Application Pods

> [!CAUTION]
> Our aws_security_group allows **all** inbound traffic and outbound traffic between the internet and the EKS nodes. This was done for ease of the project and to ensure smooth demonstration. 
> However, as per Terrascan warnings - best practice would be to ensure all outbound traffic is monitored and restricted to specific ports or required external IPs, and all inbound traffic is restricted to trusted IPs.  

![Image](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone5.jpg)

## CI/CD Pipelines

### Advantages of Separating Terraform and Docker CI/CD Workflows

1. Clear Separation of Concerns: Distinct workflows allow teams to focus on infrastructure (Terraform) and application deployment (Docker) independently, clarifying roles and responsibilities.
2. Improved Modularity: Modular Terraform configurations can be reused across projects without being tied to specific Docker setups, enhancing maintainability.
3. Enhanced Security: Different access controls can be implemented for infrastructure and application workflows, improving security by limiting permissions based on team roles.
4. Simplified CI/CD Pipelines: Independent pipelines make debugging and maintenance easier, as issues in one workflow do not affect the other.
5. Easier Environment Management: Separate workflows facilitate managing different environments (development, staging, production), reducing the risk of cross-environment issues.
6. Optimized Resource Management: Infrastructure can scale independently from application needs, allowing for more efficient resource allocation.
7. Better Testing and Validation: Independent testing strategies for infrastructure and application code ensure both components function correctly before integration.

In summary, separating these workflows enhances clarity, security, modularity, and efficiency in managing infrastructure and application deployments within a DevOps framework.

### Terraform CI

Terraform files are stored in `terraform/` directory in the repo.
Adopting a shift-left security approach, we implement the following checks for our Terraform CI workflow.
We also have Sonarqube integrated into our repo so it runs code scans on the repo as well as every pull request.

1. Terraform checks
    - Terraform format
    - Terraform init
    - Terraform validate
    - TFLint

<details>
  
```yml
  Terraform-Checks:
    runs-on: ubuntu-latest

    defaults:
      run:
        shell: bash
        working-directory: terraform

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform fmt check
        id: fmt
        run: |
          # Run terraform fmt check and capture output
          output=$(terraform fmt -check) || true
          echo "$output" >> $GITHUB_STEP_SUMMARY  # Append output to step summary

          # Check if formatting issues were found
          if [ $? -ne 0 ]; then
            echo "Formatting issues found!" >> $GITHUB_STEP_SUMMARY
          else
            echo "All files are properly formatted." >> $GITHUB_STEP_SUMMARY
          fi

      - name: Terraform init
        id: init
        run: |
          # Run terraform init and capture output
          output=$(terraform init -backend=false 2>&1) || true

          # Check if initialization was successful
          if [ $? -eq 0 ]; then
            echo "Terraform initialized successfully." >> $GITHUB_STEP_SUMMARY
          else
            echo "Terraform initialization failed with the following error:" >> $GITHUB_STEP_SUMMARY
            echo "$output" >> $GITHUB_STEP_SUMMARY  # Append error output to summary
          fi

      - name: Terraform Validate
        id: validate
        run: |
          # Run terraform validate and capture output
          output=$(terraform validate -no-color) || true
          if [ $? -eq 0 ]; then
            echo "Terraform configuration is valid." >> $GITHUB_STEP_SUMMARY
          else
            echo "Terraform configuration is invalid:" >> $GITHUB_STEP_SUMMARY
            echo "$output" >> $GITHUB_STEP_SUMMARY  # Append validation errors to summary
          fi

      - name: Setup TFLint
        uses: terraform-linters/setup-tflint@v4

      - name: Show TFLint version
        run: tflint --version

      - name: Init TFLint
        run: tflint --init

      - name: Run TFLint
        id: tflint
        run: |
          # Run TFLint and capture output
          output=$(tflint -f compact) || true

          # Check if there were any linting issues
          if [ $? -eq 0 ]; then
            echo "TFLint found no issues." >> $GITHUB_STEP_SUMMARY
          else
            echo "TFLint found the following issues:" >> $GITHUB_STEP_SUMMARY
            echo "$output" >> $GITHUB_STEP_SUMMARY  # Append linting output to summary
          fi
```

</details>

2. Terrascan IAC Scan  

Snyk was the initial choice for IAC scan. However as the free version of Snyk limits the number of runs allowed, the team switched to use Terrascan.

<details>
  
```yml
  Terrascan-IAC:
    runs-on: ubuntu-latest

    defaults:
      run:
        shell: bash
        working-directory: terraform

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Run Terrascan for Terraform
        id: terrascan
        uses: tenable/terrascan-action@main
        with:
          iac_type: "terraform"
          iac_version: "v14"
          policy_type: "aws"
          only_warn: true
          sarif_upload: true

      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: terrascan.sarif
```

</details>

3. Terraform plan

<details>
  
```yml
  Terraform-Plan:
    needs: [Terraform-Checks, Terrascan-IAC]
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: terraform

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.AWS_REGION }}
          audience: sts.amazonaws.com
          role-to-assume: ${{ secrets.ROLE_TO_ASSUME }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        if: github.event_name == 'pull_request'
        id: plan
        run: |
          terraform plan -no-color -var-file="${{ github.base_ref }}.tfvars" -out=tfplan > plan_output.txt 2>&1 || true
          echo "## Terraform Plan Output" >> $GITHUB_STEP_SUMMARY
          echo '```' >> $GITHUB_STEP_SUMMARY
          cat plan_output.txt >> $GITHUB_STEP_SUMMARY
          echo '```' >> $GITHUB_STEP_SUMMARY

      - name: Terraform Plan (Workflow Dispatch)
        if: github.event_name == 'workflow_dispatch'
        id: plan-dispatch
        run: |
          terraform plan -no-color -var-file="${{ github.ref_name }}.tfvars" -out=tfplan > plan_output.txt 2>&1 || true
          echo "## Terraform Plan Output" >> $GITHUB_STEP_SUMMARY
          echo '```' >> $GITHUB_STEP_SUMMARY
          cat plan_output.txt >> $GITHUB_STEP_SUMMARY
          echo '```' >> $GITHUB_STEP_SUMMARY
```

</details>

### Terraform CD

Our terraform CD workflow only consists of one step since all the checks have been done in the CI workflow.

1. Terraform Apply

<details>
  
```yml
  Terraform-Apply:
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: terraform

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.AWS_REGION }}
          audience: sts.amazonaws.com
          role-to-assume: ${{ secrets.ROLE_TO_ASSUME }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: |
          terraform apply -no-color -auto-approve -var-file="${{ github.ref_name }}.tfvars"

      - name: Export terraform outputs
        id: tfout
        run: |
          terraform output

```

</details>

### Docker CI

Docker and application files are stored in their own directory in the repo. `health_care_advisor` in this instance.
We have tried to design the workflow to be app agnostic. Currently, these workflows will work with both js and python projects.
Adopting a shift-left security approach, we implement the following checks for our Docker CI workflow.
We also have Sonarqube integrated into our repo so it runs code scans on the repo as well as every pull request.

1. Check project type
   - Checks if the project is a python or js node project.

<details>
  
```yml
  Check-Files:
    runs-on: ubuntu-latest
    outputs:
      has_js_files: ${{ steps.checkjs.outputs.has_js_files }}
      has_python_files: ${{ steps.checkpy.outputs.has_python_files }}

    defaults:
      run:
        shell: bash
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Check for .js files
        id: checkjs
        run: |
          if ls *.js 1> /dev/null 2>&1; then
            echo "has_js_files=true" >> $GITHUB_OUTPUT
          else
            echo "has_js_files=false" >> $GITHUB_OUTPUT
          fi

      - name: Check for .py files
        id: checkpy
        run: |
          if ls *.py 1> /dev/null 2>&1; then
            echo "has_python_files=true" >> $GITHUB_OUTPUT
          else
            echo "has_python_files=false" >> $GITHUB_OUTPUT
          fi
```

</details>

2. Code Checks  
   - NPM Audit (js): Analyzes the dependencies listed in your project's package.json file and checks them against a database of known vulnerabilities, including those from the GitHub Advisory Database, which encompasses vulnerabilities from various ecosystems.
   - NPM Test (js): Command that runs the test script defined in the "test" property of a project's package.json file, executing automated unit tests for the codebase.
   - Python Safety Scan (py): Scans for vulnerabilities in third-party libraries and dependencies specified in requirements files.
   - Python Bandit Scan (py): Only scans the application code itself, detecting issues directly within the codebase.

<details>
  
```yml
Code-Checks:
    runs-on: ubuntu-latest
    needs: Check-Files

    defaults:
      run:
        shell: bash
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        if: needs.Check-Files.outputs.has_js_files == 'true'
        uses: actions/setup-node@v4
        with:
          node-version: "23"

      - name: Run installation of dependencies commands
        if: needs.Check-Files.outputs.has_js_files == 'true'
        run: npm install

      - name: Run a security audit
        if: needs.Check-Files.outputs.has_js_files == 'true'
        id: npm-audit
        run: |
          # Run npm audit and capture output
          output=$(npm audit --audit-level=high --json)

          # Check if there are vulnerabilities found
          if [ $? -eq 0 ]; then
            echo "NPM audit completed successfully with no high vulnerabilities found." >> $GITHUB_STEP_SUMMARY
          else
            echo "NPM audit found the following high vulnerabilities:" >> $GITHUB_STEP_SUMMARY
            echo "$output" | jq -r '.advisories | to_entries[] | "Package: \(.value.module_name), Severity: \(.value.severity), Title: \(.value.title), URL: \(.value.url)"' >> $GITHUB_STEP_SUMMARY
          fi

      - name: Install Mocha, Chai and Supertest
        if: needs.Check-Files.outputs.has_js_files == 'true'
        # Mocha: A test framework for running tests.
        # Chai: An assertion library for Node.js.
        # Supertest: A library for testing HTTP servers.
        run: npm install --save-dev mocha chai supertest

      - name: Run unit testing command
        if: needs.Check-Files.outputs.has_js_files == 'true'
        id: npm-test
        run: |
          # Run npm test and capture output
          output=$(npm test -- --reporter=json)

          # Check if tests passed or failed
          if [ $? -eq 0 ]; then
            echo "All unit tests passed successfully." >> $GITHUB_STEP_SUMMARY
          else
            echo "Some unit tests failed. See details below:" >> $GITHUB_STEP_SUMMARY
            echo "$output" >> $GITHUB_STEP_SUMMARY  # Append test output to summary
          fi

      - name: Run Safety CLI to check for vulnerabilities
        if: needs.Check-Files.outputs.has_python_files == 'true'
        id: safety
        uses: pyupio/safety-action@v1
        with:
          api-key: ${{ secrets.SAFETY_API_KEY }}
          args: --detailed-output --ignore 72731 --ignore 70813 --ignore 70624 # To always see detailed output from this action

      - name: Summary of Python Safety Scan
        if: needs.Check-Files.outputs.has_python_files == 'true'
        run: |
          if [ "${{ steps.safety.outcome }}" == "success" ]; then
            echo "### Safety Scan" >> $GITHUB_STEP_SUMMARY
            echo "- Safety scan completed successfully." >> $GITHUB_STEP_SUMMARY
          else
            echo "### Safety Scan" >> $GITHUB_STEP_SUMMARY
            echo "- Safety scan failed." >> $GITHUB_STEP_SUMMARY
            echo "- Vulnerabilities found:" >> $GITHUB_STEP_SUMMARY
            echo "${{ steps.safety.outputs.vulnerabilities }}" >> $GITHUB_STEP_SUMMARY
          fi

      - name: Set Up Python
        if: needs.Check-Files.outputs.has_python_files == 'true'
        uses: actions/setup-python@v5
        with:
          python-version: "3.13"

      - name: Install Bandit
        if: needs.Check-Files.outputs.has_python_files == 'true'
        run: pip install bandit[sarif]

      - name: Run Bandit Scan
        if: needs.Check-Files.outputs.has_python_files == 'true'
        id: bandit
        run: bandit -r . --severity-level high --confidence-level high -f sarif -o bandit-report.sarif

      - name: Upload Bandit scan SARIF report
        if: needs.Check-Files.outputs.has_python_files == 'true' && failure()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: bandit-report.sarif

      - name: Summary of Bandit Scan
        if: needs.Check-Files.outputs.has_python_files == 'true'
        run: |
          if [ "${{ steps.bandit.outcome }}" == "success" ]; then
            echo "### Bandit Scan" >> $GITHUB_STEP_SUMMARY
            echo "- Bandit scan completed successfully." >> $GITHUB_STEP_SUMMARY
          else
            echo "### Bandit Scan" >> $GITHUB_STEP_SUMMARY
            echo "High severity issues found:" >> $GITHUB_STEP_SUMMARY
          fi
```

</details>

3. Docker Build
   - Builds the Docker container locally on the runner to confirm that it can be built without errors.

<details>
  
```yml
  Docker-Build:
    needs: Code-Checks
    runs-on: ubuntu-latest

    defaults:
      run:
        shell: bash
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build an image from Dockerfile
        id: docker-build
        run: |
          # Run docker build and capture output
          output=$(docker build -t ${{ env.IMAGE_NAME }}:${{ github.sha }} . 2>&1)

          # Check if the build was successful
          if [ $? -eq 0 ]; then
            echo "### Docker Build" >> $GITHUB_STEP_SUMMARY
            echo "- Docker image built successfully with tag ${{ env.IMAGE_NAME }}:${{ github.sha }}." >> $GITHUB_STEP_SUMMARY
          else
            echo "### Docker Build" >> $GITHUB_STEP_SUMMARY
            echo "- Docker build failed with the following errors:" >> $GITHUB_STEP_SUMMARY
            echo "- $output" >> $GITHUB_STEP_SUMMARY  # Append build output to summary
          fi
```

</details>

4. Grype Container Scan
   - An open-source vulnerability scanner that identifies known security vulnerabilities in container images and filesystems.

<details>
  
```yml
  Grype-Container-Scan:
    needs: Docker-Build
    runs-on: ubuntu-latest

    defaults:
      run:
        shell: bash
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Docker Build
        run: docker build -t ${{ env.IMAGE_NAME }}:${{ github.sha }} .

      - name: Run Grype Container Scan
        id: grype
        uses: anchore/scan-action@v5
        with:
          image: "${{ env.IMAGE_NAME }}:${{ github.sha }}"
          fail-build: true
          severity-cutoff: high

      - name: upload Anchore scan SARIF report
        if: ${{ failure() }}
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: ${{ steps.grype.outputs.sarif }}

      - name: Summarize Grype Scan Results
        run: |
          if [ "${{ steps.grype.outcome }}" == "success" ]; then
            echo "### Grype Scan" >> $GITHUB_STEP_SUMMARY
            echo "- Grype scan completed successfully." >> $GITHUB_STEP_SUMMARY
          else
            echo "### Grype Scan" >> $GITHUB_STEP_SUMMARY
            echo "- High severity issues found." >> $GITHUB_STEP_SUMMARY
          fi
```

</details>

5. Docker run test and ZAP scan
   - Runs the Docker container to make sure it can launch successfully.
   - OWASP ZAP (Zed Attack Proxy) is an open-source web application DAST security scanner that identifies vulnerabilities and security issues by simulating attacks on web applications.

<details>
  
```yml
  Docker-Run-and-ZAP:
    needs: Grype-Container-Scan
    runs-on: ubuntu-latest

    defaults:
      run:
        shell: bash
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Docker Build
        run: docker build -t ${{ env.IMAGE_NAME }}:${{ github.sha }} .

      - name: Docker Run
        run: |
          # Run the container
          docker run --rm --name test_container -d -p 8080:5000 ${{ env.IMAGE_NAME }}:${{ github.sha }}

          # Wait for the container to start up
          sleep 5

          # Check if the container is running
          container_status=$(docker inspect -f '{{.State.Running}}' test_container)

          if [ "$container_status" = "true" ]; then
            echo "### Docker Run" >> $GITHUB_STEP_SUMMARY
            echo "- Docker container is running successfully." >> $GITHUB_STEP_SUMMARY
          else
            echo "### Docker Run" >> $GITHUB_STEP_SUMMARY
            echo "- Docker container is not running!" >> $GITHUB_STEP_SUMMARY
            exit 1  # Exit with a non-zero code to indicate failure
          fi

      - name: ZAP Scan
        id: zap-scan
        uses: zaproxy/action-full-scan@v0.12.0
        with:
          target: "http://localhost:8080" # Adjust this URL to match your application's endpoint
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Write Success Summary
        if: success() # This step runs only if the previous step succeeded
        run: |
          echo "### ZAP Scan" >> $GITHUB_STEP_SUMMARY
          echo "- ZAP Scan Completed Successfully!" >> $GITHUB_STEP_SUMMARY

      - name: Write Failure Summary
        if: failure() # This step runs only if the previous step failed
        run: |
          echo "### ZAP Scan" >> $GITHUB_STEP_SUMMARY
          echo "- ZAP Scan Failed!" >> $GITHUB_STEP_SUMMARY
```

</details>

### Docker CD

Since we are using a kubernetes cluster, we will need to apply kubernetes secrets, deployments and services as part of the workflow.

#### Get Github Tag

- Fetch the latest tag from the github repo to be used as tags for container images.

<details>
  
```yml
  Get-Tag:
    runs-on: ubuntu-latest

    outputs:
      LATEST_TAG: ${{ steps.get_latest_tag.outputs.LATEST_TAG }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Fetch All Tags
        run: git fetch --tags

      - name: Get Latest Tag
        id: get_latest_tag
        run: |
          echo "LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)" >> $GITHUB_OUTPUT
          echo "LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)"

      - name: Output Latest Tag
        run: echo "The latest tag is ${{ steps.get_latest_tag.outputs.LATEST_TAG }}" >> $GITHUB_STEP_SUMMARY
```

</details>

#### Docker Push

- Use a github action ```docker/build-push-action@v6``` to build and push the container image to ghcr

<details>
  
```yml
  Docker-Push:
    needs: Get-Tag
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Log in to the Container registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        id: push
        uses: docker/build-push-action@v6
        with:
          context: ./${{ vars.APP_FOLDER }}/
          file: ./${{ vars.APP_FOLDER }}/Dockerfile
          push: true
          tags: ${{ env.REGISTRY }}/${{ github.repository_owner }}/${{ env.IMAGE_NAME }}:${{ needs.Get-Tag.outputs.LATEST_TAG }}.${{ github.run_number }}
```

</details>

#### Create and apply secrets.yaml

- Use a Github Personal Access Token(PAT) stored in Github Secrets to create a secrets.yaml file and apply it to the kubernetes cluster.
- We can create a secret in each namespace with the same name ```ghcr-auth```. This makes is easy to pull the secret later for deployments to any namespace.

<details>
  
```yml
  Create-Secret:
    needs: Docker-Push
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.AWS_REGION }}
          audience: sts.amazonaws.com
          role-to-assume: ${{ secrets.ROLE_TO_ASSUME }}

      - name: Set up kubectl
        run: |
          aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER }} --region ${{ env.AWS_REGION }}

      - name: Create Secrets file
        run: |
          cat <<EOF > secrets.yaml
          apiVersion: v1
          kind: Secret
          metadata:
            name: ghcr-auth
            namespace: "${{ github.ref_name }}"
          type: kubernetes.io/dockerconfigjson
          stringData:
            .dockerconfigjson: |
              {
                "auths": {
                  "${{ env.REGISTRY }}": {
                    "username": "${{ secrets.GHCR_USER }}",
                    "password": "${{ secrets.GHCR_TOKEN }}"
                  }
                }
              }
          EOF

      - name: Apply secret to Kubernetes
        run: |
          kubectl apply -f secrets.yaml || true
          sleep 10
          if kubectl get secret -n ${{ github.ref_name }} | grep -q ghcr-auth; then
            echo "secrets.yaml applied successfully" >> $GITHUB_STEP_SUMMARY
          else
            echo "Secrets.yaml failed to apply" >> $GITHUB_STEP_SUMMARY
          fi
```

</details>

#### Create and apply deployment.yaml

- Create a deployment.yaml based on a template in github actions with substitutions for eks cluster name, region, namespace, image name, etc.
- Apply the file to the kubernetes cluster.

<details>
  
```yml
      - name: Create Deployment file
        env:
          LATEST_TAG: ${{ needs.Get-Tag.outputs.LATEST_TAG }}
        run: |
          cat <<EOF > deployment.yaml
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            namespace: ${{ github.ref_name }}
            name: ${{ env.IMAGE_NAME }}
          spec:
            replicas: 2
            selector:
              matchLabels:
                app: ${{ env.IMAGE_NAME }}
            template:
              metadata:
                labels:
                  app: ${{ env.IMAGE_NAME }}
              spec:
                imagePullSecrets:
                  - name: ghcr-auth
                containers:
                  - name: ${{ env.IMAGE_NAME }}
                    image: ${{ env.REGISTRY }}/${{ github.repository_owner }}/${{ env.IMAGE_NAME }}:${{ env.LATEST_TAG }}.${{ github.run_number }}
                    ports:
                      - containerPort: 5000
                        protocol: TCP
                    resources:
                      requests:
                        cpu: "500m"
                        memory: "512Mi"
                      limits:
                         cpu: "1"
                         memory: "1Gi"
                    livenessProbe:
                      httpGet:
                        path: "/"
                        port: 5000
                        scheme: "HTTP"
                      initialDelaySeconds: 45
                      timeoutSeconds: 3
                      periodSeconds: 10
                      successThreshold: 1
                      failureThreshold: 3
                    readinessProbe:
                      httpGet:
                        path: "/"
                        port: 5000
                        scheme: "HTTP"
                      initialDelaySeconds: 30
                      timeoutSeconds: 3
                      periodSeconds: 10
                      successThreshold: 1
                      failureThreshold: 3
          EOF

      - name: Apply Deployment file
        run: |
          kubectl apply -f deployment.yaml || true
          sleep 10
          if kubectl get deployment -n ${{ github.ref_name }} | grep -q ${{ env.IMAGE_NAME }}; then
            echo "deployment.yaml applied successfully" >> $GITHUB_STEP_SUMMARY
          else
            echo "deployment.yaml failed to apply" >> $GITHUB_STEP_SUMMARY
          fi
```

</details>

#### Create and apply service.yaml

- Create a service.yaml file based on a template in github actions with substitutions for cluster, namespace, region and security group.
- Apply the file to the kubernetes cluster.

<details>
  
```yml
  Create-Service:
    needs: Create-Deployment
    runs-on: ubuntu-latest

    outputs:
      SG_ID: ${{ steps.sg_id.outputs.SG_ID }}

    defaults:
      run:
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.AWS_REGION }}
          audience: sts.amazonaws.com
          role-to-assume: ${{ secrets.ROLE_TO_ASSUME }}

      - name: Get LB security group id
        id: sg_id
        run: |
          SG_ID=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=ce7-grp-2-lb-sg" --query "SecurityGroups[*].GroupId" --output text)
          echo "SG_ID=$SG_ID" >> "$GITHUB_OUTPUT"

      - name: Set up kubectl
        run: |
          aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER }} --region ${{ env.AWS_REGION }}

      - name: Create Service file
        run: |
          cat <<EOF > service.yaml
          kind: Service
          apiVersion: v1
          metadata:
            name: ${{ env.IMAGE_NAME }}
            namespace: ${{ github.ref_name }}
            annotations:
              service.beta.kubernetes.io/aws-load-balancer-type: nlb
              service.beta.kubernetes.io/aws-load-balancer-internal: "false"
              service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
              service.beta.kubernetes.io/aws-load-balancer-security-groups: ${{ steps.sg_id.outputs.SG_ID }}
          spec:
            type: LoadBalancer
            ports:
              - name: web
                port: 80
                targetPort: 5000
            selector:
              app: ${{ env.IMAGE_NAME }}
          EOF

      - name: Apply Service file
        run: |
          kubectl apply -f service.yaml || true
          sleep 10
          if kubectl get service -n ${{ github.ref_name }} | grep -q ${{ env.IMAGE_NAME }}; then
            echo "service.yaml applied successfully" >> $GITHUB_STEP_SUMMARY
          else
            echo "service.yaml failed to apply" >> $GITHUB_STEP_SUMMARY
          fi
```

</details>

#### Create Route53 cname

- Once the service is created and we get an External IP from the load balancer, we can create a Route53 CNAME on our hosted zone ```sctp-sandbox.com```.
- We use awscli to get the Zone ID and to create the CNAME record.
- We then check if the CNAME resource record was created successfully and if the dns resolution functions.

<details>
  
```yml
  Create-Route53:
    needs: Create-Service
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.AWS_REGION }}
          audience: sts.amazonaws.com
          role-to-assume: ${{ secrets.ROLE_TO_ASSUME }}

      - name: Set up kubectl
        run: |
          aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER }} --region ${{ env.AWS_REGION }}

      - name: Create Route 53 CNAME Record
        run: |
          # Wait for the LoadBalancer to get an external IP
          sleep 30 # Adjust this duration as necessary

          # Get the external IP of the LoadBalancer
          EXTERNAL_IP=$(kubectl get svc -n ${{ github.ref_name }} | grep ${{ env.IMAGE_NAME }} | awk '{print $4}')

          # Get Hosted Zone ID
          ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name sctp-sandbox.com --query "HostedZones[].Id" --output text  | sed 's|/hostedzone/||')

          # Create CNAME variable
          CNAME=ce7-grp-2-app-${{ github.ref_name }}.sctp-sandbox.com

          # Create a CNAME record in Route 53
          aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch '{
            "Changes": [{
              "Action": "UPSERT",
              "ResourceRecordSet": {
                "Name": "'"$CNAME"'",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [{"Value": "'"$EXTERNAL_IP"'"}]
              }
            }]
          }'

          # Wait for CNAME record to be created
          sleep 30 # Adjust this duration as necessary

          # Get CNAME Value
          CNAME_VALUE=$(aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" --query "ResourceRecordSets[?Type == 'CNAME' && Name == '$CNAME.'].ResourceRecords[*].Value" --output text)

          # Check if CNAME record was created successfully
          if [ "$CNAME_VALUE" = "$EXTERNAL_IP" ]; then
            echo "Route53 cname $CNAME created successfully." >> $GITHUB_STEP_SUMMARY
          else
            echo "Route53 cname creation failed." >> $GITHUB_STEP_SUMMARY
          fi

          # Wait for DNS propagation
          sleep 30 # Adjust this duration as necessary

          # Get dig result
          DIG_RESULT=$(dig @8.8.8.8 +short $CNAME | grep amazonaws)

          # Check if DNS name lookup works
          if [ "$DIG_RESULT" = "$EXTERNAL_IP" ]; then
            echo "DNS name resolution successful." >> $GITHUB_STEP_SUMMARY
          else
            echo "DNS name resolution failed." >> $GITHUB_STEP_SUMMARY
          fi
```

</details>

#### Automerge to UAT branch (if push to dev)

- After we have succesfully done all the above on the dev branch we can auto-merge dev to uat branch.

<details>
  
```yml
  Automerge-to-UAT:
    if: ${{ github.ref_name == 'dev' }}
    needs: Create-Route53
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Merge dev -> uat
        uses: devmasx/merge-branch@master
        with:
          type: now
          target_branch: uat
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

</details>

#### Advance github tag and release (if push to prod)

- When we have successfully pushed a PR from uat to prod, we will advance the github tag and release.

<details>
  
```yml
  Advance-Tag-and-Release:
    if: ${{ github.ref_name == 'prod' }}
    needs: Create-Route53
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ${{ vars.APP_FOLDER }}

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Bump version and push tag
        id: tag_version
        uses: mathieudutour/github-tag-action@v6.2
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}

      - name: Create a GitHub release
        uses: ncipollo/release-action@v1
        with:
          tag: ${{ steps.tag_version.outputs.new_tag }}
          name: Release ${{ steps.tag_version.outputs.new_tag }}
          body: ${{ steps.tag_version.outputs.changelog }}
```

</details>

## This repository contains Terraform files  

```sh
project-root/
├── .terraform/                       # Terraform hidden directory for internal files
├── .gitignore                        # Ignore Terraform state files, .terraform directory, etc.
├── backend.tf                        # Configures the backend for storing the Terraform state file
├── main.tf                           # Main configuration file for calling all modules
├── variables.tf                      # Declares all the variables used across modules
├── outputs.tf                        # Outputs from the modules or resources to use externally
├── provider.tf                       # AWS provider configuration
├── terraform.tfvars                  # Contains values for the variables declared in variables.tf
├── modules/                          # Directory to hold all reusable Terraform modules
│   │
│   ├── eks/                          # EKS module
│   │   ├── eks.tf                    # EKS resources
│   │   ├── iam.tf                    # IAM (Identity and Access Management) for EKS cluster
│   │   ├── logging.tf                # Loadbalancer logging into S3
│   │   ├── outputs.tf                # EKS module outputs
│   │   ├── secrets.tf                # GHCR Secrets Management for private registry (Not in use)
│   │   ├── security.tf               # Network Security Configuration for EKS and Load Balancer
│   │   ├── serviceacc.tf             # Kubernetes Service Account and IAM Integration
│   │   ├── variables.tf              # EKS module variables
│   │   └── versions.tf               # EKS module versioning
│   │
│   └── network/                      # VPC module
│       ├── vpc.tf                    # VPC, IGW, NAT GW, and Elastic IPs
│       ├── network.tf                # Subnets, Route Tables, and Route Tables Association.
│       ├── variables.tf              # VPC module variables
│       └── outputs.tf                # VPC module outputs (e.g., VPC ID, subnet IDs)
│
├── iam.tf                            # IAM role/policy for Lambda to access DynamoDB and CloudWatch.
├── network.tf                        # Security groups and networking configurations.
├── container-definitions.json        # ECS task container definitions file (if needed)
├── ce7-grp-2-hca-lambda.zip          # A ZIP file containing the Lambda function code to call Method.
├── ce7-grp-2-hca-insert-records.zip  # A ZIP file containing the Lambda function code to insert content records. 
├── dynamodb.tf                       # DynamoDB table setup
├── lambda.tf                         # Creates Lambda function for health care advisor service with Python, IAM, and DynamoDB integration.
├── webapi_gtw.tf                     # Sets up an API Gateway with Lambda integration.  
├── README.md                         # Documentation for the setup and usage
│
├── dev.tfvars                        # Not utilised - Development settings 
├── uat.tfvars                        # Not utilised - UAT settings
└── prod.tfvars                       # Not utilised - Production settings
```

## Health Care Advisor (Web Application)

**Health Care Advisor** is a comprehensive and interactive web application designed to help users understand and improve their health through personalized guidance on managing chronic diseases, engaging in physical activities, and adopting healthy dietary habits. For chronic conditions like Blood Pressure, Diabetes, and Heart Health, the app offers practical tips such as monitoring vital metrics, reducing salt or sugar intake, and maintaining an active lifestyle. Users can explore diverse physical activities like walking, yoga, or strength training to enhance fitness and prevent health risks. Additionally, the app provides valuable diet tips, emphasizing the importance of whole foods, portion control, hydration, and minimizing processed foods. By combining expert insights with actionable recommendations, Health Care Advisor empowers individuals to take charge of their well-being and live healthier, more balanced lives.

### Home page

![Screenshot 2024-12-27 141543](https://github.com/user-attachments/assets/d4b44230-00b4-4ffb-9066-7530914e4b4f)

[Watch Health Care Advisor Demo Video](https://drive.google.com/file/d/1iKSBZfRZptc52vxu3ImMjSprXQKeE8fi/view?usp=sharing)

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/nyYlBen2mdY/0.jpg)](https://www.youtube.com/watch?v=nyYlBen2mdY)

### Key Features of Health Care Advisor

1. Chronic Disease Management

  * Tailored tips for managing conditions like Blood Pressure, Diabetes, and Heart Health.
  * Easy-to-follow advice on monitoring health metrics and lifestyle adjustments.

2. Physical Activity Recommendations

  * Suggestions for various exercises like walking, yoga, cycling, and strength training.
  * Detailed benefits of each activity to encourage an active lifestyle.

3. Dietary Guidance

  * Nutritional tips such as eating whole foods, staying hydrated, and controlling portion sizes.
  * Insights on healthy fats, lean proteins, and minimizing processed foods for better health.

### Technologies Used

#### 1. Frontend is built using:

  - **Python**: Handles dynamic components of the application.
  - **JavaScript**: Powers interactivity like button clicks and API calls.
  - **HTML & CSS**: Provide a responsive and fun user interface.
  - The entire frontend runs in a **Docker container** for easy portability and scaling.

#### 2. Backend (Serverless):

The backend is built using **AWS serverless services**, deployed and managed through **Terraform** and automated with **GitHub Workflows** for continuous integration and deployment:

- **API Gateway**: Exposes RESTful endpoints to retrieve content for Health Care Advisor.
- **AWS Lambda Function**: Executes backend logic such as fetching a content from the database.
- **Amazon DynamoDB**: Stores all the content in a NoSQL database, ensuring fast retrieval and scalability.

#### 3. Build and Deployment

- **Terraform**: Infrastructure as Code (IaC) is used to provision and configure serverless resources in AWS.
- **GitHub Workflows**: Automates the CI/CD pipeline, running Terraform scripts to deploy backend changes seamlessly upon code updates.

### Web Application files/folder structures

```sh
health_care_advisor
├── app                     # Application folder contain css, images, javascript, html, environment and python program.
│   ├── static              # This directory contains static assets that are served directly to the client.
│   │   ├──css
│   │   │   └── styles.css  # The CSS file to style the webpage.
│   │   ├──img              # The img folder contain all the images associated with the health care advisor.
│   │   ├──js
│   │   │    └──script.js   # contain all the javascript code.    
│   │   ├── templates       # This directory holds the HTML templates used by the Flask application.
│   │   │   └── index.html  # The main page of the application, which displays health care advisor content.
│   ├── .env                # A file containing environment variables used by the application.
│   └── app.py              # The main entry point of the Flask application. (defines the routes and logic).
│
├── docker-compose.yml      # To define and manage multi-container docker applications.
├── Dockerfile              # The file that contains instructions for building the Docker image.
└── requirements.txt        # A file listing the Python dependencies required for the application.
```

## About AWS Serverless Tools

AWS provides powerful services that enable developers to build scalable, cost-efficient, and serverless applications. Among these, API Gateway, AWS Lambda, Amazon DynamoDB, REST APIs, and IAM stand out as essential tools for modern cloud development.

![APIG_tut_resources](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone8.png)

## API Gateway

AWS API Gateway acts as the front door for applications, enabling developers to design, deploy, and manage RESTful APIs without worrying about infrastructure. It integrates seamlessly with other AWS services like Lambda and DynamoDB, allowing you to build robust serverless applications. Key features include request transformation, traffic throttling, and built-in authentication mechanisms.

## REST API with API Gateway

A REST API is an architectural style that allows applications to interact over HTTP using standard methods like GET, POST, and DELETE. AWS API Gateway makes creating REST APIs simple, acting as a bridge between clients and backends such as Lambda functions or DynamoDB tables.

![Screenshot 2024-12-27 141957](https://github.com/user-attachments/assets/710d1cdf-a4b4-478f-ae95-b0caa09b2a90)

## AWS Lambda

AWS Lambda is the backbone of serverless computing in AWS. It allows you to run code in response to triggers such as HTTP requests, database events, or changes in data streams. With Lambda, there’s no need to manage servers; AWS automatically handles scaling, making it ideal for lightweight, event-driven workloads.

![Screenshot 2024-12-27 142107](https://github.com/user-attachments/assets/9bf1fb61-3cbd-44ef-bc1b-0952343a37bc)

## Amazon DynamoDB

A fully managed NoSQL database, Amazon DynamoDB is designed for high availability, low latency, and automatic scaling. It supports both key-value and document data models, making it a go-to choice for serverless architectures. DynamoDB works exceptionally well for real-time applications like gaming leaderboards, IoT systems, and e-commerce platforms.

![Screenshot 2024-12-27 142226](https://github.com/user-attachments/assets/39f466e4-ff55-4a0b-944a-0ebde2fccf7c)

## IAM (Identity and Access Management)

AWS IAM secures access to resources in your AWS environment. It lets you create users, roles, and policies to control who can access what. For serverless architectures, IAM ensures that services like API Gateway and Lambda interact securely with DynamoDB or other resources, following the principle of least privilege.

![IamPolicy](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone12.jpg)

## Project Management and Future Areas for Improvement

A simple **Jira Kanban Board** was used to help us keep track of tasks progress. We have also added in potential areas for improvements for this project.  

https://tanlye.atlassian.net/jira/software/projects/CE7/boards/1?atlOrigin=eyJpIjoiOWY0ZmFhMmE5OTFkNGEyZGI3OTI2YzQyMDNkMGEwYmEiLCJwIjoiaiJ9

![image](https://github.com/latcaa-ce-ntu/ce7-grp-2-resources/blob/main/screenshot/capstone13.png)

## References

- https://www.parsectix.com/blog/github-oidc
- https://blog.clouddrove.com/github-actions-openid-connect-the-key-to-aws-authentication-dd9f66a7d31e
- https://blog.devops.dev/docker-hub-or-ghcr-or-ecr-lazy-mans-guide-4da1d943d26e
- https://cloudonaut.io/versus/container-registry/ecr-vs-github-container-registry/
- https://pirasanth.com/blog/how-to-build-and-push-docker-images-to-github-container-registry-with-github
