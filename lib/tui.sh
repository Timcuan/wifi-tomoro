#!/bin/bash
# INGFO TOMORO — menu interaktif (↑↓ Enter, animasi)

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
    elif [[ "$key" == $'\x7f' || "$key" == $'\177' ]]; then
        key="BACKSPACE"
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

tomoro_tui_draw_menu() {
    local selected="$1"
    local running="${2:-0}"
    local -a items=(
        "Aktifkan perisai (mode deep)"
        "Aktifkan ultra (DPI keras)"
        "Matikan perisai"
        "Status bypass"
        "Doctor — cek sistem"
        "Test koneksi"
        "Test crypto / GMGN"
        "Install SpoofDPI"
        "Panduan perintah"
        "Keluar"
    )
    local i label pointer
    local count=${#items[@]}

    tomoro_tui_clear
    tomoro_ui_logo
    if [[ "$running" == "1" ]]; then
        echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}[aktif]${TOMORO_NC} Perisai ${TOMORO_DIM}(biarkan terminal start terbuka)${TOMORO_NC}"
    else
        echo -e "  ${TOMORO_DIM}[mati] Perisai nonaktif${TOMORO_NC}"
    fi
    echo
    echo -e "  ${TOMORO_BOLD}Menu${TOMORO_NC}  ${TOMORO_DIM}↑↓ pilih · Enter jalankan · q keluar${TOMORO_NC}"
    echo

    for ((i = 0; i < count; i++)); do
        if (( i == selected )); then
            pointer="${TOMORO_CYAN}${TOMORO_BOLD}>${TOMORO_NC}"
            label="${TOMORO_CYAN}${TOMORO_BOLD}${items[$i]}${TOMORO_NC}"
        else
            pointer=" "
            label="${TOMORO_DIM}${items[$i]}${TOMORO_NC}"
        fi
        printf "  %s %b\n" "$pointer" "$label"
    done
    echo
    if declare -f tomoro_ui_rule >/dev/null 2>&1; then
        echo -e "  ${TOMORO_DIM}$(tomoro_ui_rule 60)${TOMORO_NC}"
    fi
    echo -e "  ${TOMORO_DIM}GMGN · crypto · Cursor · WiFi restricted${TOMORO_NC}"
}

tomoro_tui_run_action() {
    local action="$1"
    tomoro_tui_cursor_show
    case "$action" in
        start)
            TOMORO_ARGS=()
            tomoro_cmd_start
            ;;
        start:ultra)
            TOMORO_ARGS=(--ultra)
            tomoro_parse_start_flags "${TOMORO_ARGS[@]}"
            tomoro_cmd_start
            ;;
        stop)     tomoro_cmd_stop ;;
        status)   tomoro_cmd_status; tomoro_tui_press_enter ;;
        doctor)   tomoro_doctor; tomoro_tui_press_enter ;;
        test)     tomoro_cmd_test; tomoro_tui_press_enter ;;
        test-crypto) tomoro_cmd_test_crypto; tomoro_tui_press_enter ;;
        install)  tomoro_cmd_install; tomoro_tui_press_enter ;;
        help)     tomoro_usage; tomoro_tui_press_enter ;;
        quit)     exit 0 ;;
    esac
}

tomoro_tui_press_enter() {
    echo
    echo -ne "  ${TOMORO_DIM}Tekan Enter untuk kembali ke menu...${TOMORO_NC}"
    read -r _
}

tomoro_tui_main() {
    if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
        tomoro_log_err "Menu interaktif butuh terminal interaktif."
        tomoro_log_info "Pakai: ingfo start | ingfo stop | ingfo help"
        exit 1
    fi

    local selected=0
    local key action
    local -a actions=(
        start
        start:ultra
        stop
        status
        doctor
        test
        test-crypto
        install
        help
        quit
    )
    local count=${#actions[@]}
    local running=0

    tomoro_tui_cursor_hide
    trap 'tomoro_tui_cursor_show; printf "\n"' EXIT INT TERM

    tomoro_ui_intro_animation

    while true; do
        tomoro_is_running && running=1 || running=0
        tomoro_tui_draw_menu "$selected" "$running"
        key="$(tomoro_tui_read_key)" || key=""

        case "$key" in
            $'\x1b[A'|$'\x1bOA') # up
                selected=$(tomoro_tui_wrap_index $((selected - 1)) "$count")
                ;;
            $'\x1b[B'|$'\x1bOB') # down
                selected=$(tomoro_tui_wrap_index $((selected + 1)) "$count")
                ;;
            ''|$'\n'|$'\r') # enter
                action="${actions[$selected]}"
                if [[ "$action" == "quit" ]]; then
                    tomoro_tui_cursor_show
                    echo
                    tomoro_log_ok "Sampai jumpa dari ${INGFO_TOMORO_NAME}."
                    exit 0
                fi
                tomoro_tui_run_action "$action"
                ;;
            q|Q)
                tomoro_tui_cursor_show
                exit 0
                ;;
        esac
    done
}
