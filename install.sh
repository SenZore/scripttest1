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

# Detect Codespace domain
if [ -z "$CODESPACE_NAME" ]; then
  echo "❌ Not running inside Codespace!"
  exit 1
fi
CODESPACE_DOMAIN="https://$CODESPACE_NAME-$PORT.githubpreview.dev"

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

# Auto-start (optional)
START_CMD="bash <(curl -s https://raw.githubusercontent.com/SenZore/scripttest1/main/install.sh)"
grep -qxF "$START_CMD" ~/.bashrc || echo "$START_CMD" >> ~/.bashrc

# Info
echo ""
echo "✅ FileHost Ready!"
echo "🌐 Access: $CODESPACE_DOMAIN"
echo "🔑 Upload PIN: $UPLOAD_PIN"
echo "📂 Public download links enabled (upload needs PIN)"
echo "📄 Logs: tail -f $FILEHOST_DIR/log.txt"
echo ""
