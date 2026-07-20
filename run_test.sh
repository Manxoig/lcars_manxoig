#!/bin/bash

# Script de prueba aislado para LCARS Eww
# Permite probar el widget sin modificar tu configuración de ~/.config/eww ni ~/.cache/eww

# Salir inmediatamente si falla algún comando
set -e

# Ubicación del proyecto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EWW_DIR="$PROJECT_DIR/eww"

# Verificar que los scripts tengan permisos de ejecución
chmod +x "$EWW_DIR/scripts/stardate.py" "$EWW_DIR/scripts/volume_control.sh" "$EWW_DIR/scripts/sensors.py" "$EWW_DIR/scripts/computer_command.sh" "$EWW_DIR/scripts/open_terminal.sh" "$EWW_DIR/scripts/open_help.sh" "$PROJECT_DIR/troubleshoot.sh"

# Crear directorio temporal
TEMP_DIR=$(mktemp -d -t lcars-eww-test.XXXXXX)

# Función de limpieza al salir
cleanup() {
    echo -e "\n\n🧹 Limpiando el entorno de pruebas..."
    # Detener el demonio de eww aislado
    if command -v eww >/dev/null 2>&1; then
        echo "⏹️ Deteniendo eww daemon..."
        XDG_CONFIG_HOME="$TEMP_DIR/config" XDG_CACHE_HOME="$TEMP_DIR/cache" eww kill || true
    fi
    # Eliminar directorio temporal
    rm -rf "$TEMP_DIR"
    echo "✨ Sistema limpio."
}

# Registrar la limpieza para señales de salida e interrupción
trap cleanup EXIT INT TERM

# Configurar estructura del entorno aislado
echo "⚙️ Configurando entorno aislado de pruebas..."
mkdir -p "$TEMP_DIR/config"
mkdir -p "$TEMP_DIR/cache"

# Enlazar la configuración del proyecto
ln -s "$EWW_DIR" "$TEMP_DIR/config/eww"

# Exportar variables de entorno para aislar eww
export XDG_CONFIG_HOME="$TEMP_DIR/config"
export XDG_CACHE_HOME="$TEMP_DIR/cache"

echo "🚀 Iniciando eww daemon aislado..."
if ! command -v eww >/dev/null 2>&1; then
    echo "❌ Error: 'eww' no está instalado en el sistema."
    echo "Por favor instala eww-wayland o eww-x11 primero."
    exit 1
fi

echo "🖖 Abriendo widget lcars-bg..."
eww open lcars-bg

echo "--------------------------------------------------------"
echo "✅ Entorno de pruebas LCARS activo de forma aislada."
echo "Puedes interactuar con el widget en tu pantalla."
echo "Logs de eww disponibles en: $TEMP_DIR/cache/"
echo "--------------------------------------------------------"
echo "Presiona [ENTER] o Ctrl+C para finalizar la prueba y limpiar todo."
read -r
