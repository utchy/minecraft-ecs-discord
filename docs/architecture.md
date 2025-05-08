# Minecraft ECS Discord - Architecture

This document describes the architecture of the Minecraft ECS Discord project.

## Architecture Diagram

```mermaid
flowchart TD
    Discord[Discord Bot] -->|Commands| ECS
    S3[S3 Buckets\n(Mods/Backups)] <-->|Data| EFS
    EFS[EFS\n(Storage)] <-->|Data| ECS
    ECS[ECS Fargate\n(Minecraft)] -->|Trigger| Lambda
    CloudWatch[CloudWatch\n(Scheduling)] -->|Schedule| ECS
    Lambda[Lambda Functions\n(Auto-shutdown)]
```

## Components

This diagram shows the main components of the Minecraft ECS Discord architecture:

1. **Discord Bot** - Provides commands to control the Minecraft server
2. **ECS Fargate** - Runs the Minecraft server container
3. **EFS** - Provides persistent storage for the Minecraft world data
4. **S3 Buckets** - Store mods and backups
5. **Lambda Functions** - Handle auto-shutdown and other automation
6. **CloudWatch** - Schedules the auto-shutdown and monitors the system

The arrows indicate the flow of data and control between components.

## Component Details

### Discord Bot
- Implemented as a Python application using discord.py
- Provides slash commands for server control (/start, /stop, /status)
- Notifies users when the server starts with the IP address

### ECS Fargate
- Runs the Minecraft server as a containerized application
- Uses the itzg/minecraft-server Docker image
- Includes sidecar containers for mod synchronization and backups

### EFS (Elastic File System)
- Provides persistent storage for the Minecraft world data
- Ensures data is preserved when the server is stopped and started
- Mounted to the Minecraft server container

### S3 Buckets
- Store Minecraft mods for easy management
- Store backups of the Minecraft world
- Enable version control of mods and backups

### Lambda Functions
- Handle automated tasks like server shutdown
- Process Discord commands
- Manage server state

### CloudWatch
- Schedules automatic shutdown at 20:00 JST
- Monitors server performance
- Triggers Lambda functions based on schedule