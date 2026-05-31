#!/bin/bash
# Terminal UI — banner, tabel, progress, spinner.

TOMORO_VERSION="2.1.0"

tomoro_ui_logo() {
    echo -e "${TOMORO_CYAN}${TOMORO_BOLD}"
    cat <<'EOF'
  ╦ ╦╦╔╗╔╔═╗  ╔╦╗╔═╗╔╗─╔═╗╦═╗╔═╗
  ║║║║║║║║╣───║║║║ ║╠╩╗║ ║╠╦╝║╣
  ╚╩╝╩╝╚╝╚═╝  ╩ ╩╚═╝╚═╝╚═╝╩╚═╚═╝
EOF
    echo -e "${TOMORO_NC}  ${TOMORO_DIM}macOS WiFi / DPI bypass · v${TOMORO_VERSION}${TOMORO_NC}"
    echo
}

tomoro_ui_dim_init() {
    if [[ -t 1 ]]; then
        TOMORO_DIM='\033[2m'
    else
        TOMORO_DIM=''
    fi
}

tomoro_print_header() {
    tomoro_ui_dim_init
    tomoro_ui_logo
    echo -e "  ${TOMORO_DIM}┌─────────────────────────────────────────────────────────────┐${TOMORO_NC}"
    printf "  ${TOMORO_DIM}│${TOMORO_NC} %-28s ${TOMORO_DIM}│${TOMORO_NC} %-28s ${TOMORO_DIM}│${TOMORO_NC}\n" \
        "Folder" "Port"
    printf "  ${TOMORO_DIM}│${TOMORO_NC} ${TOMORO_BLUE}%-28s${TOMORO_NC} ${TOMORO_DIM}│${TOMORO_NC} ${TOMORO_BOLD}%-28s${TOMORO_NC} ${TOMORO_DIM}│${TOMORO_NC}\n" \
        "${TOMORO_REPO_DIR}" "${TOMORO_PROXY_PORT}"
    echo -e "  ${TOMORO_DIM}└─────────────────────────────────────────────────────────────┘${TOMORO_NC}"
    echo
}

tomoro_ui_step() {
    local current="$1"
    local total="$2"
    local label="$3"
    echo -e "${TOMORO_MAGENTA}${TOMORO_BOLD}  ▸ Langkah ${current}/${total}${TOMORO_NC} ${TOMORO_DIM}—${TOMORO_NC} ${label}"
}

tomoro_ui_divider() {
    echo -e "${TOMORO_DIM}  ─────────────────────────────────────────────────────────────${TOMORO_NC}"
}

tomoro_ui_success_banner() {
    echo
    echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}╭──────────────────────────────────────────────────────────╮${TOMORO_NC}"
    echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}│  🛡  PERISAI AKTIF — bypass DPI + DNS + multi-layer      │${TOMORO_NC}"
    echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}╰──────────────────────────────────────────────────────────╯${TOMORO_NC}"
    echo
    if declare -f tomoro_show_shield_status >/dev/null 2>&1; then
        tomoro_show_shield_status
        echo
    fi
    echo -e "  ${TOMORO_DIM}Target:${TOMORO_NC} Cursor · ChatGPT · Reddit · TLS/SNI terblokir"
    echo
    echo -e "  ${TOMORO_YELLOW}${TOMORO_BOLD}⚡ Penting${TOMORO_NC}"
    echo -e "     • Biarkan ${TOMORO_BOLD}terminal ini terbuka${TOMORO_NC}"
    echo -e "     • Verifikasi : ${TOMORO_BOLD}./tomoro test${TOMORO_NC}"
    echo -e "     • Berhenti   : ${TOMORO_BOLD}Ctrl+C${TOMORO_NC}  atau  ${TOMORO_BOLD}./tomoro stop${TOMORO_NC}"
    tomoro_ui_divider
    echo
}

tomoro_ui_status_card() {
    local title="$1"
    local state="$2"   # on | off | warn
    local detail="$3"

    local badge color
    case "$state" in
        on)   badge="● AKTIF";  color="${TOMORO_GREEN}" ;;
        off)  badge="○ MATI";   color="${TOMORO_DIM}" ;;
        warn) badge="◐ PERINGATAN"; color="${TOMORO_YELLOW}" ;;
        *)    badge="?"; color="${TOMORO_NC}" ;;
    esac

    echo -e "  ${color}${TOMORO_BOLD}${badge}${TOMORO_NC}  ${TOMORO_BOLD}${title}${TOMORO_NC}"
    [[ -n "$detail" ]] && echo -e "  ${TOMORO_DIM}${detail}${TOMORO_NC}"
    echo
}

tomoro_ui_spinner() {
    local msg="$1"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while true; do
        printf "\r  ${TOMORO_CYAN}%s${TOMORO_NC} %s" "${frames[$i]}" "$msg"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.08
    done
}

tomoro_ui_run_with_spinner() {
    local msg="$1"
    shift
    tomoro_ui_spinner "$msg" &
    local spin_pid=$!
    "$@"
    local exit_code=$?
    kill "$spin_pid" 2>/dev/null || true
    wait "$spin_pid" 2>/dev/null || true
    printf "\r\033[K"
    return "$exit_code"
}

tomoro_usage() {
    tomoro_ui_logo
    echo -e "${TOMORO_BOLD}Perintah${TOMORO_NC}"
    echo
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "./tomoro" "Sama dengan start"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "start" "Aktifkan bypass (terminal tetap terbuka)"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "stop" "Matikan bypass & pulihkan proxy macOS"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "status" "Cek status bypass"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "install" "Unduh SpoofDPI ke bin/"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "doctor" "Diagnosa lingkungan"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "version" "Tampilkan versi"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "test" "Uji endpoint via proxy (saat aktif)"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "start --deep" "Mode deep (default)"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "start --standard" "Mode ringan"
    printf "  ${TOMORO_CYAN}%-14s${TOMORO_NC} %s\n" "help" "Bantuan ini"
    echo
    echo -e "${TOMORO_BOLD}Opsi${TOMORO_NC}"
    echo -e "  ${TOMORO_DIM}TOMORO_PORT=9090${TOMORO_NC}       Ganti port HTTP (default 8080)"
    echo -e "  ${TOMORO_DIM}TOMORO_MODE=standard${TOMORO_NC}  Mode ringan"
    echo -e "  ${TOMORO_DIM}TOMORO_SOCKS_ENABLE=0${TOMORO_NC}   Matikan SOCKS (deep mode)"
    echo -e "  ${TOMORO_DIM}TOMORO_DNS_DOH_URL=...${TOMORO_NC}  Ganti resolver DoH"
    echo
    echo -e "${TOMORO_BOLD}Dokumentasi${TOMORO_NC}"
    echo -e "  ${TOMORO_BLUE}docs/PANDUAN.md${TOMORO_NC}  Panduan langkah demi langkah"
    echo -e "  ${TOMORO_BLUE}CHANGELOG.md${TOMORO_NC}     Riwayat perubahan"
    echo
}

tomoro_doctor_report() {
    local label="$1"
    local state="$2"  # ok warn err
    local note="${3:-}"

    local icon color
    case "$state" in
        ok)   icon="✓"; color="${TOMORO_GREEN}" ;;
        warn) icon="!"; color="${TOMORO_YELLOW}" ;;
        err)  icon="✗"; color="${TOMORO_RED}" ;;
        *)    icon="·"; color="${TOMORO_NC}" ;;
    esac
    printf "  ${color}%s${TOMORO_NC} %-22s" "$icon" "$label"
    [[ -n "$note" ]] && printf "${TOMORO_DIM}%s${TOMORO_NC}" "$note"
    echo
}
