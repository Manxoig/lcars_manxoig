#!/bin/bash

EWW_CONFIG_DIR="$HOME/.config/eww"
PROJECT_EWW_DIR="$(pwd)/eww"

echo "🖖 Configurando el entorno LCARS..."

# Asegurarse de que los scripts sean ejecutables
chmod +x eww/scripts/stardate.py eww/scripts/volume_control.sh eww/scripts/open_help.sh troubleshoot.sh

# Enlazar la configuración de eww
if [ -d "$EWW_CONFIG_DIR" ] || [ -L "$EWW_CONFIG_DIR" ]; then
    echo "⚠️ Se detectó una configuración existente de Eww en $EWW_CONFIG_DIR."
    echo "Respalda tu configuración anterior y crea un enlace simbólico si deseas usar este widget por defecto,"
    echo "o ejecuta eww indicando la ruta directa de la carpeta de este proyecto:"
    echo "   eww --config $PROJECT_EWW_DIR open lcars-bg"
else
    mkdir -p "$(dirname "$EWW_CONFIG_DIR")"
    ln -sf "$PROJECT_EWW_DIR" "$EWW_CONFIG_DIR"
    echo "🔗 Enlace simbólico creado con éxito en $EWW_CONFIG_DIR"
fi

echo "✅ Listo. Puedes iniciar el widget ejecutando:"
echo "   eww --config $PROJECT_EWW_DIR open lcars-bg"
