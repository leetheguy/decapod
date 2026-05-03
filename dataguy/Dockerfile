FROM alpine:latest

ARG AGENT_PASSWORD=changeme

# Install essentials
RUN apk add --no-cache \
    openssh \
    bash \
    curl \
    wget \
    git \
    vim \
    nano \
    python3 \
    py3-pip \
    nodejs \
    npm \
    zip \
    unzip \
    jq \
    sudo \
    gcompat

# Install uv (static binary, no libc issues)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    mv /root/.local/bin/uvx /usr/local/bin/uvx

# Create agent user with sudo access
RUN adduser -D -s /bin/bash agent && \
    echo "agent:${AGENT_PASSWORD}" | chpasswd && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN ssh-keygen -A && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
