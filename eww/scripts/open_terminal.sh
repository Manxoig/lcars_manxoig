#!/bin/bash

# Launch preferred terminal emulator
if command -v konsole >/dev/null 2>&1; then
    konsole &
elif command -v alacritty >/dev/null 2>&1; then
    alacritty &
elif command -v kitty >/dev/null 2>&1; then
    kitty &
elif command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal &
else
    x-terminal-emulator &
fi
