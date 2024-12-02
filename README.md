# tf-aws-infra

# AWS Networking Setup with Terraform

This repository contains Terraform configuration files to set up an AWS networking infrastructure, including a Virtual Private Cloud (VPC), public and private subnets, an internet gateway, route tables, and more. The configuration is designed to be reusable, allowing you to create multiple VPCs in the same AWS account and region.

## Table of Contents

- [tf-aws-infra](#tf-aws-infra)
- [AWS Networking Setup with Terraform](#aws-networking-setup-with-terraform)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Variables](#variables)
  - [CLI Command for Certificate](#cli-command-for-certificate)
  - [Continuous Integration](#continuous-integration)
  - [Contributing](#contributing)

## Prerequisites

Before you begin, ensure you have the following installed:
 
- [Terraform](https://www.terraform.io/downloads.html) (version 1.4.0 or later)
- [AWS CLI](https://aws.amazon.com/cli/)
- An [AWS account](https://aws.amazon.com/)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/desaihir/tf-aws-infra.git
   cd tf-aws-infra
   ```

2. Configure your AWS credentials using the AWS CLI:
   ```bash
   aws configure
   ```

3. (Optional) Create a `.tfvars` file for variable values. See the [Variables](#variables) section for more details.

## Usage

1. Initialize the Terraform working directory:
   ```bash
   terraform init
   ```

2. Validate the Terraform configuration:
   ```bash
   terraform validate
   ```

3. Plan the deployment:
   ```bash
   terraform plan -var-file="your-variables.tfvars"
   ```

4. Apply the configuration to create the infrastructure:
   ```bash
   terraform apply -var-file="your-variables.tfvars"
   ```

5. To destroy the created resources, run:
   ```bash
   terraform destroy -var-file="your-variables.tfvars"
   ```

## Variables

You can customize the following variables in your `.tfvars` file or by passing them in the command line:

- `vpc_name`: Name of the VPC
- `vpc_cidr`: CIDR block for the VPC (e.g., `10.0.0.0/16`)
- `public_subnet_count`: Number of public subnets to create
- `private_subnet_count`: Number of private subnets to create
- `public_cidrs`: List of CIDR blocks for public subnets
- `private_cidrs`: List of CIDR blocks for private subnets
- `public_route_cidr`: Destination CIDR block for the public route (e.g., `0.0.0.0/0`)

## CLI Command for Certificate

```bash
   aws acm import-certificate \
     --certificate fileb://certificate.pem \
     --private-key fileb://privateKey.pem \
     --certificate-chain fileb://certificateChain.pem \
     --region us-east-1

## Continuous Integration

This repository uses GitHub Actions for Continuous Integration. Every time a pull request is created, the following checks will be performed:

- **Terraform Format**: Ensures that all Terraform files are properly formatted.
- **Terraform Validate**: Validates the Terraform configuration.

A pull request can only be merged if both checks pass. The CI workflow file can be found in `.github/workflows/terraform-ci.yml`.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes. 
