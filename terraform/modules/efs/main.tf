resource "aws_efs_file_system" "minecraft" {
  creation_token = "${var.project_name}-efs"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "minecraft" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.minecraft.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${var.project_name}-efs-sg"
  description = "Allow EFS access from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from ECS tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-efs-sg"
  }
}

# Create access point for Minecraft data
resource "aws_efs_access_point" "minecraft" {
  file_system_id = aws_efs_file_system.minecraft.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/minecraft"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "${var.project_name}-minecraft-ap"
  }
}

# Create access point for mods
resource "aws_efs_access_point" "mods" {
  file_system_id = aws_efs_file_system.minecraft.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/minecraft/mods"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "${var.project_name}-mods-ap"
  }
}

# Create access point for backups
resource "aws_efs_access_point" "backups" {
  file_system_id = aws_efs_file_system.minecraft.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/minecraft/backups"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "${var.project_name}-backups-ap"
  }
}