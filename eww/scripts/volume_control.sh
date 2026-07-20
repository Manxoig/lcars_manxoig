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

get_device() {
    if has_pactl; then
        local def_sink=$(pactl get-default-sink 2>/dev/null)
        if [ -n "$def_sink" ]; then
            local desc=$(pactl list sinks 2>/dev/null | awk -v sink="$def_sink" '
                $0 ~ "Name: " sink { in_sink=1 }
                in_sink && $1 ~ "^Description:" {
                    sub(/^[[:space:]]*Description:[[:space:]]*/, "")
                    print
                    exit
                }
                $1 == "Name:" && $0 !~ sink { in_sink=0 }
            ')
            if [ -n "$desc" ]; then
                echo "$desc"
                return
            fi
            echo "$def_sink"
            return
        fi
    fi
    echo "Default Output"
}

case $1 in
    get)
        get_volume
        ;;
    device)
        get_device
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
        echo "Uso: $0 {get|device|up|down|mute}"
        exit 1
        ;;
esac
