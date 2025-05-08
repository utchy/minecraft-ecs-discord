#!/bin/bash
set -e

# Environment variables:
# S3_BUCKET: The S3 bucket containing the mods
# MODS_DIR: The directory where mods should be stored
# SYNC_INTERVAL: The interval in seconds between sync operations

# Default values
S3_BUCKET=${S3_BUCKET:-"minecraft-ecs-discord-mods"}
MODS_DIR=${MODS_DIR:-"/minecraft/mods"}
SYNC_INTERVAL=${SYNC_INTERVAL:-300}

echo "Starting mod sync sidecar"
echo "S3 Bucket: ${S3_BUCKET}"
echo "Mods Directory: ${MODS_DIR}"
echo "Sync Interval: ${SYNC_INTERVAL} seconds"

# Create mods directory if it doesn't exist
mkdir -p ${MODS_DIR}

# Function to sync mods from S3
sync_mods() {
    echo "Syncing mods from S3 bucket ${S3_BUCKET} to ${MODS_DIR}"
    aws s3 sync s3://${S3_BUCKET}/ ${MODS_DIR}/ --delete
    
    # Set permissions
    find ${MODS_DIR} -type d -exec chmod 755 {} \;
    find ${MODS_DIR} -type f -exec chmod 644 {} \;
    
    echo "Sync completed at $(date)"
}

# Initial sync
sync_mods

# Continuous sync
while true; do
    echo "Waiting ${SYNC_INTERVAL} seconds before next sync..."
    sleep ${SYNC_INTERVAL}
    sync_mods
done