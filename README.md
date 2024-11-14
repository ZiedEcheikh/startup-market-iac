# Startup Market IAC
Market IAC is infrastructure as a code for public market that automatically scale up and down and run in a highly available configuration for mobile and web application.


## AWS Resources

* AWS ALB : Managed load balancer that routes incoming application or API traffic to targets ECS tasks.
* AWS Fragate Cluster: Hosts and manages the running of containerized applications.
* ESC Task Definition : Specifies the settings for the containers, such as the Docker image, CPU and memory requirements, and log configuration.
* ESC Task Service : Used to manage the deployment and scaling of the task.
* Amazon CloudWatch : Collects logs from ECS tasks for monitoring and troubleshooting.
* IAM Roles and Policies: Manages permissions required for ECS tasks to interact with AWS services securely.
* Security Group: Firewall that controls inbound and outbound traffic for ECS tasks and load balancers.

## Building from Source
### Prerequisites

* Git, python3.11
* Terraform: Install Terraform (version >= 1.9.0)
* AWS CLI: Install and configure the AWS CLI with a valid profile
* AWS Account: Ensure you have an AWS account with permissions to create the required resources (e.g., ECS, IAM, CloudWatch)

### Check out sources
```
$ git@github.com:ZiedEcheikh/startup-market-iac.git
```

### Create python virtual environment
```
$ python3 -m venv .venv
```

### Activate virtual environment

On Unix or MacOS, using the bash shell:

```
$ source .venv/bin/activate
```

On Windows using the Command Prompt:
```
$ \.venv\Scripts\activate.bat
```

### Install packages
```
$ pip3 install -r requirements.txt
```

### Install the git hook scripts
```
$ pre-commit install
```

### Run against all the files
```
$ pre-commit run --all-files
```

## Usage

### Configure Environment Variables
Define the following environment variables to simplify AWS access
```
$ export AWS_ACCESS_KEY_ID=your-access-key
$ export AWS_SECRET_ACCESS_KEY=your-secret-key
$ export AWS_DEFAULT_REGION=your-region
```

### Initialize Terraform
Initialize Terraform to download the necessary provider plugins
```
$ terraform init
```

### Apply the Configuration
Apply the Terraform configuration to create the AWS resources
```
$  terraform plan --var-file="./vars/dev.tfvars"
```
