FROM docker.n8n.io/n8nio/n8n:latest

# Install yamljs package globally so it's available to n8n Code nodes
# n8n Code nodes can access globally installed npm packages via require()
USER root
RUN npm install -g yamljs
USER node
