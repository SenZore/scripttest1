#!/bin/bash

# =============== Simple FileHost Auto Installer =============== #
# Author  : SenzDev
# Domain  : host.senzdev.xyz
# Upload PIN : 969696
# ============================================================= #

set -e

echo ""
echo "🔐 Starting Simple File Host Setup..."
sleep 1

# Auto-detect public IP
PUBLIC_IP=$(curl -s ifconfig.me)

echo "🌐 Detected Public IP: $PUBLIC_IP"
echo ""

# Install Docker & Docker Compose
echo "📥 Installing Docker & Docker Compose..."
apt update -y
apt install -y docker.io docker-compose curl ufw

# Enable Docker
systemctl enable --now docker

# Setup Firewall (Optional but recommended)
ufw allow 80,443/tcp
ufw allow OpenSSH
ufw --force enable

# Create directories
mkdir -p /opt/filehost
cd /opt/filehost

# Create Docker Compose
cat > docker-compose.yml <<EOF
version: '3'

services:
  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser
    ports:
      - "8080:80"
    volumes:
      - /opt/filehost/data:/srv
    environment:
      - FB_AUTH_METHOD=basic
    restart: unless-stopped
EOF

# Start container
echo "🚀 Starting FileBrowser..."
docker-compose up -d

# Wait for FileBrowser to boot
sleep 5

# Set admin PIN
docker exec filebrowser filebrowser users add admin "" --perm.admin
docker exec filebrowser filebrowser config set --auth.method=json --auth.json='{"pin":"969696"}'

# Install Caddy for HTTPS reverse proxy
echo "🔒 Installing Caddy Server (Auto SSL)..."
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install -y caddy

# Configure Caddy
cat > /etc/caddy/Caddyfile <<EOF
host.senzdev.xyz {
    reverse_proxy 127.0.0.1:8080
}
EOF

# Restart Caddy
systemctl restart caddy
systemctl enable caddy

echo ""
echo "✅ Installation Complete!"
echo "🌐 Access: https://host.senzdev.xyz"
echo "🔑 Upload PIN: 969696"
echo "📂 Uploaded files will have public download links"
echo ""

