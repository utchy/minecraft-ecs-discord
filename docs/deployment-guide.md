# Minecraft ECS Discord - Deployment Guide

This guide provides detailed instructions for deploying and using the Minecraft ECS Discord project.

## Prerequisites

Before you begin, ensure you have:

1. An AWS account with appropriate permissions
2. A Discord account and a server where you have admin permissions
3. Git installed on your local machine
4. AWS CLI configured with your credentials (for manual deployment)
5. Terraform >= 1.0.0 installed (for manual deployment)
6. Docker installed (for local testing)

## Step 1: Set Up Discord Bot

1. Go to the [Discord Developer Portal](https://discord.com/developers/applications)
2. Click "New Application" and give it a name (e.g., "Minecraft Controller")
3. Go to the "Bot" tab and click "Add Bot"
4. Under the "Privileged Gateway Intents" section, enable "Message Content Intent"
5. Copy the bot token (you'll need this later)
6. Go to the "OAuth2" tab, then "URL Generator"
7. Select the following scopes:
   - bot
   - applications.commands
8. Select the following bot permissions:
   - Send Messages
   - Read Message History
   - Use Slash Commands
9. Copy the generated URL and open it in your browser
10. Select your Discord server and authorize the bot
11. In your Discord server, create a channel for the bot (e.g., #minecraft)
12. Right-click on the channel and select "Copy ID" (you'll need this later)

## Step 2: Fork and Clone the Repository

1. Fork this repository on GitHub
2. Clone your fork to your local machine:

```bash
git clone https://github.com/yourusername/minecraft-ecs-discord.git
cd minecraft-ecs-discord
```

## Step 3: Set Up GitHub Secrets

In your GitHub repository:

1. Go to "Settings" > "Secrets and variables" > "Actions"
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `DISCORD_BOT_TOKEN`: The bot token you copied earlier
   - `DISCORD_CHANNEL_ID`: The channel ID you copied earlier

## Step 4: Deploy the Infrastructure

### Automated Deployment (Recommended)

1. Push any changes to the main branch, or:
2. Go to the "Actions" tab in your GitHub repository
3. Select the "Deploy Minecraft Server Infrastructure" workflow
4. Click "Run workflow" and select the main branch
5. Wait for the workflow to complete (this may take 15-20 minutes)

### Manual Deployment

If you prefer to deploy manually:

1. Create the required S3 bucket and DynamoDB table:

```bash
aws s3 mb s3://minecraft-ecs-discord-tfstate
aws dynamodb create-table \
  --table-name minecraft-ecs-discord-tfstate-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

2. Initialize and apply the Terraform configuration:

```bash
cd terraform
terraform init
terraform apply
```

3. Update the SSM parameters with your Discord bot token and channel ID:

```bash
aws ssm put-parameter \
  --name "/minecraft-ecs-discord/discord-bot-token" \
  --value "YOUR_DISCORD_BOT_TOKEN" \
  --type "SecureString" \
  --overwrite

aws ssm put-parameter \
  --name "/minecraft-ecs-discord/discord-channel-id" \
  --value "YOUR_DISCORD_CHANNEL_ID" \
  --type "String" \
  --overwrite
```

### Local Testing

For testing the Terraform configuration locally before deploying to AWS:

1. Copy the `.env.example` file to `.env`:

```bash
cp .env.example .env
```

2. Edit the `.env` file with your AWS credentials and other settings:
   - Set `USE_LOCAL_BACKEND=true` if you want to use a local backend instead of S3
   - Customize bucket names and other variables as needed

3. Use the Makefile to initialize, plan, and apply the Terraform configuration:

```bash
make help    # Show available commands
make plan    # Plan Terraform changes
make apply   # Apply Terraform changes
```

For more detailed instructions on local testing, see the [Local Testing with Makefile Guide](terraform-local-testing.md).

## Step 5: Verify the Deployment

1. Check that the ECS cluster has been created:

```bash
aws ecs list-clusters
```

2. Check that the Lambda functions have been created:

```bash
aws lambda list-functions | grep minecraft-ecs-discord
```

3. Go to your Discord server and check that the bot is online
4. Try using the `/status` command to check the server status

## Using the Minecraft Server

### Discord Commands

- `/start` - Start the Minecraft server
- `/stop` - Stop the Minecraft server
- `/status` - Check the status and get the IP address

### Adding Mods

1. Upload mod JAR files to the S3 bucket:

```bash
aws s3 cp your-mod.jar s3://minecraft-ecs-discord-mods/
```

2. The mods will be automatically synchronized to the server within 5 minutes
3. If you want to force an immediate sync, restart the server using the `/stop` and `/start` commands

### Managing Backups

Backups are automatically created when the server stops. To manually create a backup:

1. Get the subnet IDs and security group IDs:

```bash
aws ecs describe-services \
  --cluster minecraft-ecs-discord-cluster \
  --services minecraft-ecs-discord-service \
  --query 'services[0].networkConfiguration.awsvpcConfiguration'
```

2. Run the backup task:

```bash
aws ecs run-task \
  --cluster minecraft-ecs-discord-cluster \
  --task-definition minecraft-ecs-discord-backup \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-id],securityGroups=[sg-id],assignPublicIp=ENABLED}"
```

To restore from a backup:

1. List available backups:

```bash
aws s3 ls s3://minecraft-ecs-discord-backups/
```

2. Run the restore task with the desired backup file:

```bash
aws ecs run-task \
  --cluster minecraft-ecs-discord-cluster \
  --task-definition minecraft-ecs-discord-restore \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-id],securityGroups=[sg-id],assignPublicIp=ENABLED}" \
  --overrides '{"containerOverrides": [{"name": "restore", "environment": [{"name": "BACKUP_FILE", "value": "world-backup-20230101-120000.tar.gz"}]}]}'
```

## Customizing the Server

### Minecraft Server Properties

To customize the Minecraft server properties:

1. Edit the `terraform/variables.tf` file
2. Modify the `minecraft_env_vars` variable to change server properties
3. Commit and push your changes, or run `terraform apply` if deploying manually

### Server Resources

To adjust the CPU and memory allocated to the server:

1. Edit the `terraform/variables.tf` file
2. Modify the `minecraft_cpu` and `minecraft_memory` variables
3. Commit and push your changes, or run `terraform apply` if deploying manually

## Troubleshooting

### Server Not Starting

Check the ECS service logs:

```bash
aws logs get-log-events \
  --log-group-name /ecs/minecraft-ecs-discord \
  --log-stream-name minecraft/latest
```

### Discord Bot Not Responding

Check the Lambda function logs:

```bash
aws logs get-log-events \
  --log-group-name /aws/lambda/minecraft-ecs-discord-discord-bot \
  --log-stream-name latest
```

### Auto-Shutdown Not Working

Check the CloudWatch Events rule:

```bash
aws events describe-rule --name minecraft-ecs-discord-auto-shutdown
```

And check the Lambda function logs:

```bash
aws logs get-log-events \
  --log-group-name /aws/lambda/minecraft-ecs-discord-auto-shutdown \
  --log-stream-name latest
```

## Cleaning Up

To remove all resources when you're done:

```bash
cd terraform
terraform destroy
```

Note: This will delete all resources, including the Minecraft world data. Make sure to create a backup first if you want to keep your world.
