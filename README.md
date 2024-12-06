![Alt Text](https://github.com/lann87/cloud_infra_eng_ntu_coursework_alanp/blob/main/.misc/ntu_logo.png)  

# CE7 Group 2 Capstone Project  
## Team Members :  
1. Alan Peh
2. Andy Liew
3. Azmi Maniku
4. Lovell Tan
5. Wong Teck Choy
                
## Project Objectives
1. Create A simple Web App that allows users to read new jokes with each click of a button. 
2. Containerize the Web App and dependencies using Docker. Store Jokes database in AWS DynamoDB.
3. Build AWS infrastructure using Terraform
4. Implement CI/CD pipeline using Github Actions to build infrastructure, perform relevant tests on Terraform code/k8s files/Web App python code/Dockerfiles and automate deployment from testing to live environment.
5. Use AWS EKS as the container orchestration platform

## Architechture Diagram [To be updated]
![image](https://github.com/user-attachments/assets/a4350549-5f85-416c-aec6-f124fd283843)



## Dev/UAT/Prod Github Branch strategy  

![git branch2](https://github.com/user-attachments/assets/a1adccf3-c3bc-4e1e-8ed6-d7c7e93d6d1c)
<sub>Image from Valaxy Technologies.</sub>

### Pros and Cons of Dev/UAT/Prod Branch Strategy  

**Pros**  

- Simplicity: This strategy is straightforward, making it easier for teams to understand and implement. Developers can work directly in the DEV branch, and changes flow through UAT to PROD without complex branching structures.
- Continuous Development: Development can continue uninterrupted during releases, as new features can be worked on in the DEV branch while UAT and PROD are being updated.
- Clear Environment Segregation: Each branch corresponds to a specific environment (DEV for development, UAT for testing, PROD for production), which helps maintain clarity about what code is being tested or deployed.
- Hotfix Management: The strategy allows for quick hotfixes directly to the PROD branch without disrupting ongoing development.
  
**Cons**  

- Limited Control Over Releases: If multiple features are in development, it can be challenging to release only certain features if others are not ready. This can lead to delays or the need for complex merges.  
- Potential for Code Drift: Continuous merging into DEV could lead to integration issues if not managed properly, as features might not be tested together until later stages.  
- Less Granular Control: Compared to GitFlow, this strategy may provide less control over which features are included in each release since it typically promotes all changes from DEV to UAT at once.  

### Pros and Cons of GitFlow  

**Pros**  

- Structured Release Process: GitFlow offers a more structured approach with dedicated branches for features, releases, and hotfixes, allowing teams to manage releases more granularly.  
- Isolation of Features: Each feature can be developed in isolation on its own branch, reducing the risk of conflicts and making it easier to manage complex projects with multiple features being developed simultaneously.  
- Selective Merging: Teams can cherry-pick which features to promote to production by merging specific branches rather than merging everything from DEV at once. This allows for more control over what goes live.  
  
**Cons**  

- Complexity: The additional branches and rules can complicate the workflow, especially for smaller teams or projects. New team members may find it harder to navigate compared to simpler strategies like Dev, UAT, Prod.  
- Slower Release Cycles: The structured nature of GitFlow may slow down the release process since features must go through multiple branches and approvals before reaching production.  
- Overhead Management: Managing multiple branches requires more overhead in terms of maintaining them and ensuring they are up-to-date with the latest changes from other branches.  

### Conclusion  

The Dev/UAT/Prod strategy is beneficial for small teams like ours seeking simplicity and continuous development on smaller projects.
It may lack the granularity of control offered by GitFlow, which provides a robust framework suitable for larger projects.
However, Gitflow introduces additional complexity that may not be necessary for all teams.
We are also implementing some continuous deployment by automatically merging dev branch to uat branch after a PR is successfully pushed to dev branch.
Moving from uat branch to prod branch will be a manual pull request.


## OpenID Connect (OIDC)  

GitHub OpenID Connect (OIDC) allows GitHub Actions to authenticate with cloud providers securely. Rather than storing a permanent AWS access key ID and secret access key, OIDC enables use of temporary credentials to access AWS.
![image](https://github.com/user-attachments/assets/aa51e9c6-ca29-4458-8510-e9a1595fa9df)

GitHub OpenID Connect (OIDC) offers several advantages for CI/CD workflows:  

1. Elimination of Long-Lived Secrets  
    - OIDC removes the need for storing long-lived cloud credentials in GitHub, reducing the risk of credential exposure.  
2. Enhanced Security with Temporary Credentials  
    - Tokens are short-lived, minimizing the impact of any potential compromise since they expire quickly.  
3. Simplified Credential Management  
    - OIDC streamlines credential management by eliminating the need for manual rotation and updates, leading to increased efficiency.  
4. Improved Access Control  
    - Organizations can define specific permissions for access tokens, enhancing security by ensuring only authorized workflows can access resources.  
5. Seamless Integration with Cloud Providers  
    - OIDC supports multiple cloud providers, allowing teams to deploy applications without changing authentication methods.  
6. Better Compliance with Security Standards  
    - Adopting OIDC helps organizations align with security best practices, minimizing the use of long-lived credentials.  

### Conclusion  

OIDC eliminates the need for all team members to share a set of access keys/credentials and reduces access management workload. Hence we chose to integrate OIDC in our workflow. 
Potential areas for improvement: Restrict Access to different resources created based on specific user roles (IAM) that authenticate using OIDC.

<details>

```
permissions:
  id-token: write # This is required for requesting the JWT
  contents: write # This is required for actions/checkout
  packages: write
  attestations: write
```
</details>

## Containerization
### Container Registry selection

We have decided to use github container registry (ghcr) for this project instead of other options like AWS Elastic Container Registry (ECR) or Docker Hub.
Following are some advantages of using ghcr:

1. Cost Efficiency
    - Free for Open Source: GHCR is free for public repositories, making it ideal for open-source projects, while ECR can incur costs for private repositories.
2. Seamless Integration with GitHub
    - CI/CD Support: Direct integration with GitHub Actions simplifies the automation of building and deploying container images.
3. No Pull Limits
    - Relaxed Rate Limits: GHCR allows unlimited pulls, reducing the risk of deployment delays compared to Docker Hub's rate limits.
4. Simplified Authentication
    - Personal Access Tokens: Easier authentication through personal access tokens compared to the more complex AWS IAM policies used by ECR.
5. Multi-Architecture Support
    - Automatic Image Selection: Supports multi-architecture images, allowing automatic selection based on CPU architecture.
6. User-Friendly Interface
    - Familiarity: Provides a familiar interface for GitHub users, reducing the learning curve and increasing productivity.
7. Flexibility in Image Management
    - Tagging and Versioning: Offers flexible tagging and versioning, essential for continuous integration and delivery practices.

In summary, GHCR provides significant advantages in cost, integration, ease of use, and flexibility, making it a strong choice for developers leveraging GitHub.


### Secrets Management

We are using Github Actions Secrets for all of our secrets in this repo for ease of integration with Github Actions workflow. 

### Environment handling

We are not using terraform workspaces for this project because we do not want to create a vpc and eks for each workspace (and increase costs).
Instead we re-use the same vpc and eks cluster. Then use kubernetes namespaces (dev/uat/prod) to separate the environments respectively.
Understandably, in a large enough organization, it will be prudent to separate the cloud infra into different environments.
However, for our small capstone project, we have opted to save on costs of running multiple eks clusters.

### Kuberneter Cluster - Key Setup Features
#### Auto-scaling & self-healing
By default, 2 worker nodes are running at all times. However this can be scaled up or down to 1-3 nodes depending on load. 

<details>
  
```
  # Configure auto-scaling for nodes
  scaling_config {
    desired_size = 2 # Normal running nodes
    max_size     = 3 # Maximum during high load
    min_size     = 1 # Minimum to maintain
  }
```

</details>

Nodegroups:

Namespaces: We create three namespaces ```(dev|uat|prod)``` to achieve separate environments for our deployments/services/apps.

IAM:
    - Roles:
    - Policies:

## CI/CD Pipelines
### Terraform CI

Terraform files are stored in ```terraform/``` directory in the repo.
We implement the following checks for our Terraform CI workflow:

1. Terraform format
2. Terraform init
3. Terraform validate
4. TFLint
5. Sonarqube IAC scan
6. IAC Scan
7. Checkov Scan
8. Terraform plan

### Terraform CD

Our terraform CD workflow only consists of one step since all the checks have been done in the CI workflow.

1. Terraform Apply

### Docker CI

Docker files are stored in the ```files/``` directory in the repo.
We implement the following checks for our Docker CI workflow:

#### Python Safety Scan
  - Scans for vulnerabilities in third-party libraries and dependencies specified in requirements files.
#### Python Bandit Scan
  - Only scans the application code itself, detecting issues directly within the codebase.
#### Sonarqube scan
  - Analyzes source code to detect bugs, vulnerabilities, and code smells, providing insights into code quality and enabling teams to maintain clean and secure codebases.
#### Docker Build
  - Builds the Docker container locally on the runner to confirm that it can be built without errors.
#### Grype Container Scan
  - An open-source vulnerability scanner that identifies known security vulnerabilities in container images and filesystems.
#### Docker run test
  - Runs the Docker container to make sure it can launch successfully.

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
├── ce7-grp-2-jokes-lambda.zip        # A ZIP file containing the Lambda function code. 
├── dynamodb.tf                       # A file that defines resources related to DynamoDB.
├── lambda.tf                         # A file that defines the resources for the AWS Lambda function.
├── webapi_gtw.tf                     # A file that defines the resources for the AWS API Gateway.  
└── README.md                         # Documentation for the setup and usage
```
## The Great Laugh - Joke Web Application
Imagine a simple, fun, and engaging web application designed to deliver random jokes at the click of a button. Introducing The Great Laugh — a joke-sharing platform that’s not just about laughter but also showcases cutting-edge technology and serverless architecture.

### Main page

![webappscreen](https://github.com/user-attachments/assets/1b0646b0-143e-441d-abb4-5ea9e6f8404d)

### Joke Management Page

![mgmtpage](https://github.com/user-attachments/assets/c0d5ce22-fb80-4512-95fb-d6539bee8b0e)

### Key Features
1. Random Joke Generator
- Click a button to fetch a random joke from a dynamic pool of jokes.
- Each joke is retrieved through serverless APIs backed by AWS tools.
- Joke Management Interface

2. A sleek and user-friendly interface allows users to:
- Create new jokes.
- Edit existing jokes.
- Delete jokes they no longer find funny.

### Technologies Used
1. Frontend is built using:
- **Python**: Handles dynamic components of the application.
- **JavaScript**: Powers interactivity like button clicks and API calls.
- **HTML & CSS**: Provide a responsive and fun user interface.
- The entire frontend runs in a **Docker container** for easy portability and scaling.

2. Backend (Serverless)
The backend leverages **AWS serverless tools** for seamless management and scaling:
- **API Gateway**: Exposes RESTful endpoints for joke-related operations (Create, Read, Update, Delete).
- **AWS Lambda Function**: Executes backend logic such as fetching a random joke or updating the database.
- **Amazon DynamoDB**: Stores all jokes in a NoSQL database, ensuring fast retrieval and scalability.

### Jokes web application files/folder

```sh
Jokes-webapp-v2
├── static            # This directory contains static assets that are served directly to the client.		
│   ├── joke.png      # The image associated with the jokes (can be displayed in the frontend).
│   ├── styles.css    # The CSS file to style the webpage.
│
├── templates         # This directory holds the HTML templates used by the Flask application.
│   ├── index.html    # The main page of the application, which displays jokes.
│   ├── mgmt.html     # A management page, possibly for admin use to control the jokes.
│
├── .dockerignore     # Defines which files and directories should be excluded when building the Docker image.	
├── .env              # A file containing environment variables used by the application.
├── app.py            # The main entry point of the Flask application. (defines the routes and logic).
├── Dockerfile        # The file that contains instructions for building the Docker image.
├── jokes_setting.py  # Configuration settings related to how jokes are stored or fetched.
├── jokes_webapp.py   # A file containing the core logic of serving jokes to the user.
└── requirements.txt  # A file listing the Python dependencies required for the application.
```

## About AWS Serverless Tools
AWS provides powerful services that enable developers to build scalable, cost-efficient, and serverless applications. Among these, API Gateway, AWS Lambda, Amazon DynamoDB, REST APIs, and IAM stand out as essential tools for modern cloud development.

![APIG_tut_resources](https://github.com/user-attachments/assets/11e617c1-dbb4-4071-982e-ad49c57f02ea)

## API Gateway
AWS API Gateway acts as the front door for applications, enabling developers to design, deploy, and manage RESTful APIs without worrying about infrastructure. It integrates seamlessly with other AWS services like Lambda and DynamoDB, allowing you to build robust serverless applications. Key features include request transformation, traffic throttling, and built-in authentication mechanisms.

## REST API with API Gateway
A REST API is an architectural style that allows applications to interact over HTTP using standard methods like GET, POST, and DELETE. AWS API Gateway makes creating REST APIs simple, acting as a bridge between clients and backends such as Lambda functions or DynamoDB tables.

![API Gateway](https://github.com/user-attachments/assets/34db84b9-2c02-40c2-a648-d7f352de21c6)

## AWS Lambda
AWS Lambda is the backbone of serverless computing in AWS. It allows you to run code in response to triggers such as HTTP requests, database events, or changes in data streams. With Lambda, there’s no need to manage servers; AWS automatically handles scaling, making it ideal for lightweight, event-driven workloads.

![lambda](https://github.com/user-attachments/assets/c50afced-1b6c-45d8-9c76-d232076276a4)

## Amazon DynamoDB
A fully managed NoSQL database, Amazon DynamoDB is designed for high availability, low latency, and automatic scaling. It supports both key-value and document data models, making it a go-to choice for serverless architectures. DynamoDB works exceptionally well for real-time applications like gaming leaderboards, IoT systems, and e-commerce platforms.

![dynamodb](https://github.com/user-attachments/assets/363486f5-cd0a-4b62-8629-160f16c97d0d)

## IAM (Identity and Access Management)
AWS IAM secures access to resources in your AWS environment. It lets you create users, roles, and policies to control who can access what. For serverless architectures, IAM ensures that services like API Gateway and Lambda interact securely with DynamoDB or other resources, following the principle of least privilege.

![IamPolicy](https://github.com/user-attachments/assets/a65c7531-68dd-47fe-915e-1b19a722ddad)


## References

- https://www.parsectix.com/blog/github-oidc
- https://blog.clouddrove.com/github-actions-openid-connect-the-key-to-aws-authentication-dd9f66a7d31e
- https://blog.devops.dev/docker-hub-or-ghcr-or-ecr-lazy-mans-guide-4da1d943d26e
- https://cloudonaut.io/versus/container-registry/ecr-vs-github-container-registry/
- https://pirasanth.com/blog/how-to-build-and-push-docker-images-to-github-container-registry-with-github
