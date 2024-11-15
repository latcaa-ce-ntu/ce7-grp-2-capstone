# devops-tf
This repository contains Terraform files.


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
│   ├── alb/                          # ALB module
│   │   ├── alb.tf                    # ALB resources
│   │   ├── variables.tf              # ALB module variables
│   │   └── outputs.tf                # ALB module outputs (e.g., ALB DNS name)
│   ├── ecr/                          # ECR module
│   │   ├── ecr.tf                    # ECR repository resources
│   │   ├── variables.tf              # ECR module variables
│   │   └── outputs.tf                # ECR module outputs
│   ├── ecs/                          # ECS module
│   │   ├── ecs.tf                    # ECS cluster, task definitions, service
│   │   ├── variables.tf              # ECS module variables
│   │   └── outputs.tf                # ECS module outputs (e.g., ECS cluster ARN)
│   └── vpc/                          # VPC module
│       ├── vpc.tf                    # VPC, subnets, and related resources
│       ├── variables.tf              # VPC module variables
│       └── outputs.tf                # VPC module outputs (e.g., VPC ID, subnet IDs)
├── iam.tf                            # IAM roles and policies for ECS task execution and services
├── network.tf                        # Security groups and networking configurations
├── container-definitions.json        # ECS task container definitions file (if needed)
└── README.md                         # Documentation for the setup and usage
