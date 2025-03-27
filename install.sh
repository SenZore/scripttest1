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

# Create database dir
mkdir -p $(dirname "$DB_FILE")

# Create .env config
cat > $FILEHOST_DIR/.env <<EOF
PIN=$UPLOAD_PIN
EOF

# Start File Browser
echo "🚀 Launching File Browser..."
nohup $FILEHOST_DIR/filebrowser -r $FILEHOST_DIR -d $DB_FILE --address 0.0.0.0 --port $PORT > $FILEHOST_DIR/log.txt 2>&1 &

sleep 3

# Create Admin User
$FILEHOST_DIR/filebrowser users add admin "$UPLOAD_PIN" --perm.admin

# Info
echo ""
echo "✅ FileHost Ready!"
echo "🌐 Access: http://$VPS_IP:$PORT"
echo "🔑 Upload PIN: $UPLOAD_PIN"
echo "📂 Public download links enabled (upload needs PIN)"
echo "📄 Logs: tail -f $FILEHOST_DIR/log.txt"
echo ""
