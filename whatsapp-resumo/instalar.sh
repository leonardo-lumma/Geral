#!/bin/bash
# Instala o envio automático às 9h15, 12h15 e 17h15.
set -e
mkdir -p "$HOME/.resumo-whatsapp" "$HOME/Library/LaunchAgents"
cp "$(dirname "$0")/enviar-resumo.sh" "$HOME/.resumo-whatsapp/enviar-resumo.sh"
chmod +x "$HOME/.resumo-whatsapp/enviar-resumo.sh"
P="$HOME/Library/LaunchAgents/com.leonardo.resumo-whatsapp.plist"
cat > "$P" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.leonardo.resumo-whatsapp</string>
  <key>ProgramArguments</key><array><string>$HOME/.resumo-whatsapp/enviar-resumo.sh</string></array>
  <key>EnvironmentVariables</key><dict><key>DESTINO</key><string>${DESTINO:-whatsapp}</string></dict>
  <key>StartCalendarInterval</key><array>
    <dict><key>Hour</key><integer>9</integer><key>Minute</key><integer>15</integer></dict>
    <dict><key>Hour</key><integer>12</integer><key>Minute</key><integer>15</integer></dict>
    <dict><key>Hour</key><integer>17</integer><key>Minute</key><integer>15</integer></dict>
  </array>
</dict></plist>
PL
launchctl unload "$P" 2>/dev/null || true
launchctl load "$P"
echo "Instalado. Log em ~/.resumo-whatsapp/log.txt"
