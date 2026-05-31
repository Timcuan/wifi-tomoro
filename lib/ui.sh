#!/bin/bash
# INGFO TOMORO — banner, animasi, progress

INGFO_TOMORO_NAME="${INGFO_TOMORO_NAME:-INGFO TOMORO}"
TOMORO_VERSION="2.3.1"

tomoro_ui_logo() {
    echo -e "${TOMORO_CYAN}${TOMORO_BOLD}"
    tomoro_print_logo_art
    echo -e "${TOMORO_NC}  ${TOMORO_MAGENTA}${TOMORO_BOLD}${INGFO_TOMORO_NAME}${TOMORO_NC}  ${TOMORO_DIM}· WiFi · DPI · GMGN · v${TOMORO_VERSION}${TOMORO_NC}"
    echo
}

tomoro_ui_intro_animation() {
    [[ ! -t 1 ]] && return 0
    local frames=(
        "Menyiapkan antarmuka"
        "Menyiapkan antarmuka."
        "Menyiapkan antarmuka.."
        "Menyiapkan antarmuka..."
    )
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧')
    local i s=0
    tomoro_tui_clear
    tomoro_ui_logo
    for i in "${!frames[@]}"; do
        printf "\r  ${TOMORO_CYAN}%s${TOMORO_NC} %s" "${spin[$((s % ${#spin[@]}))]}" "${frames[$i]}"
        s=$((s + 1))
        sleep 0.12
    done
    printf "\r\033[K"
    echo -e "  ${TOMORO_GREEN}[ok]${TOMORO_NC} Siap."
    echo
    sleep 0.2
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
    local filled=$((current * 20 / total))
    local bar=""
    local i
    for ((i = 0; i < 20; i++)); do
        if (( i < filled )); then bar+="█"; else bar+="░"; fi
    done
    echo -e "${TOMORO_MAGENTA}${TOMORO_BOLD}  ▸ ${current}/${total}${TOMORO_NC} ${label}"
    echo -e "  ${TOMORO_CYAN}[${bar}]${TOMORO_NC}"
}

tomoro_ui_divider() {
    echo -e "${TOMORO_DIM}  ─────────────────────────────────────────────────────────────${TOMORO_NC}"
}

tomoro_ui_success_banner() {
    echo
    echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}╭──────────────────────────────────────────────────────────╮${TOMORO_NC}"
    echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}│  🛡  ${INGFO_TOMORO_NAME} — PERISAI AKTIF                         │${TOMORO_NC}"
    echo -e "  ${TOMORO_GREEN}${TOMORO_BOLD}╰──────────────────────────────────────────────────────────╯${TOMORO_NC}"
    echo
    if declare -f tomoro_show_shield_status >/dev/null 2>&1; then
        tomoro_show_shield_status
        echo
    fi
    echo -e "  ${TOMORO_DIM}Target:${TOMORO_NC} GMGN · crypto · Cursor · ChatGPT"
    echo
    echo -e "  ${TOMORO_YELLOW}${TOMORO_BOLD}⚡ Penting${TOMORO_NC}"
    echo -e "     • Biarkan ${TOMORO_BOLD}terminal ini terbuka${TOMORO_NC}"
    echo -e "     • Menu lagi : buka terminal baru → ${TOMORO_BOLD}ingfo${TOMORO_NC}"
    echo -e "     • Uji crypto : ${TOMORO_BOLD}ingfo test-crypto${TOMORO_NC}"
    echo -e "     • Berhenti   : ${TOMORO_BOLD}Ctrl+C${TOMORO_NC} atau ${TOMORO_BOLD}ingfo stop${TOMORO_NC}"
    tomoro_ui_divider
    echo
}

tomoro_ui_status_card() {
    local title="$1"
    local state="$2"
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
    echo -e "${TOMORO_BOLD}INGFO TOMORO — perintah${TOMORO_NC}"
    echo
    printf "  ${TOMORO_CYAN}%-16s${TOMORO_NC} %s\n" "ingfo" "Menu interaktif (↑↓ Enter)"
    printf "  ${TOMORO_CYAN}%-16s${TOMORO_NC} %s\n" "ingfo start" "Aktifkan perisai"
    printf "  ${TOMORO_CYAN}%-16s${TOMORO_NC} %s\n" "ingfo stop" "Matikan & pulihkan"
    printf "  ${TOMORO_CYAN}%-16s${TOMORO_NC} %s\n" "ingfo status" "Status bypass"
    printf "  ${TOMORO_CYAN}%-16s${TOMORO_NC} %s\n" "ingfo test-crypto" "Uji GMGN & crypto"
    printf "  ${TOMORO_CYAN}%-16s${TOMORO_NC} %s\n" "ingfo start --ultra" "Mode ultra"
    echo
    echo -e "${TOMORO_DIM}tomoro = alias ingfo${TOMORO_NC}"
    echo
}

tomoro_doctor_report() {
    local label="$1"
    local state="$2"
    local note="${3:-}"
    local icon color
    case "$state" in
        ok)   icon="✓"; color="${TOMORO_GREEN}" ;;
        warn) icon="!"; color="${TOMORO_YELLOW}" ;;
        err)  icon="✗"; color="${TOMORO_RED}" ;;
        *)    icon="·"; color="${TOMORO_NC}" ;;
    esac
    printf "  ${color}%s${TOMORO_NC} %-22s" "$icon" "$label"
    [[ -n "$note" ]] && printf " ${TOMORO_DIM}%s${TOMORO_NC}" "$note"
    echo
}
