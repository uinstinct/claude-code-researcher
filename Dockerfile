FROM ubuntu:26.04

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

# Install Python, pip and venv
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Install Golang (latest stable, resolved at build time) -- system-wide
RUN ARCH=$(dpkg --print-architecture) && \
    GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -n1) && \
    curl -fsSL "https://go.dev/dl/${GO_VERSION}.linux-${ARCH}.tar.gz" -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install sudo
RUN apt-get update && apt-get install -y sudo && \
    rm -rf /var/lib/apt/lists/*

# Set root password and allow root login (Optional, not recommended for production)
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Create a non-root user 'happy' with (password-protected) sudo capabilities
RUN useradd -m -s /bin/bash happy && \
    echo 'happy:password' | chpasswd && \
    usermod -aG sudo happy

# Everything below installs the dev toolchain for 'happy' only (not root)
USER happy
WORKDIR /home/happy
ENV HOME=/home/happy

# Install Rust via rustup (into happy's home)
ENV RUSTUP_HOME=/home/happy/.rustup CARGO_HOME=/home/happy/.cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# Install nvm (Node Version Manager) and the latest LTS Node.js (into happy's home)
ENV NVM_DIR=/home/happy/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && nvm install --lts && nvm alias default 'lts/*'

# Install uv (Python package/project manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add ~/.local/bin and ~/.cargo/bin to path for interactive shells
RUN echo 'export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc
ENV PATH="/home/happy/.cargo/bin:/home/happy/.local/bin:${PATH}"

# Install claude code (into happy's home)
RUN curl -fsSL https://claude.ai/install.sh | bash

# Switch back to root so sshd can start the daemon
USER root

# Expose port 22
EXPOSE 22

# Start SSH service when container launches
CMD ["/usr/sbin/sshd", "-D"]
