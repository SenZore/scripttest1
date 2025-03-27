#!/bin/bash

# ===============================
# 🌐 Simple FileHost Installer
# ===============================

DOMAIN="host.senzdev.xyz"
UPLOAD_PIN="969696"
PORT="8080"
FILEHOST_DIR="/tmp/filehost"
DB_FILE="$FILEHOST_DIR/database/filebrowser.db"
LOG_FILE="$FILEHOST_DIR/log.txt"

echo "🚀 Starting FileHost Setup..."
sleep 1

# Detect VPS IP
VPS_IP=$(curl -s https://api.ipify.org)
echo "📡 Detected VPS IP: $VPS_IP"

# Install File Browser
echo "📥 Downloading File Browser..."
mkdir -p "$FILEHOST_DIR"
curl -fsSL https://github.com/filebrowser/filebrowser/releases/download/v2.32.0/linux-amd64-filebrowser.tar.gz -o "$FILEHOST_DIR/filebrowser.tar.gz"

echo "📂 Extracting File Browser..."
tar -xzf "$FILEHOST_DIR/filebrowser.tar.gz" -C "$FILEHOST_DIR"
chmod +x "$FILEHOST_DIR/filebrowser"

# Create database dir
mkdir -p "$(dirname "$DB_FILE")"

# Write .env
echo "PIN=$UPLOAD_PIN" > "$FILEHOST_DIR/.env"

# Launch FileBrowser
echo "🚀 Launching File Browser..."
nohup "$FILEHOST_DIR/filebrowser" -r "$FILEHOST_DIR" -d "$DB_FILE" --address 0.0.0.0 --port "$PORT" > "$LOG_FILE" 2>&1 &

sleep 3

# Add admin user
"$FILEHOST_DIR/filebrowser" users add admin "$UPLOAD_PIN" --perm.admin

# Show info
echo ""
echo "✅ FileHost Ready!"
echo "🌐 Access: http://$VPS_IP:$PORT or http://$DOMAIN:$PORT"
echo "🔑 Upload PIN: $UPLOAD_PIN"
echo "📥 Public download links enabled"
echo "📄 Logs: tail -f $LOG_FILE"
echo ""
echo "⚠️  Don't forget to point your A Record:"
echo "    $DOMAIN --> $VPS_IP"
echo ""
