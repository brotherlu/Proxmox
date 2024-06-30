#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Downloading OpenWebUI"
mkdir -p /opt/open-webui
TAR_URL=$(curl -sL https://api.github.com/repos/open-webui/open-webui/releases/latest | grep -o 'http.*tarball[^"]*')
wget -qO- $TAR_URL | tar xz --strip-components=1 --directory /opt/open-webui/
msg_ok "Download Complete"

msg_info "Setting up Node.js Repository"
wget -qO- https://nodejs.org/dist/v20.15.0/node-v20.15.0-linux-x64.tar.xz
tar -xvf node-v20.15.0-linux-x64.tar.xz --strip-components=1 --directory /usr/local/
msg_ok "Set up Node.js Repository"

msg_info "Installing Dependacies"
cd /opt/open-webui
npm i
npm run build
cd /opt/open-webui/backend
pip install -r requirements.txt -U
msg_ok "Installed Dependacies"

msg_info "Creating Service"
service_path="/etc/systemd/system/open-webui.service"

echo "[Unit]
Description=OpenWebUI
After=network.target

[Service]
Type=simple
ExecStart=bash /opt/open-webui/backend/start.sh
Restart=always
User=root
Environment=NODE_ENV=production
WorkingDirectory=/opt/open-webui/backend

[Install]
WantedBy=multi-user.target" >$service_path
$STD systemctl enable --now open-webui
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
