FROM ubuntu:24.04

# set TZ to prevent timezone questions in installation
ENV TZ=UTC
# debian do not ask questions
ENV DEBIAN_FRONTEND=noninteractive

# Install OpenSSH Server
RUN apt-get update
RUN apt-get install -y openssh-server && \
    # Create the missing privilege separation directory
    mkdir -p /run/sshd && \
    # Generate host keys (otherwise sshd might complain about missing keys)
    ssh-keygen -A && \
    # Cleanup to reduce image size
    rm -rf /var/lib/apt/lists/*

# Install git, curl, build-essential
RUN apt update && apt install -y git curl build-essential

# Add ~/.local/bin to path
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# Install claude code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Create a user and set password (Example: user/password)
RUN echo 'root:password' | chpasswd

# Allow root login (Optional, not recommended for production)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Expose port 22
EXPOSE 22

# Start SSH service when container launches
CMD ["/usr/sbin/sshd", "-D"]
