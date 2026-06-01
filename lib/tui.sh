#!/bin/bash
# INGFO TOMORO — menu ON / OFF (UX + animasi)

INGFO_TOMORO_NAME="INGFO TOMORO"
TOMORO_TUI_SHOW_MECH="${TOMORO_TUI_SHOW_MECH:-0}"

tomoro_tui_cursor_hide() { tomoro_anim_hide_cursor 2>/dev/null || printf '\033[?25l'; }
tomoro_tui_cursor_show() { tomoro_anim_show_cursor 2>/dev/null || printf '\033[?25h'; }

tomoro_tui_clear() {
    if declare -f tomoro_anim_clear >/dev/null 2>&1; then
        tomoro_anim_clear
    else
        printf '\033[2J\033[H'
    fi
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

tomoro_tui_default_selection() {
    local running="$1"
    if [[ "$running" == "1" ]]; then
        echo 1
    else
        echo 0
    fi
}

tomoro_tui_item_hint() {
    local sel="$1" running="$2"
    case "$sel" in
        0)
            if [[ "$running" == "1" ]]; then
                echo "Sudah ON — pilih OFF untuk mematikan"
            else
                echo "Nyalakan bypass · terminal ini harus tetap terbuka"
            fi
            ;;
        1)
            if [[ "$running" == "1" ]]; then
                echo "Matikan proxy & kembalikan DNS/IPv6 Mac"
            else
                echo "Sudah OFF — tidak ada yang perlu dimatikan"
            fi
            ;;
    esac
}

tomoro_tui_show_mechanism_short() {
    echo -e "  ${TOMORO_DIM}Alur: App → proxy Mac → SpoofDPI → internet (anti-DPI)${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}Tekan ${TOMORO_BOLD}?${TOMORO_NC}${TOMORO_DIM} untuk detail mekanisme${TOMORO_NC}"
}

tomoro_tui_show_mechanism_full() {
    echo -e "  ${TOMORO_BOLD}Cara kerja${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}WiFi/ISP blokir lewat SNI (nama situs) atau DNS.${TOMORO_NC}"
    echo
    echo -e "  ${TOMORO_GREEN}ON${TOMORO_NC}  SpoofDPI + proxy macOS + DNS aman + rules GMGN/crypto"
    echo -e "  ${TOMORO_YELLOW}OFF${TOMORO_NC} Semua dikembalikan · Mac normal lagi"
    echo -e "  ${TOMORO_DIM}Tekan ? tutup detail${TOMORO_NC}"
}

tomoro_tui_draw_menu() {
    local selected="$1"
    local running="${2:-0}"
    local show_mech="${3:-0}"
    local -a items=("ON  — nyalakan bypass" "OFF — matikan & pulihkan")
    local i pointer label hint
    local count=${#items[@]}

    tomoro_tui_clear
    tomoro_ui_brand
    echo

    if [[ "$running" == "1" ]]; then
        tomoro_read_saved_port 2>/dev/null || true
        echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}[ON]${TOMORO_NC}  bypass aktif · port ${TOMORO_PROXY_PORT}"
        echo -e "  ${TOMORO_DIM}Jangan tutup terminal sesi start.${TOMORO_NC}"
    else
        echo -e "  ${TOMORO_DIM}[OFF]${TOMORO_NC} bypass tidak berjalan"
    fi

    echo
    echo -e "  ${TOMORO_BOLD}Pilih${TOMORO_NC}  ${TOMORO_DIM}↑↓  Enter  q keluar  ? info${TOMORO_NC}"
    echo

    for ((i = 0; i < count; i++)); do
        if (( i == selected )); then
            if (( i == 0 )); then
                pointer="${TOMORO_GREEN}${TOMORO_BOLD}>${TOMORO_NC}"
                label="${TOMORO_GREEN}${TOMORO_BOLD}${items[$i]}${TOMORO_NC}"
            else
                pointer="${TOMORO_YELLOW}${TOMORO_BOLD}>${TOMORO_NC}"
                label="${TOMORO_YELLOW}${TOMORO_BOLD}${items[$i]}${TOMORO_NC}"
            fi
        else
            pointer=" "
            label="${TOMORO_DIM}${items[$i]}${TOMORO_NC}"
        fi
        printf "  %b %b\n" "$pointer" "$label"
    done

    hint="$(tomoro_tui_item_hint "$selected" "$running")"
    echo
    echo -e "  ${TOMORO_CYAN}${hint}${TOMORO_NC}"

    echo
    tomoro_ui_divider
    echo
    if [[ "$show_mech" == "1" ]]; then
        tomoro_tui_show_mechanism_full
    else
        tomoro_tui_show_mechanism_short
    fi
}

tomoro_tui_action_on() {
    tomoro_tui_cursor_show
    if tomoro_is_running; then
        tomoro_anim_alt_off 2>/dev/null || true
        echo
        tomoro_log_warn "Sudah ON."
        tomoro_log_info "Pilih OFF atau: ingfo off"
        tomoro_tui_press_enter
        tomoro_anim_alt_on 2>/dev/null || true
        return 0
    fi
    tomoro_anim_alt_off 2>/dev/null || true
    echo
    if declare -f tomoro_anim_run >/dev/null 2>&1; then
        tomoro_anim_flash "Menyalakan perisai ..." "${TOMORO_GREEN}"
    fi
    TOMORO_ARGS=()
    TOMORO_MODE="${TOMORO_MODE:-deep}"
    tomoro_cmd_start
}

tomoro_tui_action_off() {
    tomoro_tui_cursor_show
    tomoro_anim_alt_off 2>/dev/null || true
    echo
    if declare -f tomoro_anim_run >/dev/null 2>&1; then
        TOMORO_SKIP_HEADER=1 tomoro_anim_run "Mematikan perisai" tomoro_cmd_stop
    else
        if ! tomoro_is_running; then
            tomoro_log_info "Sudah OFF. Membersihkan sisa pengaturan ..."
        fi
        tomoro_cmd_stop
    fi
    tomoro_tui_press_enter
    tomoro_anim_alt_on 2>/dev/null || true
}

tomoro_tui_press_enter() {
    echo
    echo -ne "  ${TOMORO_DIM}Enter · kembali ke menu${TOMORO_NC} "
    read -r _
}

tomoro_tui_main() {
    if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
        tomoro_log_err "Menu butuh terminal interaktif."
        tomoro_log_info "ON: ingfo on   OFF: ingfo off"
        exit 1
    fi

    local selected=-1 key running=0 redraw=1
    local -a actions=(on off)
    local count=${#actions[@]}

    tomoro_anim_alt_on
    tomoro_tui_cursor_hide
    trap 'tomoro_tui_cursor_show; tomoro_anim_alt_off 2>/dev/null || true; printf "\n"' EXIT INT TERM

    tomoro_ui_intro_animation

    while true; do
        tomoro_is_running && running=1 || running=0
        if (( selected < 0 )); then
            selected="$(tomoro_tui_default_selection "$running")"
        fi
        if (( redraw )); then
            tomoro_tui_draw_menu "$selected" "$running" "$TOMORO_TUI_SHOW_MECH"
            redraw=0
        fi

        key="$(tomoro_tui_read_key)" || key=""

        case "$key" in
            $'\x1b[A'|$'\x1bOA')
                selected=$(tomoro_tui_wrap_index $((selected - 1)) "$count")
                redraw=1
                ;;
            $'\x1b[B'|$'\x1bOB')
                selected=$(tomoro_tui_wrap_index $((selected + 1)) "$count")
                redraw=1
                ;;
            '?'|h|H)
                if [[ "$TOMORO_TUI_SHOW_MECH" == "1" ]]; then
                    TOMORO_TUI_SHOW_MECH=0
                else
                    TOMORO_TUI_SHOW_MECH=1
                fi
                redraw=1
                ;;
            ''|$'\n'|$'\r')
                case "${actions[$selected]}" in
                    on)  tomoro_tui_action_on; selected=-1; redraw=1 ;;
                    off) tomoro_tui_action_off; selected=-1; redraw=1 ;;
                esac
                ;;
            q|Q)
                tomoro_tui_cursor_show
                tomoro_anim_alt_off
                echo
                tomoro_log_ok "Keluar."
                exit 0
                ;;
        esac
    done
}
