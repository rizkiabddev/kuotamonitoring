#!/bin/bash

SERVICE_NAME=kuota-monitoring
SERVICE_FILE=/usr/lib/systemd/system/$SERVICE_NAME.service
INSTALL_DIR=/opt/kuotamonitoring
BINARY_URL="https://github.com/rizkiabddev/kuotamonitoring/raw/refs/heads/main/kuota_monitoring" 
BINARY_NAME=kuota_monitoring

# Cek argumen
if [ -z "$1" ]; then
  echo "❌ Error: Harap isi basepath statistik modem sebagai argumen."
  echo "Contoh: ./install_service.sh /sys/class/net/wwp0s20f0u2i4/statistics/"
  exit 1
fi

INTERFACE_PATH="$1"

echo "🚀 Membuat direktori instalasi..."
sudo mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

echo "⬇️  Mengunduh binary dari $BINARY_URL..."
sudo curl -L -o $BINARY_NAME $BINARY_URL
sudo chmod +x $BINARY_NAME

echo "📝 Membuat systemd service..."
cat <<EOF | sudo tee $SERVICE_FILE > /dev/null
[Unit]
Description=Monitoring Kuota

[Service]
Type=simple
Restart=always
RestartSec=5s
ExecStart=$INSTALL_DIR/$BINARY_NAME --basepath $INTERFACE_PATH
WorkingDirectory=$INSTALL_DIR

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reload systemd daemon dan enable + start service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "✅ Service '$SERVICE_NAME' sudah aktif!"
sudo systemctl status $SERVICE_NAME --no-pager
