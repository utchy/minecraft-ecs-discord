output "efs_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.minecraft.id
}

output "efs_arn" {
  description = "The ARN of the EFS file system"
  value       = aws_efs_file_system.minecraft.arn
}

output "minecraft_access_point_id" {
  description = "The ID of the Minecraft access point"
  value       = aws_efs_access_point.minecraft.id
}

output "mods_access_point_id" {
  description = "The ID of the mods access point"
  value       = aws_efs_access_point.mods.id
}

output "backups_access_point_id" {
  description = "The ID of the backups access point"
  value       = aws_efs_access_point.backups.id
}

output "efs_security_group_id" {
  description = "The ID of the EFS security group"
  value       = aws_security_group.efs.id
}