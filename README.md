# IaC Course - Assignment Solution

This repository contains the solution for Milestone 1 of the Infrastructure as Code assignment. It deploys a simple "Hello World" serverless application on AWS using Terraform.

## How to Test

1.  **Install Dependencies**: Run `pip install -r tests/requirements.txt`.
2.  **Run Test Script**: Execute the test script, passing the API URL from the deployment output:
    ```bash
    python tests/test_milestone1.py <paste_your_api_url_here>
    ```
You should see a "Test PASSED!" message.

---

## How to Destroy

To avoid leaving resources running, you can destroy all the created infrastructure.

1.  Run `terraform destroy` and approve by typing `yes`.