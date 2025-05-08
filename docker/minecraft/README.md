# Minecraft Server Docker Image

This project uses the official `itzg/minecraft-server` Docker image from Docker Hub for running the Minecraft server. This is a popular, well-maintained image that provides a ready-to-use Minecraft server with many configuration options.

## Image Details

- **Image**: `itzg/minecraft-server:latest`
- **Source**: [Docker Hub](https://hub.docker.com/r/itzg/minecraft-server)
- **GitHub**: [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server)

## Configuration

The Minecraft server is configured through environment variables defined in the Terraform configuration. See `terraform/variables.tf` for the default configuration:

```terraform
variable "minecraft_env_vars" {
  description = "Environment variables for Minecraft server"
  type        = map(string)
  default = {
    EULA                    = "TRUE"
    TYPE                    = "PAPER"
    MEMORY                  = "1G"
    DIFFICULTY              = "normal"
    ALLOW_NETHER            = "true"
    ANNOUNCE_PLAYER_ACHIEVEMENTS = "true"
    ENABLE_COMMAND_BLOCK    = "true"
    GENERATE_STRUCTURES     = "true"
    LEVEL_TYPE              = "DEFAULT"
    MAX_PLAYERS             = "10"
    MODE                    = "survival"
    MOTD                    = "Weekend Minecraft Server"
    PVP                     = "true"
    ONLINE_MODE             = "true"
    VIEW_DISTANCE           = "10"
    SPAWN_PROTECTION        = "0"
  }
}
```

## Why No Custom Dockerfile?

This project uses the official image directly instead of creating a custom Dockerfile because:

1. The `itzg/minecraft-server` image is well-maintained and regularly updated
2. It provides all the functionality needed for this project
3. It has extensive configuration options via environment variables
4. Using the official image reduces maintenance overhead

If you need to customize the Minecraft server beyond what's possible with environment variables, you can create a custom Dockerfile in this directory that extends the base image.

## Example Custom Dockerfile

If you need to create a custom Minecraft server image, you can use this as a starting point:

```dockerfile
FROM itzg/minecraft-server:latest

# Add custom configurations, mods, or plugins
COPY custom-configs/ /config/

# Any additional customization steps
RUN echo "Custom setup complete"
```

For more information on customizing the Minecraft server, refer to the [official documentation](https://github.com/itzg/docker-minecraft-server).