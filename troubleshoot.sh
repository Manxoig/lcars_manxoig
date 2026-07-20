#!/bin/bash

# ==============================================================================
# 🖖 LCARS DIAGNOSTIC SYSTEM & TROUBLESHOOTER
# ==============================================================================

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Determinar el directorio del proyecto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EWW_DIR="$PROJECT_DIR/eww"

clear
echo -e "${PURPLE}==============================================================================${NC}"
echo -e "${YELLOW}${BOLD}🖖 SISTEMA DE DIAGNÓSTICO Y ANÁLISIS DE ERRORES - LCARS DESKTOP OVERLAY${NC}"
echo -e "${PURPLE}==============================================================================${NC}"
echo -e "Analizando el entorno de ejecución del sistema..."
echo ""

errors=0
warnings=0

# ------------------------------------------------------------------------------
# 1. COMPROBAR EWW
# ------------------------------------------------------------------------------
echo -e "${BOLD}[1/7] Comprobando entorno de Eww...${NC}"
if command -v eww >/dev/null 2>&1; then
    eww_path=$(command -v eww)
    echo -e "  ${GREEN}✔${NC} Eww está instalado en: ${BLUE}$eww_path${NC}"
    # Intentar obtener versión
    eww_ver=$(eww --version 2>/dev/null | head -n1 || echo "Desconocida")
    echo -e "    Versión de Eww: $eww_ver"
else
    echo -e "  ${RED}✘ ERROR:${NC} 'eww' no está instalado en el sistema."
    echo -e "    ${YELLOW}Solución:${NC} Instala eww-wayland o eww-x11 usando el gestor de paquetes de tu distro."
    ((errors++))
fi
echo ""

# ------------------------------------------------------------------------------
# 2. COMPROBAR PYTHON 3 (Para Stardate)
# ------------------------------------------------------------------------------
echo -e "${BOLD}[2/7] Comprobando Python (para Stardate)...${NC}"
if command -v python3 >/dev/null 2>&1; then
    py_ver=$(python3 --version)
    echo -e "  ${GREEN}✔${NC} Python 3 está instalado: ${BLUE}$py_ver${NC}"
else
    echo -e "  ${RED}✘ ERROR:${NC} Python 3 no está instalado."
    echo -e "    ${YELLOW}Solución:${NC} Instala python3 para que funcione el cálculo del Stardate."
    ((errors++))
fi
echo ""

# ------------------------------------------------------------------------------
# 3. COMPROBAR CONTROLADORES DE AUDIO
# ------------------------------------------------------------------------------
echo -e "${BOLD}[3/7] Comprobando controladores de volumen...${NC}"
has_vol=0
if command -v pamixer >/dev/null 2>&1; then
    echo -e "  ${GREEN}✔${NC} pamixer detectado: ${BLUE}$(command -v pamixer)${NC}"
    has_vol=1
fi
if command -v pactl >/dev/null 2>&1; then
    echo -e "  ${GREEN}✔${NC} pactl detectado: ${BLUE}$(command -v pactl)${NC}"
    has_vol=1
fi

if [ $has_vol -eq 0 ]; then
    echo -e "  ${RED}✘ ERROR:${NC} No se detectó ni 'pamixer' ni 'pactl'."
    echo -e "    ${YELLOW}Solución:${NC} Instala 'pamixer' (recomendado) o 'pulseaudio-utils' (para pactl) para usar el control de volumen."
    ((errors++))
else
    echo -e "  ${GREEN}✔${NC} Soporte de audio disponible para control de volumen."
fi
echo ""

# ------------------------------------------------------------------------------
# 4. COMPROBAR PERMISOS DE SCRIPTS
# ------------------------------------------------------------------------------
echo -e "${BOLD}[4/7] Comprobando permisos de los scripts auxiliares...${NC}"
scripts=(
    "$EWW_DIR/scripts/stardate.py"
    "$EWW_DIR/scripts/volume_control.sh"
)

for script in "${scripts[@]}"; do
    filename=$(basename "$script")
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "  ${GREEN}✔${NC} $filename tiene permisos de ejecución correctos."
        else
            echo -e "  ${YELLOW}⚠ ADVERTENCIA:${NC} $filename no es ejecutable."
            echo -e "    Intentando corregir permisos automáticamente..."
            chmod +x "$script" 2>/dev/null
            if [ -x "$script" ]; then
                echo -e "    ${GREEN}✔ Permisos corregidos con éxito.${NC}"
            else
                echo -e "    ${RED}✘ No se pudieron corregir los permisos.${NC}"
                echo -e "      Ejecuta manualmente: chmod +x $script"
                ((errors++))
            fi
        fi
    else
        echo -e "  ${RED}✘ ERROR:${NC} No se encuentra el script crítico: $script"
        ((errors++))
    fi
done
echo ""

# ------------------------------------------------------------------------------
# 5. DETECTAR ENTORNO DE ESCRITORIO
# ------------------------------------------------------------------------------
echo -e "${BOLD}[5/7] Comprobando compatibilidad de entorno de escritorio...${NC}"
desktop="${XDG_CURRENT_DESKTOP:-Desconocido}"
echo -e "  Entorno actual detectado: ${BLUE}$desktop${NC}"
if [[ "$desktop" =~ KDE|plasma|Plasma ]]; then
    echo -e "  ${GREEN}✔${NC} Compatible al 100% con los botones predeterminados de KDE (Monitor del Sistema, KRunner, Configuración)."
else
    echo -e "  ${YELLOW}⚠ ADVERTENCIA:${NC} Tu entorno no es KDE Plasma. Los botones predeterminados de acción rápida"
    echo -e "    (SYS MONITOR, RUN APPS, SYS CONFIG) podrían no responder."
    echo -e "    ${YELLOW}Solución:${NC} Edita eww.yuck para vincular comandos acordes a tu entorno (ej. gnome-system-monitor)."
    ((warnings++))
fi
echo ""

# ------------------------------------------------------------------------------
# 6. COMPROBAR CONFLICTOS DE PROCESOS EWW
# ------------------------------------------------------------------------------
echo -e "${BOLD}[6/7] Comprobando demonios de Eww activos...${NC}"
active_eww_pids=$(pgrep eww || true)
if [ -n "$active_eww_pids" ]; then
    echo -e "  ${YELLOW}⚠ ADVERTENCIA:${NC} Hay procesos de Eww ejecutándose en segundo plano (PIDs: $active_eww_pids)."
    echo -e "    Si inicias el widget sin aislamiento, podría colisionar con la configuración activa."
    echo -e "    ${YELLOW}Solución:${NC} Ejecuta './run_test.sh' para probar de forma aislada, o detén los procesos con 'eww kill'."
    ((warnings++))
else
    echo -e "  ${GREEN}✔${NC} No hay demonios de Eww conflictivos activos."
fi
echo ""

# ------------------------------------------------------------------------------
# 7. COMPROBAR FUENTES TIPOGRÁFICAS
# ------------------------------------------------------------------------------
echo -e "${BOLD}[7/7] Comprobando tipografías LCARS...${NC}"
if command -v fc-list >/dev/null 2>&1; then
    # Buscar ocurrencias de Swiss, Antonio o Hansen
    lcars_fonts=$(fc-list : family | grep -E -i "Swiss 911|Hansen|Antonio|Arial Narrow" | sort -u | head -n 5 || true)
    if [ -n "$lcars_fonts" ]; then
        echo -e "  ${GREEN}✔${NC} Se detectaron fuentes compatibles en el sistema:"
        echo "$lcars_fonts" | sed 's/^/    - /'
    else
        echo -e "  ${YELLOW}⚠ ADVERTENCIA:${NC} No se detectaron las tipografías oficiales de LCARS (Swiss 911 / Hansen)."
        echo -e "    Se usará Arial Narrow o sans-serif por defecto, perdiendo la estética de Star Trek."
        echo -e "    ${YELLOW}Solución:${NC} Descarga e instala 'Swiss 911 Ultra Compressed' en ~/.local/share/fonts/"
        ((warnings++))
    fi
else
    echo -e "  ${YELLOW}⚠ ADVERTENCIA:${NC} No se pudo verificar la lista de fuentes ('fc-list' no disponible)."
    ((warnings++))
fi
echo ""

# ------------------------------------------------------------------------------
# RESUMEN GENERAL
# ------------------------------------------------------------------------------
echo -e "${PURPLE}==============================================================================${NC}"
echo -e "${BOLD}RESUMEN DE DIAGNÓSTICO:${NC}"
echo -e "  Errores críticos: ${RED}$errors${NC}"
echo -e "  Advertencias:     ${YELLOW}$warnings${NC}"
echo -e "${PURPLE}==============================================================================${NC}"

if [ $errors -eq 0 ]; then
    if [ $warnings -eq 0 ]; then
        echo -e "${GREEN}${BOLD}¡Todo correcto! Tu entorno está perfectamente preparado para ejecutar LCARS Eww. 🖖${NC}"
    else
        echo -e "${YELLOW}${BOLD}El entorno está listo, pero revisa las advertencias anteriores para optimizar la experiencia. 🖖${NC}"
    fi
else
    echo -e "${RED}${BOLD}Se detectaron fallos críticos. Resuelve los errores indicados arriba para asegurar que el widget funcione.${NC}"
fi
echo ""

# Ofrecer leer la guía de soporte
echo -e "¿Deseas abrir la guía completa de soporte escrita (SOPORTE_ERRORES.md)? [s/N]"
read -r respuesta
if [[ "$respuesta" =~ ^[sS]$ || "$respuesta" == "si" || "$respuesta" == "sí" ]]; then
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$EWW_DIR/SOPORTE_ERRORES.md" >/dev/null 2>&1 &
        echo "Abriendo guía con la aplicación predeterminada del sistema..."
    elif [ -f "$EWW_DIR/SOPORTE_ERRORES.md" ]; then
        cat "$EWW_DIR/SOPORTE_ERRORES.md"
    else
        echo "No se pudo localizar la guía."
    fi
fi

echo -e "\nPresiona [ENTER] para salir del diagnosticador."
read -r || true
exit 0
