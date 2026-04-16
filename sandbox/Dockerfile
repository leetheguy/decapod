FROM ubuntu:24.04

# Build argument for agent password
ARG AGENT_PASSWORD=agent123

# Install essential tools
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    vim \
    nano \
    python3 \
    python3-pip \
    python3-venv \
    python3-psycopg2 \
    htop \
    tmux \
    unzip \
    zip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    mv /root/.local/bin/uvx /usr/local/bin/uvx

# Create agent user with sudo access (using build arg)
RUN useradd -m -s /bin/bash -G sudo agent && \
    echo "agent:${AGENT_PASSWORD}" | chpasswd && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install nvm and Node.js for agent user
RUN su - agent -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash" && \
    su - agent -c "export NVM_DIR=\"\$HOME/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\" && nvm install node"

# Add nvm to agent's .bashrc
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /home/agent/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/agent/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /home/agent/.bashrc

# Setup SSH - disable PAM to avoid container issues
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# Start SSH
CMD ["/usr/sbin/sshd", "-D"]