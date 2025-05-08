#!/bin/bash
set -e

# Environment variables:
# S3_BUCKET: The S3 bucket for backups
# MINECRAFT_DIR: The directory containing the Minecraft world
# BACKUP_FILE: The specific backup file to restore (if not provided, latest will be used)

# Default values
S3_BUCKET=${S3_BUCKET:-"minecraft-ecs-discord-backups"}
MINECRAFT_DIR=${MINECRAFT_DIR:-"/minecraft"}
BACKUP_FILE=${BACKUP_FILE:-""}

echo "Starting Minecraft world restore"
echo "S3 Bucket: ${S3_BUCKET}"
echo "Minecraft Directory: ${MINECRAFT_DIR}"

# If no specific backup file is provided, get the latest
if [ -z "${BACKUP_FILE}" ]; then
    echo "No specific backup file provided, getting the latest"
    
    # Download latest.txt
    aws s3 cp s3://${S3_BUCKET}/latest.txt /tmp/latest.txt
    
    if [ $? -ne 0 ]; then
        echo "Failed to download latest.txt from S3. No backups available?"
        exit 1
    fi
    
    BACKUP_FILE=$(cat /tmp/latest.txt)
    rm /tmp/latest.txt
    
    echo "Latest backup is: ${BACKUP_FILE}"
fi

# Download the backup file
echo "Downloading backup file: ${BACKUP_FILE}"
aws s3 cp s3://${S3_BUCKET}/${BACKUP_FILE} /tmp/${BACKUP_FILE}

if [ $? -ne 0 ]; then
    echo "Failed to download backup file from S3"
    exit 1
fi

# Check if world directory already exists
if [ -d "${MINECRAFT_DIR}/world" ]; then
    echo "World directory already exists at ${MINECRAFT_DIR}/world"
    echo "Creating backup of existing world before restoring"
    
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    EXISTING_BACKUP="existing-world-${TIMESTAMP}.tar.gz"
    
    tar -czf /tmp/${EXISTING_BACKUP} -C ${MINECRAFT_DIR} world
    
    echo "Removing existing world directory"
    rm -rf ${MINECRAFT_DIR}/world
fi

# Create world directory if it doesn't exist
mkdir -p ${MINECRAFT_DIR}

# Extract the backup
echo "Extracting backup to ${MINECRAFT_DIR}"
tar -xzf /tmp/${BACKUP_FILE} -C ${MINECRAFT_DIR}

# Remove the downloaded backup file
rm /tmp/${BACKUP_FILE}

# Set permissions
echo "Setting permissions on world directory"
find ${MINECRAFT_DIR}/world -type d -exec chmod 755 {} \;
find ${MINECRAFT_DIR}/world -type f -exec chmod 644 {} \;

echo "Restore completed successfully"