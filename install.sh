#!/bin/bash

# ===============================
# Codespace FileHost Installer 🌐
# ===============================

DOMAIN="host.senzdev.xyz"
UPLOAD_PIN="969696"
PORT="8080"
FILEHOST_DIR="/tmp/filehost"
DB_FILE="$FILEHOST_DIR/database/filebrowser.db"

echo "🌐 Starting Codespace FileHost Setup..."
sleep 1

# Install File Browser
echo "📥 Downloading File Browser..."
mkdir -p $FILEHOST_DIR
curl -fsSL https://github.com/filebrowser/filebrowser/releases/download/v2.32.0/linux-amd64-filebrowser.tar.gz -o $FILEHOST_DIR/filebrowser.tar.gz

echo "📂 Extracting File Browser..."
tar -xzf $FILEHOST_DIR/filebrowser.tar.gz -C $FILEHOST_DIR
chmod +x $FILEHOST_DIR/filebrowser

# Create database dir
mkdir -p $(dirname "$DB_FILE")

# Start File Browser
echo "🚀 Launching File Browser..."
nohup $FILEHOST_DIR/filebrowser -r $FILEHOST_DIR -d $DB_FILE --address 0.0.0.0 --port $PORT > $FILEHOST_DIR/log.txt 2>&1 &

# Wait a bit
sleep 3

# Create Admin User
$FILEHOST_DIR/filebrowser users add admin "$UPLOAD_PIN" --perm.admin

# Show Info
echo ""
echo "✅ FileHost Ready!"
echo "🌐 Access: https://$CODESPACE_NAME-$PORT.githubpreview.dev"
echo "🔑 Upload PIN: $UPLOAD_PIN"
echo "📂 Public download links enabled (share the file link)"
echo "📄 Logs: tail -f $FILEHOST_DIR/log.txt"
echo ""
