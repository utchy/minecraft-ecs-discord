# Makefile for Minecraft ECS Discord Terraform Configuration

# Check if .env file exists and include it
ifneq (,$(wildcard ./.env))
    include .env
    export
else
    $(error .env file not found. Please create one based on .env.example)
endif

# Default target
.PHONY: help
help:
	@echo "Minecraft ECS Discord - Terraform Makefile"
	@echo "=========================================="
	@echo "Available targets:"
	@echo "  make init     - Initialize Terraform"
	@echo "  make plan     - Initialize and plan Terraform changes"
	@echo "  make apply    - Initialize, plan, and apply Terraform changes"
	@echo "  make destroy  - Initialize and destroy Terraform resources"
	@echo "  make help     - Show this help message"

# Check AWS credentials
check-aws-credentials:
	@if [ -z "$(AWS_ACCESS_KEY_ID)" ] || [ -z "$(AWS_SECRET_ACCESS_KEY)" ]; then \
		echo "Error: AWS credentials not set in .env file"; \
		exit 1; \
	fi
	@echo "AWS credentials found."

# Initialize Terraform
.PHONY: init
init: check-aws-credentials
	@echo "Initializing Terraform..."
	@if [ "$(USE_LOCAL_BACKEND)" = "true" ]; then \
		echo "Using local backend for Terraform state..."; \
		cd terraform && terraform init -backend=false; \
	else \
		echo "Using S3 backend for Terraform state..."; \
		cd terraform && terraform init; \
	fi

# Plan Terraform changes
.PHONY: plan
plan: init
	@echo "Planning Terraform changes..."
	@cd terraform && terraform plan -out=tfplan

# Apply Terraform changes
.PHONY: apply
apply: plan
	@echo "Applying Terraform changes..."
	@cd terraform && terraform apply tfplan

# Destroy Terraform resources
.PHONY: destroy
destroy: init
	@echo "Destroying Terraform resources..."
	@cd terraform && terraform destroy