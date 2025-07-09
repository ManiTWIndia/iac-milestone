# IaC Course - Assignment Solution

This repository contains the solution for the Infrastructure as Code (IaC) course assignment. It deploys a serverless application on AWS using Terraform, following best practices and modular design. The stack includes API Gateway, Lambda, S3, and DynamoDB, with remote state management, automated testing, and CI/CD integration.

---

## Project Overview

This project provisions the following AWS resources:

- **API Gateway (HTTP API):** Exposes endpoints for user registration and verification.
- **Lambda Functions:** 
  - `register_user` - Handles user registration and stores data in DynamoDB.
  - `verify_user` - Verifies users and fetches HTML content from S3.
- **DynamoDB Table:** Stores user data for registration and verification.
- **S3 Bucket:** Hosts static website files (`index.html` and `error.html`) used by the Lambda function.
- **IAM Roles & Policies:** Follows least privilege principle for Lambda and API Gateway.
- **Remote State:** Uses S3 backend for Terraform state management.
- **Automated Tests:** Python scripts to verify API functionality.
- **CI/CD:** GitHub Actions workflow for deployment, linting, and testing.

---

## Milestone 1: Infrastructure Foundation

- Deploys a Lambda function that returns "Hello world" for the `/` endpoint.
- API Gateway HTTP API routes requests to the Lambda.
- CloudWatch logging enabled for Lambda.
- S3 backend for remote state management.
- Automated test verifies the `/` endpoint returns "Hello world".

---

## Milestone 2: Functional Infrastructure

- Adds a DynamoDB table for user registration and verification.
- Adds an S3 bucket to host `index.html` and `error.html`.
- Implements two Lambda functions (`register_user`, `verify_user`) using `for_each` for modularity.
- API Gateway exposes `/register` (PUT) and `/` (GET) endpoints, each mapped to the appropriate Lambda.
- Lambdas use environment variables for table and bucket names.
- Least privilege IAM roles for Lambda and API Gateway.
- Automated tests cover:
  - Registering a user via `/register?userId=<user id>`
  - Verifying a registered user via `/?userId=<user id>`
  - Verifying a non-registered user (should return error page)
  - Handling invalid query strings for both endpoints
  - Idempotency and test independence
- Outputs include API Gateway URL, S3 bucket ARN, and DynamoDB ARN.

---

## Milestone 3: CI/CD and Advanced Features

- Adds GitHub Actions workflow for:
  - Deploying and destroying infrastructure using Terraform and remote state.
  - Linting Terraform code with `tflint`.
  - Checking Terraform formatting.
  - Running automated tests after deployment.
  - (Optional) Security checks (e.g., `checkov`).
- Uses OIDC for GitHub Actions to assume an AWS IAM role (least privilege, repo-restricted).
- Modularizes Terraform code using custom modules for Lambda, API Gateway, S3, and DynamoDB.
- README includes instructions for configuring and running CI/CD workflows.
- All previous acceptance criteria remain valid and are tested in CI.

---

## How to Deploy

1. **Clone the Repository**
   ```bash
   git clone <your-repo-url>
   cd iac-milestone
   ```

2. **Configure AWS Credentials**
   - Ensure your AWS CLI is configured with credentials for the target AWS account and region.

3. **Initialize Backend Terraform**
   ```bash
   cd backend
   terraform init
   terraform plan
   terraform apply
   ```

4. **Review and Set Variables**
   - Add `terraform.tfvars` or set variables as needed (e.g., `aws_region`, `user_prefix`, `environment`).

5. **Deploy the Infrastructure from root folder**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
   - Review the plan and type `yes` to confirm.

6. **Retrieve Outputs**
   - After deployment, Terraform will output the API Gateway URL, S3 bucket ARN, and DynamoDB ARN.

---

## How to Test

1. **Install Python Dependencies**
   ```bash
   pip install -r tests/requirements.txt
   ```

2. **Run Automated Test Scripts**
   - Copy the API Gateway URL from the Terraform output.
   - Run:
     ```bash
     python tests/test_milestone1.py <api_url>
     python tests/test_milestone2.py <api_url>
     ```
   - Tests will verify registration, verification, error handling, and idempotency.

---

## How to Destroy

To clean up all resources and avoid incurring AWS charges:

1. **Empty the S3 Bucket (if not handled automatically)**
   - If the S3 bucket is not empty, empty it manually via the AWS Console or CLI:
     ```bash
     aws s3 rm s3://<your-bucket-name> --recursive
     ```

2. **Destroy the Infrastructure**
   ```bash
   terraform destroy
   ```
   - Review the plan and type `yes` to confirm.

---

## CI/CD with GitHub Actions

- The repository includes a workflow in `.github/workflows/deploy.yaml` for automated deployment, linting, and testing.
- To enable CI/CD:
  1. Configure the required AWS OIDC role and permissions for GitHub Actions.
  2. Set repository secrets as needed (see workflow file for details).
  3. Push changes to trigger the workflow.
- The workflow will:
  - Deploy infrastructure using Terraform.
  - Lint and format Terraform code.
  - Run automated tests.
  - Optionally, run security checks.
  - Destroy infrastructure when requested.

---

## Project Structure

```
.
├── main.tf                # Main Terraform configuration
├── modules/               # Custom Terraform modules
├── tests/                 # Automated test scripts
├── src/                   # Lambda function source code
├── terraform.tfvars       # Variable values (not committed)
├── .github/workflows/     # GitHub Actions workflows
├── Readme.md              # This file
└── ...
```

---

## Notes

- Ensure you have the necessary IAM permissions to create and destroy AWS resources.
- All resources are named with a unique prefix to avoid conflicts in shared AWS accounts.
- For troubleshooting, check the AWS CloudWatch logs for Lambda function executions.
- For CI/CD, ensure your GitHub repository is configured with the correct AWS OIDC role and secrets.