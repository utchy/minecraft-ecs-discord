FROM amazon/aws-cli:latest

# Install required packages
RUN yum install -y \
    jq \
    python3 \
    shadow-utils \
    tar \
    gzip \
    && yum clean all

# Create a non-root user
RUN groupadd -g 1000 minecraft && \
    useradd -u 1000 -g minecraft -s /bin/bash -m minecraft

# Copy the backup and restore scripts
COPY backup.sh /usr/local/bin/backup.sh
COPY restore.sh /usr/local/bin/restore.sh
RUN chmod +x /usr/local/bin/backup.sh /usr/local/bin/restore.sh

# Set the working directory
WORKDIR /minecraft

# Switch to the minecraft user
USER minecraft

# Default command (can be overridden)
CMD ["/usr/local/bin/backup.sh"]