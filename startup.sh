#! /bin/bash
set -e

# VARIABLES (edit if you want)
REPO_URL="https://github.com/NaveenRayapati/Test-mig.git"
BRANCH="main"
APP_DIR="/opt/app"
INSTANCE_ID="$(curl -H 'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/id || echo unknown)"
PORT=8080

# update & install prerequisites
apt-get update -y
apt-get install -y curl git

# Install Node.js (LTS) and npm
# using NodeSource (works on Debian/Ubuntu)
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# create app directory
mkdir -p ${APP_DIR}
chown -R $(whoami) ${APP_DIR}

# clone or pull code (idempotent)
if [ -d "${APP_DIR}/.git" ]; then
  cd ${APP_DIR}
  git fetch --all
  git reset --hard origin/${BRANCH}
else
  rm -rf ${APP_DIR}/*
  git clone --branch ${BRANCH} ${REPO_URL} ${APP_DIR}
fi

cd ${APP_DIR}
npm install --production || true

# create a systemd service to run the app
SERVICE_NAME="simple-node-app.service"
cat >/etc/systemd/system/${SERVICE_NAME} <<EOF
[Unit]
Description=Simple Node App
After=network.target

[Service]
Type=simple
User=root
Environment=PORT=${PORT}
Environment=INSTANCE_ID=${INSTANCE_ID}
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/node ${APP_DIR}/index.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ${SERVICE_NAME}
systemctl restart ${SERVICE_NAME}

# Ensure firewall (if necessary) and health-check listen port is open:
# On Google-managed images default firewall for external LB will be allowed via LB.
echo "Startup script finished on $(date)."
