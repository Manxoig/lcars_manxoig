#!/bin/bash

# Script para interactuar con el volumen con soporte de pamixer y pactl

has_pamixer() {
    command -v pamixer >/dev/null 2>&1
}

has_pactl() {
    command -v pactl >/dev/null 2>&1
}

get_volume() {
    local vol=""
    if has_pamixer; then
        vol=$(pamixer --get-volume 2>/dev/null)
    elif has_pactl; then
        # Obtener el volumen del default sink
        vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -Po '[0-9]+(?=%)' | head -n1)
    fi
    if [ -z "$vol" ]; then
        echo "0"
    else
        echo "$vol"
    fi
}

set_volume_up() {
    if has_pamixer; then
        pamixer -i 5
    elif has_pactl; then
        pactl set-sink-volume @DEFAULT_SINK@ +5%
    fi
}

set_volume_down() {
    if has_pamixer; then
        pamixer -d 5
    elif has_pactl; then
        pactl set-sink-volume @DEFAULT_SINK@ -5%
    fi
}

toggle_mute() {
    if has_pamixer; then
        pamixer -t
    elif has_pactl; then
        pactl set-sink-mute @DEFAULT_SINK@ toggle
    fi
}

case $1 in
    get)
        get_volume
        ;;
    up)
        set_volume_up
        ;;
    down)
        set_volume_down
        ;;
    mute)
        toggle_mute
        ;;
    *)
        echo "Uso: $0 {get|up|down|mute}"
        exit 1
        ;;
esac
