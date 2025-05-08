import os
import logging
import asyncio
import boto3
import discord
from discord import app_commands
from discord.ext import commands
import time

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Get environment variables
DISCORD_BOT_TOKEN = os.getenv('DISCORD_BOT_TOKEN')
DISCORD_CHANNEL_ID = int(os.getenv('DISCORD_CHANNEL_ID', '0'))
ECS_CLUSTER_NAME = os.getenv('ECS_CLUSTER_NAME')
ECS_SERVICE_NAME = os.getenv('ECS_SERVICE_NAME')
AWS_REGION = os.getenv('AWS_REGION', 'ap-northeast-1')

# Initialize AWS clients
ecs_client = boto3.client('ecs', region_name=AWS_REGION)
ec2_client = boto3.client('ec2', region_name=AWS_REGION)

# Initialize Discord bot
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents)

# Function to get the public IP of the Minecraft server
async def get_minecraft_server_ip():
    try:
        # Get the task ARN
        tasks = ecs_client.list_tasks(
            cluster=ECS_CLUSTER_NAME,
            serviceName=ECS_SERVICE_NAME
        )
        
        if not tasks['taskArns']:
            return None
        
        task_arn = tasks['taskArns'][0]
        
        # Get the task details
        task = ecs_client.describe_tasks(
            cluster=ECS_CLUSTER_NAME,
            tasks=[task_arn]
        )
        
        # Get the ENI ID
        attachment = task['tasks'][0]['attachments'][0]
        eni_id = None
        for detail in attachment['details']:
            if detail['name'] == 'networkInterfaceId':
                eni_id = detail['value']
                break
        
        if not eni_id:
            return None
        
        # Get the public IP
        eni = ec2_client.describe_network_interfaces(
            NetworkInterfaceIds=[eni_id]
        )
        
        if 'PublicIp' in eni['NetworkInterfaces'][0]:
            return eni['NetworkInterfaces'][0]['PublicIp']
        
        return None
    except Exception as e:
        logger.error(f"Error getting Minecraft server IP: {e}")
        return None

# Function to start the Minecraft server
async def start_minecraft_server():
    try:
        # Update the service to set desired count to 1
        response = ecs_client.update_service(
            cluster=ECS_CLUSTER_NAME,
            service=ECS_SERVICE_NAME,
            desiredCount=1
        )
        return True
    except Exception as e:
        logger.error(f"Error starting Minecraft server: {e}")
        return False

# Function to stop the Minecraft server
async def stop_minecraft_server():
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

# Function to check if the Minecraft server is running
async def is_minecraft_server_running():
    try:
        # Get the service details
        service = ecs_client.describe_services(
            cluster=ECS_CLUSTER_NAME,
            services=[ECS_SERVICE_NAME]
        )
        
        # Check if the service has running tasks
        running_count = service['services'][0]['runningCount']
        return running_count > 0
    except Exception as e:
        logger.error(f"Error checking if Minecraft server is running: {e}")
        return False

@bot.event
async def on_ready():
    logger.info(f'Logged in as {bot.user.name} ({bot.user.id})')
    
    # Sync commands with Discord
    try:
        synced = await bot.tree.sync()
        logger.info(f"Synced {len(synced)} command(s)")
    except Exception as e:
        logger.error(f"Failed to sync commands: {e}")
    
    # Send a message to the specified channel
    if DISCORD_CHANNEL_ID:
        channel = bot.get_channel(DISCORD_CHANNEL_ID)
        if channel:
            await channel.send("Minecraft Discord Bot is now online! Use /start to start the server and /stop to stop it.")

# Command to start the Minecraft server
@bot.tree.command(name="start", description="Start the Minecraft server")
async def start_command(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    
    # Check if the server is already running
    if await is_minecraft_server_running():
        await interaction.followup.send("The Minecraft server is already running!")
        return
    
    # Start the server
    success = await start_minecraft_server()
    
    if success:
        await interaction.followup.send("Starting the Minecraft server... This may take a few minutes.")
        
        # Wait for the server to start and get its IP
        for _ in range(30):  # Wait up to 5 minutes (30 * 10 seconds)
            await asyncio.sleep(10)
            
            if await is_minecraft_server_running():
                # Wait a bit more for the server to fully initialize
                await asyncio.sleep(30)
                
                ip = await get_minecraft_server_ip()
                if ip:
                    await interaction.followup.send(f"Minecraft server is now running! Connect to: **{ip}:25565**")
                    return
        
        await interaction.followup.send("Minecraft server started, but couldn't get the IP address. Please try the /status command in a few minutes.")
    else:
        await interaction.followup.send("Failed to start the Minecraft server. Please check the logs.")

# Command to stop the Minecraft server
@bot.tree.command(name="stop", description="Stop the Minecraft server")
async def stop_command(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    
    # Check if the server is running
    if not await is_minecraft_server_running():
        await interaction.followup.send("The Minecraft server is not running!")
        return
    
    # Stop the server
    success = await stop_minecraft_server()
    
    if success:
        await interaction.followup.send("Stopping the Minecraft server... This may take a few minutes.")
        
        # Wait for the server to stop
        for _ in range(12):  # Wait up to 2 minutes (12 * 10 seconds)
            await asyncio.sleep(10)
            
            if not await is_minecraft_server_running():
                await interaction.followup.send("Minecraft server has been stopped.")
                return
        
        await interaction.followup.send("Minecraft server is still stopping. Please check the status later.")
    else:
        await interaction.followup.send("Failed to stop the Minecraft server. Please check the logs.")

# Command to check the status of the Minecraft server
@bot.tree.command(name="status", description="Check the status of the Minecraft server")
async def status_command(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    
    # Check if the server is running
    if await is_minecraft_server_running():
        ip = await get_minecraft_server_ip()
        if ip:
            await interaction.followup.send(f"Minecraft server is running! Connect to: **{ip}:25565**")
        else:
            await interaction.followup.send("Minecraft server is running, but couldn't get the IP address.")
    else:
        await interaction.followup.send("Minecraft server is not running. Use /start to start it.")

# Run the bot
if __name__ == '__main__':
    if not DISCORD_BOT_TOKEN:
        logger.error("DISCORD_BOT_TOKEN environment variable is not set")
        exit(1)
    
    bot.run(DISCORD_BOT_TOKEN)