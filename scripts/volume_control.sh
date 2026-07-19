#!/bin/bash

# Script simple para interactuar con el volumen
case $1 in
    get)
        pamixer --get-volume
        ;;
    up)
        pamixer -i 5
        ;;
    down)
        pamixer -d 5
        ;;
    mute)
        pamixer -t
        ;;
esac
