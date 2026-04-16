FROM n8nio/runners:latest

USER root

# Install llama-index into the Python runner's venv using uv (already in the image)
RUN uv pip install --python /opt/runners/task-runner-python/.venv/bin/python llama-index

# Copy task runner config with llama-index allowlisted
COPY n8n-task-runners.json /etc/n8n-task-runners.json

USER runner
