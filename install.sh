#!/bin/bash

# ============================
#  Simple FileHost (Codespace)
# ============================

DOMAIN="host.senzdev.xyz"
UPLOAD_PIN="969696"
PORT=8080

echo "🌐 Starting Codespace FileHost Setup..."
sleep 1

# === Install Dependencies ===
echo "📥 Installing FileBrowser..."
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# === Setup Directories ===
mkdir -p /tmp/filehost
mkdir -p /tmp/filehost/database
mkdir -p /tmp/filehost/settings

# === Run FileBrowser ===
echo "🚀 Launching FileBrowser on port $PORT"
nohup ./filebrowser -r /tmp/filehost -d /tmp/filehost/database/filebrowser.db > /tmp/filehost/log.txt 2>&1 &

sleep 3

# === Create Admin User (PIN Based) ===
./filebrowser users add admin "$UPLOAD_PIN" --perm.admin

# === Print Info ===
echo ""
echo "✅ FileHost Ready!"
echo "🌐 Access: https://$CODESPACE_NAME.github.dev:$PORT"
echo "🔑 Upload PIN: $UPLOAD_PIN"
echo "📄 Public download links enabled (just share the file link)"
echo ""
echo "📝 Logs: tail -f /tmp/filehost/log.txt"
echo ""
