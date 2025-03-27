#!/bin/bash

# ===============================
#   Simple FileHost Installer
#       by SenZore
# ===============================

# === CONFIG ===
DOMAIN="host.senzdev.xyz"
UPLOAD_PIN="969696"

echo ""
echo "📂 Starting FileHost Auto Installer for $DOMAIN ..."
sleep 1

# === Auto Detect Public IP ===
IP=$(curl -s ifconfig.me)
echo "🌐 Detected VPS IP: $IP"

# === Update & Install Dependencies ===
echo "📥 Installing Docker, Docker Compose & Caddy..."
apt update -y
apt install -y docker.io docker-compose curl ufw caddy

# === Enable & Start Docker ===
systemctl enable --now docker

# === Firewall Rules (Optional but safe) ===
ufw allow 80,443/tcp
ufw allow OpenSSH
ufw --force enable

# === Create directories ===
mkdir -p /opt/filehost/data
cd /opt/filehost

# === Docker Compose File ===
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
    restart: unless-stopped
EOF

# === Start FileBrowser ===
echo "🚀 Launching FileBrowser..."
docker-compose up -d
sleep 5

# === Set Admin PIN ===
docker exec filebrowser filebrowser users add admin "" --perm.admin || true
docker exec filebrowser filebrowser config set --auth.method=json --auth.json="{\"pin\":\"${UPLOAD_PIN}\"}"

# === Configure Caddy Reverse Proxy ===
echo "🔐 Setting up Caddy Reverse Proxy..."
cat > /etc/caddy/Caddyfile <<EOF
$DOMAIN {
    reverse_proxy 127.0.0.1:8080
}
EOF

systemctl restart caddy
systemctl enable caddy

# === Finished ===
echo ""
echo "✅ Installation Finished!"
echo "🌐 Access: https://$DOMAIN"
echo "🔑 Upload PIN: $UPLOAD_PIN"
echo "📄 Public download links enabled"
echo "🚀 VPS IP: $IP"
echo ""
echo "⚠️ Don't forget to point your A Record:"
echo "    $DOMAIN --> $IP"
echo ""

exit 0
