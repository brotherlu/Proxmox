#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 brotherlu
# Author: brotherlu
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"

   ____                 _       __     __    __  ______
  / __ \____  ___  ____| |     / /__  / /_  / / / /  _/
 / / / / __ \/ _ \/ __ \ | /| / / _ \/ __ \/ / / // /  
/ /_/ / /_/ /  __/ / / / |/ |/ /  __/ /_/ / /_/ // /   
\____/ .___/\___/_/ /_/|__/|__/\___/_.___/\____/___/   
    /_/                                                

EOF
}
header_info
echo -e "Loading..."
APP="OpenWebUI"
var_disk="3"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -d /opt/open-webui ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Stopping ${APP}"
systemctl stop open-webui
msg_ok "Stopped ${APP}"

msg_info "Updating ${APP}"
rm -rf /opt/open-webui/*
TAR_URL=$(curl -sL https://api.github.com/repos/open-webui/open-webui/releases/latest | grep -o 'http.*tarball[^"]*')
wget -qO- $TAR_URL | tar xz --strip-components=1 --directory /opt/open-webui/
msg_ok "Updated ${APP}"

msg_info "Updating NodeJS"
wget -qO- https://nodejs.org/dist/v20.15.0/node-v20.15.0-linux-x64.tar.xz
tar -xvf node-v20.15.0-linux-x64.tar.xz --strip-components=1 --directory /usr/local/
msg_ok "Updated NodeJS"

msg_info "Installing Dependacies"
cd /opt/open-webui
npm i
npm run build
cd /opt/open-webui/backend
pip install -r requirements.txt -U
msg_ok "Installed Dependacies"

msg_info "Starting ${APP}"
cd /opt/open-webui/backend
bash start.sh
msg_ok "Started ${APP}"
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8080${CL} \n"
