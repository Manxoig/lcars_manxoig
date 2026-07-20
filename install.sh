#!/bin/bash

EWW_CONFIG_DIR="$HOME/.config/eww"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_EWW_DIR="$PROJECT_DIR/eww"
AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/lcars-eww.desktop"

echo "🖖 Configurando el entorno LCARS..."

# Asegurarse de que los scripts sean ejecutables
chmod +x "$PROJECT_EWW_DIR/scripts/stardate.py" "$PROJECT_EWW_DIR/scripts/volume_control.sh" "$PROJECT_EWW_DIR/scripts/sensors.py" "$PROJECT_EWW_DIR/scripts/computer_command.sh" "$PROJECT_EWW_DIR/scripts/open_terminal.sh" "$PROJECT_EWW_DIR/scripts/open_help.sh" "$PROJECT_DIR/troubleshoot.sh" 2>/dev/null || true

# Enlazar la configuración de eww
if [ -d "$EWW_CONFIG_DIR" ] || [ -L "$EWW_CONFIG_DIR" ]; then
    echo "ℹ️ Enlazando configuración en $EWW_CONFIG_DIR..."
    ln -sfn "$PROJECT_EWW_DIR" "$EWW_CONFIG_DIR"
else
    mkdir -p "$(dirname "$EWW_CONFIG_DIR")"
    ln -sf "$PROJECT_EWW_DIR" "$EWW_CONFIG_DIR"
    echo "🔗 Enlace simbólico creado en $EWW_CONFIG_DIR"
fi

# Configurar inicio automático (Autostart)
mkdir -p "$AUTOSTART_DIR"
cat <<EOF > "$AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Name=LCARS Eww Widget
Comment=Autostart LCARS Eww Widget on login
Exec=bash -c "sleep 3 && eww --config $PROJECT_EWW_DIR daemon && sleep 1 && eww --config $PROJECT_EWW_DIR open lcars-bg"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel
EOF
chmod +x "$AUTOSTART_FILE"

echo "🚀 Inicio automático configurado en: $AUTOSTART_FILE"
echo "✅ Listo. El widget se iniciará automáticamente en el próximo reinicio o inicio de sesión."
