#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Moras pokrenuti kao root!"
  exit 1
fi

sudo apt update -y && sudo apt upgrade -y

SAMP_USER="samp"
WORKDIR="/home/$SAMP_USER"
ARCHIVE_URL="https://raw.githubusercontent.com/hake-lua/default_sampsvr/refs/heads/main/samp03.tar.gz"
PORT="7777"

dpkg --add-architecture i386
apt install -y libc6:i386 libncurses6:i386 libstdc++6:i386 lib32z1 \
                lib32stdc++6 lib32gcc-s1 screen wget tar unzip ca-certificates curl

if ! id "$SAMP_USER" &>/dev/null; then
  useradd -m -s /bin/bash "$SAMP_USER"
fi

cd "$WORKDIR"

rm -rf "$WORKDIR/samp03"
rm -f samp03.tar.gz

su - "$SAMP_USER" -c "wget -O samp03.tar.gz $ARCHIVE_URL"
su - "$SAMP_USER" -c "tar -xzf samp03.tar.gz"

chmod +x "$WORKDIR/samp03/samp03svr"
chown -R "$SAMP_USER":"$SAMP_USER" "$WORKDIR/samp03"

cat > /etc/systemd/system/samp.service <<EOF
[Unit]
Description=SA-MP Server
After=network.target

[Service]
Type=simple
User=$SAMP_USER
WorkingDirectory=$WORKDIR/samp03
ExecStart=$WORKDIR/samp03/samp03svr
Restart=always
RestartSec=5
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable samp

if command -v ufw &>/dev/null; then
  ufw allow ${PORT}/udp || true
  ufw allow ${PORT}/tcp || true
fi

if command -v iptables &>/dev/null; then
  iptables -I INPUT -p udp --dport ${PORT} -j ACCEPT || true
  iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT || true
fi

systemctl restart samp
sleep 2

PUBLIC_IP=$(curl -s https://api.ipify.org || wget -qO- https://api.ipify.org)

if systemctl is-active --quiet samp; then
    echo -e "\n=================================================="
    echo -e "  INSTALACIJA USPJESNO ZAVRSENA"
    echo -e "=================================================="
    echo -e " IP Adresa: $PUBLIC_IP:$PORT"
    echo -e " Lokacija fajlova: $WORKDIR/samp03"
    echo -e " Konfiguracija: $WORKDIR/samp03/server.cfg"
    echo -e "=================================================="
    echo -e "\n--- UPRAVLJANJE SERVEROM ---"
    echo -e " Restartuj server:  sudo systemctl restart samp"
    echo -e " Ugasi server:      sudo systemctl stop samp"
    echo -e " Upali server:      sudo systemctl start samp"
    echo -e "==================================================\n"
else
    echo -e "\n[ERROR] Server nije uspio startati.\n"
fi

