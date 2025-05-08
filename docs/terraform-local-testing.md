# Local Testing with Makefile

This project uses a Makefile to help with local testing of the Terraform configuration.

## Prerequisites

Before using the Makefile, ensure you have:

1. AWS CLI installed and configured
2. Terraform >= 1.0.0 installed
3. GNU Make installed
4. Bash shell (for Linux/Mac) or Git Bash/WSL (for Windows)

## Setup

1. Copy the `.env.example` file from the root directory to a new file named `.env`:

```bash
cp .env.example .env
```

2. Edit the `.env` file with your actual values:
   - Add your AWS credentials
   - Customize bucket names and other variables as needed
   - Set `USE_LOCAL_BACKEND=true` if you want to use a local backend for testing

## Usage

The Makefile provides several targets for working with Terraform:

### Show Available Targets

```bash
make help
```

This command shows all available targets with descriptions.

### Initialize Terraform

```bash
make init
```

This command initializes Terraform with either the S3 backend or a local backend, depending on your `.env` configuration.

### Plan Terraform Changes

```bash
make plan
```

This command initializes Terraform and creates a plan of the changes that will be applied.

### Apply Terraform Changes

```bash
make apply
```

This command initializes Terraform, creates a plan, and applies the changes.

### Destroy Terraform Resources

```bash
make destroy
```

This command initializes Terraform and destroys all resources created by Terraform.

## Notes

- For local testing, it's recommended to use a local backend or a separate S3 bucket to avoid conflicts with production state.
- Make sure your AWS credentials have the necessary permissions to create and manage the resources defined in the Terraform configuration.
- The script will automatically load environment variables from the `.env` file.
- Never commit your `.env` file to version control as it contains sensitive information.