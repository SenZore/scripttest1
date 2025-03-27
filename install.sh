#!/bin/bash

# ===============================
# Simple FileHost Installer 🌐
# ===============================

DOMAIN="host.senzdev.xyz"
UPLOAD_PIN="969696"
PORT="8080"
FILEHOST_DIR="/tmp/filehost"
DB_FILE="$FILEHOST_DIR/database/filebrowser.db"

echo "🌐 Starting FileHost Setup..."
sleep 1

# Detect VPS Public IP
VPS_IP=$(curl -s https://api.ipify.org)

# Install File Browser
echo "📥 Downloading File Browser..."
mkdir -p $FILEHOST_DIR
curl -fsSL https://github.com/filebrowser/filebrowser/releases/download/v2.32.0/linux-amd64-filebrowser.tar.gz -o $FILEHOST_DIR/filebrowser.tar.gz

echo "📂 Extracting File Browser..."
tar -xzf $FILEHOST_DIR/filebrowser.tar.gz -C $FILEHOST_DIR
chmod +x $FILEHOST_DIR/filebrowser

# Init config
echo "⚙️ Initializing File Browser config..."
mkdir -p $(dirname "$DB_FILE")
$FILEHOST_DIR/filebrowser config init --database "$DB_FILE"
$FILEHOST_DIR/filebrowser config set --address 0.0.0.0 --port $PORT --database "$DB_FILE"

# Create Admin User
echo "👤 Creating Admin User..."
$FILEHOST_DIR/filebrowser users add admin "$UPLOAD_PIN" --perm.admin --database "$DB_FILE"

# Start File Browser
echo "🚀 Launching File Browser..."
nohup $FILEHOST_DIR/filebrowser --database "$DB_FILE" > $FILEHOST_DIR/log.txt 2>&1 &

sleep 2

# Info
echo ""
echo "✅ FileHost Ready!"
echo "🌐 Access: http://$VPS_IP:$PORT"
echo "🔑 Upload PIN: $UPLOAD_PIN"
echo "📂 Public download links enabled (upload needs PIN)"
echo "📄 Logs: tail -f $FILEHOST_DIR/log.txt"
echo ""
