#! /bin/bash
set -e

# VARIABLES
REPO_URL="https://github.com/NaveenRayapati/Test-mig.git"
BRANCH="main"
APP_DIR="/opt/app"
# Get Instance ID from metadata for unique identification in the app
INSTANCE_ID="$(curl -H 'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/id || echo unknown)"
PORT=8080

# 1. Update & Install prerequisites
apt-get update -y
apt-get install -y curl git
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# 2. Clone or pull code (idempotent setup)
if [ -d "${APP_DIR}/.git" ]; then
  cd ${APP_DIR}
  git fetch --all
  git reset --hard origin/${BRANCH}
else
  # Ensure clean clone if directory exists but is not a git repo
  rm -rf ${APP_DIR}
  git clone --branch ${BRANCH} ${REPO_URL} ${APP_DIR}
fi

# 3. Install NPM dependencies
cd ${APP_DIR}
npm install --production || true

# 4. Create and start a systemd service (your app starts on boot)
SERVICE_NAME="simple-node-app.service"
cat >/etc/systemd/system/${SERVICE_NAME} <<EOF
[Unit]
Description=Simple Node App
After=network.target

[Service]
Type=simple
User=root
# Pass environment variables to the app
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

echo "Startup script finished on $(date)."
