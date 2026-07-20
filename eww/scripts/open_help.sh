#!/bin/bash

# Script lanzador de ayuda y diagnóstico para LCARS Eww
# Encuentra la ubicación real del script troubleshoot.sh resolviendo enlaces simbólicos

SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
# El proyecto es el padre de eww/scripts/ (2 niveles arriba)
PROJECT_DIR=$(dirname "$(dirname "$SCRIPT_DIR")")
TROUBLESHOOT_SCRIPT="$PROJECT_DIR/troubleshoot.sh"
HELP_DOC="$SCRIPT_DIR/../SOPORTE_ERRORES.md"

# Función para abrir la terminal con el script de diagnóstico
open_terminal_run() {
    local term=$1
    case "$term" in
        konsole)
            konsole --hold -e "$TROUBLESHOOT_SCRIPT" &
            return 0
            ;;
        gnome-terminal)
            gnome-terminal -- bash -c "$TROUBLESHOOT_SCRIPT" &
            return 0
            ;;
        kitty)
            kitty --hold sh -c "$TROUBLESHOOT_SCRIPT" &
            return 0
            ;;
        alacritty)
            alacritty --hold -e "$TROUBLESHOOT_SCRIPT" &
            return 0
            ;;
        xfce4-terminal)
            xfce4-terminal --hold -e "$TROUBLESHOOT_SCRIPT" &
            return 0
            ;;
        xterm)
            xterm -hold -e "$TROUBLESHOOT_SCRIPT" &
            return 0
            ;;
    esac
    return 1
}

# Lista de emuladores de terminal por orden de preferencia
terminals=("konsole" "gnome-terminal" "kitty" "alacritty" "xfce4-terminal" "xterm")

# Buscar y ejecutar el primer emulador de terminal que encontremos
terminal_found=false
for term in "${terminals[@]}"; do
    if command -v "$term" >/dev/null 2>&1; then
        if open_terminal_run "$term"; then
            terminal_found=true
            break
        fi
    fi
done

# Si no encontramos ningún emulador de terminal, abrimos directamente el archivo Markdown
if [ "$terminal_found" = false ]; then
    if command -v xdg-open >/dev/null 2>&1 && [ -f "$HELP_DOC" ]; then
        xdg-open "$HELP_DOC" &
    else
        # Si todo lo demás falla, intentar con cat/less en terminal pasivo o imprimir al log
        echo "No se pudo abrir el diagnosticador ni la guía de soporte." >&2
        exit 1
    fi
fi
