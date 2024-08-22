#!/bin/bash

MONITORS_FILE='monitors.txt'

if [ -f "$MONITORS_FILE" ]; then
    echo "Monitors file found."
    exit 0
fi

readarray -t MONITORS < <(xrandr | grep ' connected' | cut -d '+' -f1)

printf 'Found monitor: %s\n' "${MONITORS[@]}"

echo 'Monitors in horizontal order:' > "$MONITORS_FILE"
printf -- '- %s\n' "${MONITORS[@]}" >> "$MONITORS_FILE"
echo '' >> "$MONITORS_FILE"
printf '=%.0s' {0..10} >> "$MONITORS_FILE"
echo "" >> "$MONITORS_FILE"
echo 'Monitors in vertical order:' >> "$MONITORS_FILE"
printf -- '- %s\n' "${MONITORS[@]}" >> "$MONITORS_FILE"