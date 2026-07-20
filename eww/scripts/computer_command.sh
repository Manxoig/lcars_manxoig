#!/bin/bash

# Script de interfaz de comandos LCARS / Borg Computer
TITLE="🖖 LCARS / BORG COMPUTER INTERFACE"
PROMPT="State your command or query, Captain:"

# Prefer kdialog, fallback to zenity or krunner
if command -v kdialog >/dev/null 2>&1; then
    USER_INPUT=$(kdialog --title "$TITLE" --inputbox "$PROMPT" "")
elif command -v zenity >/dev/null 2>&1; then
    USER_INPUT=$(zenity --entry --title="$TITLE" --text="$PROMPT")
else
    krunner &
    exit 0
fi

# Exit if cancelled or empty
if [ -z "$USER_INPUT" ]; then
    exit 0
fi

CMD_LOWER=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]')

case "$CMD_LOWER" in
    *reboot*|*reiniciar*)
        qdbus org.kde.Shutdown /Shutdown logoutAndReboot || systemctl reboot
        ;;
    *status*|*estado*|*monitor*)
        plasma-systemmonitor &
        ;;
    *app*|*aplicacion*|*run*)
        krunner &
        ;;
    *config*|*configuracion*|*settings*)
        systemsettings &
        ;;
    *mute*|*silencio*)
        "$(dirname "$0")/volume_control.sh" mute
        ;;
    *temp*|*temperatura*)
        CPU_T=$("$(dirname "$0")/sensors.py" cpu)
        GPU_T=$("$(dirname "$0")/sensors.py" gpu)
        notify-send "🖖 LCARS Thermal Status" "CPU: ${CPU_T}°C | GPU: ${GPU_T}°C" -i dialog-information
        ;;
    *stardate*|*fecha*)
        STAR=$("$(dirname "$0")/stardate.py")
        notify-send "🖖 LCARS Stardate" "Stardate: $STAR" -i dialog-information
        ;;
    *)
        # Try running as shell command if executable exists, otherwise show acknowledgment
        if command -v "$USER_INPUT" >/dev/null 2>&1; then
            "$USER_INPUT" &
            notify-send "🖖 LCARS Executing" "Executing: '$USER_INPUT'..." -i system-run
        else
            notify-send "🖖 LCARS Computer" "Acknowledged command: '$USER_INPUT'" -i dialog-information
        fi
        ;;
esac
