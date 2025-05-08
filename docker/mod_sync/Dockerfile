FROM amazon/aws-cli:latest

# Install required packages
RUN yum install -y \
    jq \
    python3 \
    shadow-utils \
    && yum clean all

# Create a non-root user
RUN groupadd -g 1000 minecraft && \
    useradd -u 1000 -g minecraft -s /bin/bash -m minecraft

# Copy the sync script
COPY sync.sh /usr/local/bin/sync.sh
RUN chmod +x /usr/local/bin/sync.sh

# Set the working directory
WORKDIR /minecraft/mods

# Switch to the minecraft user
USER minecraft

# Run the sync script
CMD ["/usr/local/bin/sync.sh"]