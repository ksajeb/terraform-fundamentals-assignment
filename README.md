# Terraform Fundamentals with AWS

A hands-on learning repository for practicing **Terraform Infrastructure as Code (IaC)** with **Amazon Web Services (AWS)**. The exercises are organized by topic and follow the core Terraform workflow: define infrastructure in configuration files, initialize providers and modules, review an execution plan, provision resources, inspect state, and manage isolated workspaces.

> **Purpose:** Learning and practice. The configurations are intended for experimentation in an AWS account, not as production-ready infrastructure.

## Repository

[**terraform-fundamentals-assignment**](https://github.com/ksajeb/terraform-fundamentals-assignment)

## Topics covered

| Directory | Focus | What you practise |
| --- | --- | --- |
| `create/` | Creating infrastructure | Configure the AWS provider, look up an Ubuntu AMI with a data source, and provision an EC2 instance. |
| `manage/` | Managing infrastructure | Use input variables, consume the `terraform-aws-modules/vpc/aws` module, create a VPC with public and private subnets, and launch an EC2 instance in a private subnet. |
| `tf-workspaces/` | Terraform workspaces | Workspace-based environment/state separation exercises. Review the configuration in this folder before running commands. |

## Repository structure

```text
terraform-fundamentals-assignment/
├── create/
│   └── main.tf
├── manage/
│   ├── main.tf
│   └── variables.tf
├── tf-workspaces/
├── .gitignore
└── .terraform.lock.hcl
```

The exact files in each exercise folder may grow as the tutorials are extended. Run Terraform from the relevant exercise directory so that it uses that directory's configuration and state.

## Prerequisites

Install the following before starting:

- **Terraform CLI** — used to initialize, validate, plan, apply, and destroy infrastructure.
- **AWS CLI** — used to configure and verify access to AWS.
- **An AWS account** with permissions to create the resources used by the exercise.
- **Git** — to clone and version-control the repository.

Verify the installations:

```bash
terraform version
aws --version
git --version
```

## AWS authentication

Terraform uses the AWS provider and needs AWS credentials. Configure credentials locally using an AWS CLI profile:

```bash
aws configure
```

Enter your access key, secret key, default region, and output format when prompted. The configurations in this repository use the **Asia Pacific (Mumbai)** region:

```text
ap-south-1
```

Verify which identity your CLI credentials represent:

```bash
aws sts get-caller-identity
```

Do not commit access keys, secret keys, session tokens, or other credentials to this repository. Prefer an IAM identity with only the permissions required for the exercise.

## Getting started

Clone the repository:

```bash
git clone https://github.com/ksajeb/terraform-fundamentals-assignment.git
cd terraform-fundamentals-assignment
```

Choose an exercise and move into its directory. For example:

```bash
cd create
```

Run the standard Terraform workflow:

```bash
# Download required providers and initialize the working directory
terraform init

# Check formatting
terraform fmt -recursive

# Check configuration syntax and internal consistency
terraform validate

# Preview the changes Terraform intends to make
terraform plan

# Create or update the infrastructure
terraform apply
```

Read the plan carefully before approving an apply. Terraform will ask for confirmation unless automatic approval is explicitly enabled.

To remove resources created by the current exercise:

```bash
terraform destroy
```

Run `terraform destroy` from the same exercise directory and with the same backend/workspace used for the apply. Review the destroy plan before confirming.

## Exercise notes

### 1. Create — EC2 instance

Path: `create/`

This configuration:

- Configures the AWS provider for `ap-south-1`.
- Uses an AWS AMI data source to look up an Ubuntu 24.04 image published by Canonical.
- Creates an EC2 instance using the selected AMI.
- Uses the `t3.micro` instance type and applies the `Name = learning-tf` tag.

**Key learning:** A Terraform data source reads information that already exists outside the configuration—in this case, an AMI ID—while a resource block declares infrastructure Terraform should manage.

Useful commands:

```bash
cd create
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### 2. Manage — VPC, subnets, and EC2

Path: `manage/`

This configuration:

- Uses the `terraform-aws-modules/vpc/aws` community module.
- Defines a VPC with CIDR block `10.0.0.0/16`.
- Defines public and private subnet ranges across three availability zones in `ap-south-1`.
- Enables VPC DNS hostnames.
- Looks up an Ubuntu 24.04 AMI.
- Creates an EC2 instance using input variables for its name and instance type.
- Places the instance in the first private subnet and associates the VPC module's default security group.

The current variable defaults are:

| Variable | Default |
| --- | --- |
| `instance_name` | `learning-terraform-2` |
| `instance_type` | `t3.micro` |

You can override a variable at plan/apply time, for example:

```bash
terraform plan -var="instance_name=terraform-lab" -var="instance_type=t3.micro"
terraform apply -var="instance_name=terraform-lab" -var="instance_type=t3.micro"
```

**Key learning:** Modules help reuse established infrastructure patterns, and variables make configurations easier to customize. A private-subnet EC2 instance is not automatically reachable from the public internet; access requires an intentionally designed network path.

Useful commands:

```bash
cd manage
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### 3. Terraform workspaces

Path: `tf-workspaces/`

Terraform workspaces let you maintain multiple named state instances for one configuration. They can be useful for learning how the same configuration is tracked separately in different workspaces.

Common workspace commands (run from the `tf-workspaces/` directory):

```bash
# List available workspaces
terraform workspace list

# Show the currently selected workspace
terraform workspace show

# Create and switch to a workspace
terraform workspace new dev

# Switch to an existing workspace
terraform workspace select default

# Show the current workspace's state
terraform state list
```

A workspace does **not** automatically create a separate AWS account, separate credentials, or a separate configuration. Be deliberate about naming, variables, and resource naming so that resources from different workspaces do not conflict. For production isolation, separate accounts and appropriately designed state backends are often a better choice than relying on CLI workspaces alone.

## Terraform state

Terraform state records the relationship between the configuration and the real infrastructure Terraform manages.

Useful commands:

```bash
# List resources tracked in the current state
terraform state list

# Display the current state
terraform show

# Show the active workspace
terraform workspace show
```

State files can contain sensitive information. Do not commit `terraform.tfstate`, `terraform.tfstate.backup`, plan files, or secret-bearing variable files. For team or production use, consider a remote backend with encryption, access controls, and state locking.

## Cost and security considerations

- **AWS resources may incur charges.** EC2 instances, EBS volumes, VPC-related resources, public IPv4 addresses, and other services can have costs depending on account eligibility, region, and usage.
- Check the AWS Billing and Cost Management console before and after running an exercise.
- Run `terraform destroy` when you have finished and no longer need the resources.
- A successful destroy in one directory does not destroy resources managed from another directory or workspace.
- The EC2 instance in `manage/` is configured in a private subnet. Do not assume it has internet access or can be reached over SSH; inspect the route tables, NAT configuration, security groups, and access path.
- Never hard-code AWS credentials in Terraform files or commit sensitive `.tfvars` files.

## Files and Terraform conventions

- `.tf` files contain declarative infrastructure configuration written in HashiCorp Configuration Language (HCL).
- `terraform init` initializes the working directory and downloads the required providers and modules.
- `terraform plan` previews proposed infrastructure changes.
- `terraform apply` executes the approved plan.
- `terraform destroy` removes resources managed by the selected configuration and state.
- `.terraform.lock.hcl` records selected provider versions and checksums. Commit the dependency lock file so that future initializations use consistent provider selections. (The repository's current `.gitignore` also contains a lock-file ignore rule; if the lock file is intended to be version-controlled, remove that ignore rule.)

## Learning outcomes

By completing these exercises, you practise:

- Configuring the AWS provider and authenticating with AWS.
- Finding an AMI dynamically with a data source.
- Defining and provisioning EC2 infrastructure.
- Structuring configurations with variables.
- Reusing infrastructure through Terraform modules.
- Building VPC networking with public and private subnets.
- Understanding Terraform state and CLI workspaces.
- Following the init → format/validate → plan → apply → inspect → destroy workflow.

## References

- [Terraform documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform CLI workspaces](https://developer.hashicorp.com/terraform/cli/workspaces)
- [AWS VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [AWS CLI configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

---

**Author:** [Sajeb Khan](https://github.com/ksajeb)  
**Repository:** [ksajeb/terraform-fundamentals-assignment](https://github.com/ksajeb/terraform-fundamentals-assignment)
