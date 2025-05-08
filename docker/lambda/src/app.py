import os
import logging
import boto3
import requests
import json

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Get environment variables
ECS_CLUSTER_NAME = os.getenv('ECS_CLUSTER_NAME')
ECS_SERVICE_NAME = os.getenv('ECS_SERVICE_NAME')
DISCORD_BOT_TOKEN_PARAMETER = os.getenv('DISCORD_BOT_TOKEN_PARAMETER')
DISCORD_CHANNEL_ID_PARAMETER = os.getenv('DISCORD_CHANNEL_ID_PARAMETER')
AWS_REGION = os.getenv('AWS_REGION', 'ap-northeast-1')

# Initialize AWS clients
ecs_client = boto3.client('ecs', region_name=AWS_REGION)
ssm_client = boto3.client('ssm', region_name=AWS_REGION)

def get_discord_credentials():
    """Retrieve Discord bot token and channel ID from SSM Parameter Store"""
    try:
        # Get Discord bot token
        token_response = ssm_client.get_parameter(
            Name=DISCORD_BOT_TOKEN_PARAMETER,
            WithDecryption=True
        )
        discord_bot_token = token_response['Parameter']['Value']
        
        # Get Discord channel ID
        channel_response = ssm_client.get_parameter(
            Name=DISCORD_CHANNEL_ID_PARAMETER
        )
        discord_channel_id = channel_response['Parameter']['Value']
        
        return discord_bot_token, discord_channel_id
    except Exception as e:
        logger.error(f"Error retrieving Discord credentials: {e}")
        return None, None

def stop_minecraft_server():
    """Stop the Minecraft server by setting desired count to 0"""
    try:
        # Update the service to set desired count to 0
        response = ecs_client.update_service(
            cluster=ECS_CLUSTER_NAME,
            service=ECS_SERVICE_NAME,
            desiredCount=0
        )
        return True
    except Exception as e:
        logger.error(f"Error stopping Minecraft server: {e}")
        return False

def send_discord_notification(token, channel_id, message):
    """Send a notification to Discord channel"""
    try:
        url = f"https://discord.com/api/v10/channels/{channel_id}/messages"
        headers = {
            "Authorization": f"Bot {token}",
            "Content-Type": "application/json"
        }
        payload = {
            "content": message
        }
        
        response = requests.post(url, headers=headers, data=json.dumps(payload))
        response.raise_for_status()
        return True
    except Exception as e:
        logger.error(f"Error sending Discord notification: {e}")
        return False

def handler(event, context):
    """Lambda handler function"""
    logger.info("Auto-shutdown Lambda function triggered")
    
    # Stop the Minecraft server
    success = stop_minecraft_server()
    
    if success:
        logger.info("Minecraft server stopped successfully")
        
        # Send notification to Discord
        discord_bot_token, discord_channel_id = get_discord_credentials()
        
        if discord_bot_token and discord_channel_id:
            message = "🕘 **Automatic Shutdown**: The Minecraft server has been shut down for the night. See you tomorrow!"
            notification_sent = send_discord_notification(discord_bot_token, discord_channel_id, message)
            
            if notification_sent:
                logger.info("Discord notification sent successfully")
            else:
                logger.warning("Failed to send Discord notification")
        else:
            logger.warning("Could not retrieve Discord credentials")
    else:
        logger.error("Failed to stop Minecraft server")
    
    return {
        'statusCode': 200 if success else 500,
        'body': json.dumps({
            'message': 'Minecraft server shutdown completed' if success else 'Failed to shutdown Minecraft server'
        })
    }