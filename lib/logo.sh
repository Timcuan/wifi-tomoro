#!/bin/bash
# INGFO TOMORO — ASCII logo

tomoro_logo_full() {
    cat <<'LOGO'
  ___ _   _ _____ ___     _____ ___ ___ ___  
 / __| | | |  ___| _ \   |_   _| _ \ __| _ \
| (__| |_| | |_  |  __/    | | |   / _||   /
 \___|\___/|___| |_|      |_| |_|_\___|_|_\
LOGO
}

tomoro_logo_compact() {
    cat <<'LOGO'
  ┌────────────────────────────────────┐
  │   ◆  INGFO TOMORO  ·  WiFi bypass   │
  └────────────────────────────────────┘
LOGO
}

tomoro_print_logo_art() {
    if [[ "${COLUMNS:-100}" -lt 50 ]]; then
        tomoro_logo_compact
    else
        tomoro_logo_full
    fi
}
