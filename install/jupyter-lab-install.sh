#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (Modified for JupyterLab)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/

source /dev/stdin <<< "$FUNCTIONS_ASSET"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y python3-pip
$STD apt-get install -y python3-dev
$STD apt-get install -y build-essential
$STD apt-get install -y libffi-dev
$STD apt-get install -y libssl-dev
msg_ok "Installed Dependencies"

msg_info "Installing JupyterLab"
# Instalamos jupyterlab en lugar de jupyter notebook
$STD pip install jupyterlab
msg_ok "Installed JupyterLab"

msg_info "Creating Service"
# Configuramos el servicio para que use jupyter-lab
cat <<EOF >/etc/systemd/system/jupyter.service
[Unit]
Description=JupyterLab
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/jupyter-lab --ip=0.0.0.0 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password=''
User=root
Group=root
WorkingDirectory=/root
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

$STD systemctl enable --now jupyter.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove -y
$STD apt-get autoclean -y
msg_ok "Cleaned"
