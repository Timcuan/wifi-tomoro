#!/bin/bash
# INGFO TOMORO — menu ON / OFF

INGFO_TOMORO_NAME="INGFO TOMORO"

tomoro_tui_cursor_hide() { printf '\033[?25l'; }
tomoro_tui_cursor_show() { printf '\033[?25h'; }

tomoro_tui_clear() {
    printf '\033[2J\033[H'
}

tomoro_tui_read_key() {
    local key rest
    IFS= read -rsn1 key 2>/dev/null || return 1
    if [[ "$key" == $'\x1b' ]]; then
        IFS= read -rsn2 -t 0.2 rest 2>/dev/null || true
        key+="${rest}"
    fi
    printf '%s' "$key"
}

tomoro_tui_wrap_index() {
    local idx="$1" max="$2"
    if (( idx < 0 )); then
        echo $((max - 1))
    elif (( idx >= max )); then
        echo 0
    else
        echo "$idx"
    fi
}

tomoro_tui_show_mechanism() {
    echo -e "  ${TOMORO_BOLD}Cara kerja${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}ISP/WiFi sering blokir dengan membaca nama situs (SNI)${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}di awal koneksi HTTPS, atau memanipulasi DNS.${TOMORO_NC}"
    echo
    echo -e "  ${TOMORO_GREEN}ON${TOMORO_NC}  ${TOMORO_DIM}1) SpoofDPI jalan di Mac (127.0.0.1:${TOMORO_PROXY_PORT})${TOMORO_NC}"
    echo -e "     ${TOMORO_DIM}2) Paket TLS dipecah/disorder supaya sensor DPI gagal${TOMORO_NC}"
    echo -e "     ${TOMORO_DIM}3) Proxy HTTP/S + SOCKS sistem macOS ke SpoofDPI${TOMORO_NC}"
    echo -e "     ${TOMORO_DIM}4) DNS aman (DoH) + resolver publik · rules GMGN/crypto${TOMORO_NC}"
    echo -e "     ${TOMORO_DIM}5) Biarkan terminal ON terbuka; ganti WiFi otomatis dilacak${TOMORO_NC}"
    echo
    echo -e "  ${TOMORO_YELLOW}OFF${TOMORO_NC} ${TOMORO_DIM}Proxy, DNS, IPv6 dikembalikan · SpoofDPI dihentikan${TOMORO_NC}"
    echo
    echo -e "  ${TOMORO_DIM}Bukan VPN penuh. Bukan untuk captive portal hotel.${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}Lanjut: docs/KEAMANAN.md · ingfo test-crypto${TOMORO_NC}"
}

tomoro_tui_draw_menu() {
    local selected="$1"
    local running="${2:-0}"
    local -a items=("ON  — nyalakan bypass WiFi" "OFF — matikan & pulihkan Mac")
    local i pointer label
    local count=${#items[@]}

    tomoro_tui_clear
    tomoro_ui_logo

    if [[ "$running" == "1" ]]; then
        tomoro_read_saved_port 2>/dev/null || true
        echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}Status: ON${TOMORO_NC}  ${TOMORO_DIM}bypass aktif · port ${TOMORO_PROXY_PORT}${TOMORO_NC}"
        echo -e "  ${TOMORO_DIM}Terminal sesi start harus tetap terbuka.${TOMORO_NC}"
    else
        echo -e "  ${TOMORO_DIM}Status: OFF${TOMORO_NC}  ${TOMORO_DIM}bypass tidak berjalan${TOMORO_NC}"
    fi
    echo
    echo -e "  ${TOMORO_BOLD}Kontrol${TOMORO_NC}  ${TOMORO_DIM}↑↓ · Enter · q keluar${TOMORO_NC}"
    echo

    for ((i = 0; i < count; i++)); do
        if (( i == selected )); then
            pointer="${TOMORO_CYAN}${TOMORO_BOLD}>${TOMORO_NC}"
            label="${TOMORO_CYAN}${TOMORO_BOLD}${items[$i]}${TOMORO_NC}"
        else
            pointer=" "
            label="${items[$i]}"
        fi
        printf "  %s %b\n" "$pointer" "$label"
    done

    echo
    if declare -f tomoro_ui_rule >/dev/null 2>&1; then
        echo -e "  ${TOMORO_DIM}$(tomoro_ui_rule 60)${TOMORO_NC}"
    fi
    echo
    tomoro_tui_show_mechanism
}

tomoro_tui_action_on() {
    tomoro_tui_cursor_show
    if tomoro_is_running; then
        echo
        tomoro_log_warn "Sudah ON."
        tomoro_log_info "Jangan tutup terminal tempat bypass dijalankan."
        tomoro_log_info "Untuk OFF: pilih OFF di menu atau ${TOMORO_BOLD}ingfo off${TOMORO_NC}"
        tomoro_tui_press_enter
        return 0
    fi
    TOMORO_ARGS=()
    TOMORO_MODE="${TOMORO_MODE:-deep}"
    tomoro_cmd_start
}

tomoro_tui_action_off() {
    tomoro_tui_cursor_show
    if ! tomoro_is_running; then
        echo
        tomoro_log_info "Sudah OFF. Memastikan proxy/DNS bersih ..."
    fi
    tomoro_cmd_stop
    tomoro_tui_press_enter
}

tomoro_tui_press_enter() {
    echo
    echo -ne "  ${TOMORO_DIM}Enter = kembali ke menu${TOMORO_NC} "
    read -r _
}

tomoro_tui_main() {
    if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
        tomoro_log_err "Menu butuh terminal interaktif."
        tomoro_log_info "ON:  ingfo on   ·  OFF: ingfo off"
        exit 1
    fi

    local selected=0 key
    local -a actions=(on off)
    local count=${#actions[@]}
    local running=0

    tomoro_tui_cursor_hide
    trap 'tomoro_tui_cursor_show; printf "\n"' EXIT INT TERM

    while true; do
        tomoro_is_running && running=1 || running=0
        tomoro_tui_draw_menu "$selected" "$running"
        key="$(tomoro_tui_read_key)" || key=""

        case "$key" in
            $'\x1b[A'|$'\x1bOA')
                selected=$(tomoro_tui_wrap_index $((selected - 1)) "$count")
                ;;
            $'\x1b[B'|$'\x1bOB')
                selected=$(tomoro_tui_wrap_index $((selected + 1)) "$count")
                ;;
            ''|$'\n'|$'\r')
                case "${actions[$selected]}" in
                    on)  tomoro_tui_action_on ;;
                    off) tomoro_tui_action_off ;;
                esac
                ;;
            q|Q)
                tomoro_tui_cursor_show
                echo
                tomoro_log_ok "Keluar."
                exit 0
                ;;
        esac
    done
}
