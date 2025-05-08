#!/bin/bash
set -e

# Environment variables:
# S3_BUCKET: The S3 bucket for backups
# MINECRAFT_DIR: The directory containing the Minecraft world
# BACKUP_INTERVAL: The interval in seconds between backups (0 for one-time backup)
# BACKUP_PREFIX: Prefix for backup files in S3

# Default values
S3_BUCKET=${S3_BUCKET:-"minecraft-ecs-discord-backups"}
MINECRAFT_DIR=${MINECRAFT_DIR:-"/minecraft"}
BACKUP_INTERVAL=${BACKUP_INTERVAL:-0}
BACKUP_PREFIX=${BACKUP_PREFIX:-"world-backup"}

echo "Starting Minecraft backup"
echo "S3 Bucket: ${S3_BUCKET}"
echo "Minecraft Directory: ${MINECRAFT_DIR}"
echo "Backup Interval: ${BACKUP_INTERVAL} seconds"
echo "Backup Prefix: ${BACKUP_PREFIX}"

# Function to backup Minecraft world
backup_world() {
    # Get current timestamp
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_FILE="${BACKUP_PREFIX}-${TIMESTAMP}.tar.gz"
    BACKUP_PATH="/tmp/${BACKUP_FILE}"
    
    echo "Creating backup at ${TIMESTAMP}"
    
    # Check if world directory exists
    if [ ! -d "${MINECRAFT_DIR}/world" ]; then
        echo "World directory not found at ${MINECRAFT_DIR}/world"
        return 1
    fi
    
    # Create backup
    echo "Creating tar archive of world directory"
    tar -czf ${BACKUP_PATH} -C ${MINECRAFT_DIR} world
    
    # Upload to S3
    echo "Uploading backup to S3"
    aws s3 cp ${BACKUP_PATH} s3://${S3_BUCKET}/${BACKUP_FILE}
    
    # Remove local backup file
    rm ${BACKUP_PATH}
    
    echo "Backup completed and uploaded to s3://${S3_BUCKET}/${BACKUP_FILE}"
    
    # Create a latest.txt file with the name of the latest backup
    echo ${BACKUP_FILE} > /tmp/latest.txt
    aws s3 cp /tmp/latest.txt s3://${S3_BUCKET}/latest.txt
    rm /tmp/latest.txt
}

# Perform backup
if [ ${BACKUP_INTERVAL} -eq 0 ]; then
    # One-time backup
    backup_world
else
    # Continuous backup
    while true; do
        backup_world
        echo "Waiting ${BACKUP_INTERVAL} seconds before next backup..."
        sleep ${BACKUP_INTERVAL}
    done
fi